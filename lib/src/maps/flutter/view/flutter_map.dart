import 'package:effective_map/src/models/map_layer.dart' as layer;
import 'package:effective_map/src/models/styles/cluster_marker_style.dart';
import 'package:effective_map/src/models/styles/marker_style.dart';
import 'package:effective_map/src/models/styles/object_style.dart';
import 'package:effective_map/src/models/styles/user_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/map_position.dart' as mp;
import 'package:effective_map/src/models/marker.dart' as marker;
import 'package:effective_map/src/models/network_tiles_provider.dart' as tile;
import 'package:effective_map/src/models/latlng.dart' as lat_lng;
import 'package:effective_map/src/models/map_controller/map_controller.dart'
    as mc;
import 'package:effective_map/src/models/map_object_with_geometry.dart';
import 'package:effective_map/src/models/map_object_wrappers/circle_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/map_object.dart';
import 'package:effective_map/src/models/map_object_wrappers/multi_polygon_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/multi_polyline_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/polygon_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/polyline_wrapper.dart';
import 'package:effective_map/src/maps/flutter/map_controller/flutter_map_controller.dart';
import 'package:effective_map/src/maps/i_map_state.dart';
import 'package:effective_map/src/maps/flutter/utils/bbox_extension.dart';
import 'package:effective_map/src/maps/flutter/utils/cached_tile_provider.dart';
import 'package:effective_map/src/maps/flutter/utils/flutter_map_extension.dart';
import 'package:effective_map/src/maps/flutter/view/widgets/any_map_object_layer.dart';
import 'package:effective_map/src/maps/flutter/view/widgets/cluster_widget.dart';
import 'package:effective_map/src/maps/flutter/view/widgets/user_location_layer.dart';

const _initialCameraPosition =
    lat_lng.LatLng(latitude: 55.796391, longitude: 49.108891);
const _initialCameraZoom = 12.5;
const _maxCameraZoom = 19.0;
const _minCameraZoom = 3.0;

const _interactivePolygonVisibilityThreshold = 17.3;

const _defaultTileTransition = TileDisplay.fadeIn(
  duration: Duration(milliseconds: 100),
);

const _clusterAnimationsDuration = Duration(milliseconds: 100);

class FlutterMap extends StatefulWidget {
  final void Function(mp.MapPosition position, bool finished)?
      onCameraPositionChanged;
  final void Function(lat_lng.LatLng latLng)? onMapTap;
  final void Function(BBox bbox)? onClusterTap;
  final void Function(marker.Marker marker)? onMarkerTap;
  final void Function(mc.MapController controller)? onMapCreate;

  final List<tile.NetworkTileProvider> tiles;
  final List<layer.MapLayer> layers;

  final String urlTemplate;
  final String userAgentPackageName;
  final lat_lng.LatLng? userPosition;

  final double interactivePolygonVisibilityThreshold;
  final lat_lng.LatLng initialCameraPosition;
  final double minCameraZoom;
  final double maxCameraZoom;
  final double initialCameraZoom;

  final bool areTilesVisible;
  final bool areUserPositionVisible;

  final UserMarkerStyle userMarkerStyle;

  const FlutterMap({
    super.key,
    required this.tiles,
    required this.layers,
    this.onMapTap,
    this.onClusterTap,
    this.onCameraPositionChanged,
    this.onMarkerTap,
    this.onMapCreate,
    this.userPosition,
    UserMarkerStyle? userMarkerStyle,
    ClusterMarkerStyle? clusterMarkerStyle,
    String? urlTemplate,
    double? initialCameraZoom,
    double? maxCameraZoom,
    double? minCameraZoom,
    bool? areTilesVisible,
    bool? areUserPositionVisible,
    String? userAgentPackageName,
    double? interactivePolygonVisibilityThreshold,
    lat_lng.LatLng? initialCameraPosition,
  })  : initialCameraZoom = initialCameraZoom ?? _initialCameraZoom,
        maxCameraZoom = maxCameraZoom ?? _maxCameraZoom,
        minCameraZoom = minCameraZoom ?? _minCameraZoom,
        userMarkerStyle = userMarkerStyle ?? const UserMarkerStyle(),
        areTilesVisible = areTilesVisible ?? false,
        areUserPositionVisible = areUserPositionVisible ?? false,
        userAgentPackageName = userAgentPackageName ?? 'Unknown',
        interactivePolygonVisibilityThreshold =
            interactivePolygonVisibilityThreshold ??
                _interactivePolygonVisibilityThreshold,
        initialCameraPosition = initialCameraPosition ?? _initialCameraPosition,
        urlTemplate = urlTemplate ?? '';

  @override
  State<FlutterMap> createState() => _FlutterMapState();
}

class _FlutterMapState extends State<FlutterMap>
    with TickerProviderStateMixin
    implements IMapState<MapObject, Marker, Widget> {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);

  late final List<Widget> _layers = [];

  @override
  List<Widget> get layers => _layers;

  @override
  void initState() {
    _convert();
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FlutterMap oldWidget) {
    _convert();
    super.didUpdateWidget(oldWidget);
  }

  void _convert() {
    _layers.clear();
    for (final layer in widget.layers) {
      final widget = convertLayer(layer);
      if (widget != null) {
        _layers.add(widget);
      }
    }
  }

  @override
  Widget? convertLayer(layer.MapLayer layer) {
    return layer.mapOrNull<Widget?>(
      mapObjectLayer: (layer) {
        final List<MapObject> mapObjects = [];
        for (final object in layer.objects) {
          final flutterObject = convertObject(object, layer.style);
          if (flutterObject != null) {
            mapObjects.add(flutterObject);
          }
        }
        return AnyMapObjectLayer(mapObjects: mapObjects);
      },
      markerLayer: (layer) {
        final List<Marker> markers = [];
        for (final marker in layer.objects) {
          final flutterMarker = convertMarker(marker, layer.style);
          if (flutterMarker != null) {
            markers.add(flutterMarker);
          }
        }
        return MarkerLayer(markers: markers);
      },
      clusterizedMarkerLayer: (layer) {
        final List<Marker> markers = [];
        for (final marker in layer.objects) {
          final flutterMarker = convertMarker(marker, layer.style.markerStyle);
          if (flutterMarker != null) {
            markers.add(flutterMarker);
          }
        }
        return MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            size: Size(layer.style.width, layer.style.height),
            maxClusterRadius:
                (layer.clusterRadius * layer.style.devicePixelRatio).toInt(),
            disableClusteringAtZoom: layer.minZoom,
            markers: markers,
            animationsOptions: const AnimationsOptions(
              zoom: _clusterAnimationsDuration,
              fitBound: _clusterAnimationsDuration,
              centerMarker: _clusterAnimationsDuration,
              spiderfy: _clusterAnimationsDuration,
            ),
            spiderfyCluster: false,
            zoomToBoundsOnClick: false,
            centerMarkerOnClick: false,
            onClusterTap: (clusterNode) =>
                widget.onClusterTap?.call(clusterNode.bounds.toBBox()),
            onMarkerTap: (marker) =>
                widget.onMarkerTap?.call(marker.toPackageMarker()),
            builder: (
              BuildContext context,
              List<Marker> markers,
            ) =>
                ClusterWidget(
              count: markers.length,
              style: layer.style,
            ),
          ),
        );
      },
    );
  }

  @override
  Marker? convertMarker(marker.Marker packageMarker, MarkerStyle style) =>
      Marker(
        key: packageMarker.key,
        height: style.height,
        width: style.width,
        point: packageMarker.position.toLatLng(),
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => widget.onMarkerTap?.call(packageMarker),
          child: Align(
            alignment: Alignment(style.offset.dx, style.offset.dy),
            child: Image.asset(
              packageMarker.selected
                  ? style.selectedMarkerViewPath
                  : style.unselectedMarkerViewPath,
            ),
          ),
        ),
      );

  @override
  MapObject? convertObject(
          MapObjectWithGeometry mapObject, ObjectStyle style) =>
      mapObject.geometry.mapOrNull(point: (geometry) {
        final circle = CircleMarker(
          point: LatLng(geometry.center.latitude, geometry.center.longitude),
          radius: style.pointRadius,
          borderStrokeWidth: style.strokeWidth,
          borderColor: mapObject.selected
              ? style.selectedStrokeColor
              : style.unselectedStrokeColor,
          color: mapObject.selected
              ? style.selectedFillColor
              : style.unselectedFillColor,
        );
        return CircleWrapper(
          id: '${mapObject.id}_circle',
          circle: circle,
        );
      }, line: (geometry) {
        final polyline = Polyline(
          points: geometry.points
              .map((e) => LatLng(e.center.latitude, e.center.longitude))
              .toList(),
          strokeWidth: style.strokeWidth,
          color: mapObject.selected
              ? style.selectedStrokeColor
              : style.unselectedStrokeColor,
        );
        return PolylineWrapper(
          id: '${mapObject.id}_polyline',
          polyline: polyline,
        );
      }, multiline: (geometry) {
        final polylines = <Polyline>[];
        for (final lines in geometry.lines) {
          polylines.add(
            Polyline(
              points: lines.points
                  .map((e) => LatLng(e.center.latitude, e.center.longitude))
                  .toList(),
              strokeWidth: style.strokeWidth,
              color: mapObject.selected
                  ? style.selectedStrokeColor
                  : style.unselectedStrokeColor,
            ),
          );
        }
        return MultiPolylineWrapper(
          id: '${mapObject.id}_multiline',
          polylines: polylines,
        );
      }, polygon: (geometry) {
        final polygon = Polygon(
          points: geometry.outerRing.points
              .map((e) => LatLng(e.center.latitude, e.center.longitude))
              .toList(),
          holePointsList: geometry.innerRings
              ?.map(
                (e) => List<LatLng>.from(
                  e.points.map(
                    (e) => LatLng(e.center.latitude, e.center.longitude),
                  ),
                ),
              )
              .toList(),
          borderColor: mapObject.selected
              ? style.selectedStrokeColor
              : style.unselectedStrokeColor,
          borderStrokeWidth: style.strokeWidth,
          color: mapObject.selected
              ? style.selectedFillColor
              : style.unselectedFillColor,
          isFilled: true,
        );
        return PolygonWrapper(
          id: '${mapObject.id}_polygon',
          polygon: polygon,
        );
      }, multipolygon: (geometry) {
        final polygons = <Polygon>[];
        for (final polygon in geometry.polygons) {
          polygons.add(
            Polygon(
              points: polygon.outerRing.points
                  .map((e) => LatLng(e.center.latitude, e.center.longitude))
                  .toList(),
              holePointsList: polygon.innerRings
                  ?.map(
                    (e) => List<LatLng>.from(
                      e.points.map(
                        (e) => LatLng(e.center.latitude, e.center.longitude),
                      ),
                    ),
                  )
                  .toList(),
              borderColor: mapObject.selected
                  ? style.selectedStrokeColor
                  : style.unselectedStrokeColor,
              borderStrokeWidth: style.strokeWidth,
              color: mapObject.selected
                  ? style.selectedFillColor
                  : style.unselectedFillColor,
              isFilled: true,
            ),
          );
        }
        return MultiPolygonWrapper(
          id: '${mapObject.id}_multipolygon',
          polygons: polygons,
        );
      });

  @override
  Widget build(BuildContext context) => flutter_map.FlutterMap(
        mapController: _mapController.mapController,
        options: MapOptions(
          initialCenter: widget.initialCameraPosition.toLatLng(),
          initialZoom: widget.initialCameraZoom,
          minZoom: widget.minCameraZoom,
          maxZoom: widget.maxCameraZoom,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.pinchMove |
                InteractiveFlag.rotate,
          ),
          onPositionChanged: (position, hasGesture) => widget
              .onCameraPositionChanged
              ?.call(position.toMapPosition(), !hasGesture),
          onTap: (position, latLng) => widget.onMapTap?.call(latLng.toLatLng()),
          onMapReady: () {
            widget.onMapCreate?.call(
              FlutterMapController(
                  controller: _mapController,
                  maxCameraZoom: widget.maxCameraZoom,
                  interactivePolygonVisibilityThreshold:
                      widget.interactivePolygonVisibilityThreshold),
            );
          },
        ),
        nonRotatedChildren: const [
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
            ],
          ),
        ],
        children: [
          TileLayer(
            urlTemplate: widget.urlTemplate,
            maxZoom: widget.maxCameraZoom,
            panBuffer: 3,
            tileDisplay: _defaultTileTransition,
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: widget.userAgentPackageName,
            tileProvider: CachedTileProvider(headers: {}),
          ),
          if (widget.areTilesVisible && widget.tiles.isNotEmpty)
            TileLayer(
              urlTemplate: widget.tiles.first.baseUrl,
              maxZoom: widget.maxCameraZoom,
              panBuffer: 3,
              zoomOffset: 1,
              tileProvider: CachedTileProvider(
                headers: widget.tiles.first.headers,
              ),
              userAgentPackageName: widget.userAgentPackageName,
            ),
          ...layers,
          if (widget.areUserPositionVisible && widget.userPosition != null)
            UserLocationLayer(
              location: widget.userPosition!,
              style: widget.userMarkerStyle,
            ),
        ],
      );
}
