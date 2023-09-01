import 'dart:async';

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:effective_map/src/models/styles/user_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import 'package:effective_map/src/common/constants.dart';
import 'package:effective_map/src/common/package_colors.dart';
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
import 'package:effective_map/src/maps/osm/map_controller/osm_map_controller.dart';
import 'package:effective_map/src/maps/i_map_state.dart';
import 'package:effective_map/src/maps/osm/utils/bbox_extension.dart';
import 'package:effective_map/src/maps/osm/utils/cached_tile_provider.dart';
import 'package:effective_map/src/maps/osm/utils/flutter_map_extension.dart';
import 'package:effective_map/src/common/number_extractor.dart';
import 'package:effective_map/src/maps/osm/view/widgets/any_map_object_layer.dart';
import 'package:effective_map/src/maps/osm/view/widgets/cluster_widget.dart';
import 'package:effective_map/src/maps/osm/view/widgets/user_location_layer.dart';

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

class OSMMap extends StatefulWidget {
  final void Function(mp.MapPosition position, bool finished)?
      onCameraPositionChanged;
  final void Function(lat_lng.LatLng latLng)? onMapTap;
  final void Function(marker.Marker marker)? onMarkerTap;
  final void Function(MapObjectWithGeometry object)? onObjectTap;
  final void Function(mc.MapController controller)? onMapCreate;
  final void Function(bool isCentred)? isCameraCentredOnUserCallback;
  final void Function()? checkVisibleObjects;

  final List<tile.NetworkTileProvider> tiles;
  final List<marker.Marker> markers;
  final List<MapObjectWithGeometry> objects;

  final marker.Marker? selectedMarker;
  final MapObjectWithGeometry? selectedObject;

  final String urlTemplate;
  final String userAgentPackageName;
  final lat_lng.LatLng? userPosition;

  final double interactivePolygonVisibilityThreshold;
  final lat_lng.LatLng initialCameraPosition;
  final double minCameraZoom;
  final double maxCameraZoom;
  final double initialCameraZoom;
  final bool areMarkersVisible;

  final String? userMarkerViewPath;
  final Widget? selectedMarkerView;
  final Widget? unselectedMarkerView;
  final UserMarkerStyle userMarkerStyle;

  final Color selectedStrokeColor;
  final Color unselectedStrokeColor;
  final Color selectedFillColor;
  final Color unselectedFillColor;

  const OSMMap({
    super.key,
    required this.tiles,
    required this.markers,
    required this.objects,
    this.selectedMarker,
    this.selectedObject,
    this.onMapTap,
    this.onCameraPositionChanged,
    this.isCameraCentredOnUserCallback,
    this.onMarkerTap,
    this.onObjectTap,
    this.onMapCreate,
    this.userPosition,
    this.checkVisibleObjects,
    this.selectedMarkerView,
    this.unselectedMarkerView,
    this.userMarkerViewPath,
    UserMarkerStyle? userMarkerStyle,
    String? urlTemplate,
    double? initialCameraZoom,
    double? maxCameraZoom,
    double? minCameraZoom,
    Color? selectedStrokeColor,
    Color? unselectedStrokeColor,
    Color? selectedFillColor,
    Color? unselectedFillColor,
    bool? areMarkersVisible,
    String? userAgentPackageName,
    double? interactivePolygonVisibilityThreshold,
    lat_lng.LatLng? initialCameraPosition,
  })  : initialCameraZoom = initialCameraZoom ?? _initialCameraZoom,
        maxCameraZoom = maxCameraZoom ?? _maxCameraZoom,
        minCameraZoom = minCameraZoom ?? _minCameraZoom,
        selectedFillColor =
            selectedFillColor ?? PackageColors.selectedFillColor,
        userMarkerStyle = userMarkerStyle ?? const UserMarkerStyle(),
        unselectedFillColor = unselectedFillColor ?? PackageColors.fillColor,
        selectedStrokeColor =
            selectedStrokeColor ?? PackageColors.selectedStrokeColor,
        unselectedStrokeColor =
            unselectedStrokeColor ?? PackageColors.strokeColor,
        areMarkersVisible = areMarkersVisible ?? false,
        userAgentPackageName = userAgentPackageName ?? 'Unknown',
        interactivePolygonVisibilityThreshold =
            interactivePolygonVisibilityThreshold ??
                _interactivePolygonVisibilityThreshold,
        initialCameraPosition = initialCameraPosition ?? _initialCameraPosition,
        urlTemplate = urlTemplate ?? '';

  @override
  State<OSMMap> createState() => _OSMMapState();
}

class _OSMMapState extends State<OSMMap>
    with TickerProviderStateMixin
    implements IMapState<MapObject, Marker> {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);

  bool _isCameraCenteredOnUser = false;

  late final List<Marker> _markers = [];
  late final List<MapObject> _objects = [];
  late final Marker? _selectedMarker;
  late final MapObject? _selectedObject;

  @override
  List<MapObject> get objects => _objects;

  @override
  List<Marker> get markers => _markers;

  @override
  MapObject? get selectedObject => _selectedObject;

  @override
  Marker? get selectedMarker => _selectedMarker;

  @override
  bool get isCameraCentredOnUser => _isCameraCenteredOnUser;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _init() {
    for (final marker in widget.markers) {
      final flutterMarker = convertMarker(marker);
      if (flutterMarker != null) {
        _markers.add(flutterMarker);
      }
    }
    for (final object in widget.objects) {
      final flutterMapObject = convertObject(object);
      if (flutterMapObject != null) {
        _objects.add(flutterMapObject);
      }
    }
    _selectedObject = widget.selectedObject != null
        ? convertObject(widget.selectedObject!, selected: true)
        : null;
    _selectedMarker = widget.selectedMarker != null
        ? convertMarker(widget.selectedMarker!, selected: true)
        : null;
  }

  @override
  Marker? convertMarker(marker.Marker packageMarker, {bool selected = false}) =>
      Marker(
        key: packageMarker.key,
        height: 56,
        width: 50,
        point: packageMarker.position.toLatLng(),
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (context) => Align(
          alignment: Alignment.bottomCenter,
          child: _resolveMarker(selected),
        ),
      );

  Widget _resolveMarker(bool selected) {
    if (widget.selectedMarkerView != null && selected) {
      return widget.selectedMarkerView!;
    }
    if (widget.unselectedMarkerView != null && !selected) {
      return widget.unselectedMarkerView!;
    }
    return Image.asset(
      selected ? Constants.selectedPin : Constants.pin,
    );
  }

  @override
  MapObject? convertObject(MapObjectWithGeometry mapObject,
          {bool selected = false}) =>
      mapObject.geometry.mapOrNull(point: (geometry) {
        final circle = CircleMarker(
          point: LatLng(geometry.center.latitude, geometry.center.longitude),
          radius: 4,
          borderStrokeWidth: 2,
          borderColor: selected
              ? widget.selectedStrokeColor
              : widget.unselectedStrokeColor,
          color:
              selected ? widget.selectedFillColor : widget.unselectedFillColor,
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
          strokeWidth: 2,
          color: selected
              ? widget.selectedStrokeColor
              : widget.unselectedStrokeColor,
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
              strokeWidth: 2,
              color: selected
                  ? widget.selectedStrokeColor
                  : widget.unselectedStrokeColor,
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
          borderColor: selected
              ? widget.selectedStrokeColor
              : widget.unselectedStrokeColor,
          borderStrokeWidth: 2,
          color:
              selected ? widget.selectedFillColor : widget.unselectedFillColor,
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
              borderColor: selected
                  ? widget.selectedStrokeColor
                  : widget.unselectedStrokeColor,
              borderStrokeWidth: 2,
              color: selected
                  ? widget.selectedFillColor
                  : widget.unselectedFillColor,
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
  Widget build(BuildContext context) => FlutterMap(
        mapController: _mapController.mapController,
        options: MapOptions(
          center: widget.initialCameraPosition.toLatLng(),
          zoom: widget.initialCameraZoom,
          minZoom: widget.minCameraZoom,
          maxZoom: widget.maxCameraZoom,
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.pinchMove,
          onPositionChanged: (position, hasGesture) =>
              onCameraPositionChanged(position.toMapPosition(), !hasGesture),
          onMapEvent: (event) {
            if (event.source == MapEventSource.dragEnd) {
              widget.checkVisibleObjects?.call();
            }
          },
          onTap: (position, latLng) => onMapTap(latLng.toLatLng()),
          onMapReady: () {
            widget.onMapCreate?.call(
              OSMMapController(
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
            tileProvider: CachedTileProvider(),
          ),
          if ((markers.isEmpty || widget.areMarkersVisible) &&
              widget.tiles.isNotEmpty)
            TileLayer(
              urlTemplate: widget.tiles.first.baseUrl,
              maxZoom: widget.maxCameraZoom,
              panBuffer: 3,
              backgroundColor: Colors.transparent,
              zoomOffset: 1,
              tileProvider: CachedTileProvider(
                headers: widget.tiles.first.headers,
              ),
              userAgentPackageName: widget.userAgentPackageName,
            ),
          if (widget.areMarkersVisible) AnyMapObjectLayer(mapObjects: objects),
          if (selectedObject != null)
            AnyMapObjectLayer(
              mapObjects: [selectedObject!],
            ),
          if (markers.isNotEmpty && widget.areMarkersVisible)
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                size: const Size(38, 38),
                maxClusterRadius: 80,
                disableClusteringAtZoom: 18,
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
                    onClusterTap(clusterNode.bounds.toBBox()),
                onMarkerTap: onMarkerTap,
                builder: (
                  BuildContext context,
                  List<Marker> markers,
                ) =>
                    ClusterWidget(count: markers.length),
              ),
            ),
          if (selectedMarker != null)
            GestureDetector(
              onTap: () => onMarkerTap(
                selectedMarker!,
              ),
              child: MarkerLayer(markers: [selectedMarker!]),
            ),
          if (widget.userPosition != null)
            UserLocationLayer(
              location: widget.userPosition!,
              isCenteredOnUser: isCameraCentredOnUser,
              userMarkerViewPath: widget.userMarkerViewPath,
              style: widget.userMarkerStyle,
            ),
        ],
      );

  @override
  void onCameraPositionChanged(mp.MapPosition position, bool finished) {
    if (position.center != null) {
      resolveIfCameraCenteredOnUser(position.center!);
    }
    widget.onCameraPositionChanged?.call(position, finished);
  }

  @override
  void onMapTap(lat_lng.LatLng latLng) {
    widget.onMapTap?.call(latLng);
  }

  @override
  void onClusterTap(BBox bbox) {
    _mapController.animatedFitBounds(
      bbox.toBounds(),
      options: FitBoundsOptions(
        padding: const EdgeInsets.all(12),
        maxZoom: widget.maxCameraZoom,
      ),
    );
  }

  @override
  void onMarkerTap(Marker marker) {
    if (_selectedMarker?.key == marker.key) return;
    moveCameraToLocation(marker.point.toLatLng());
    widget.onMarkerTap?.call(marker.toEffectiveMarker());
  }

  @override
  Future<void> onObjectTap(MapObject mapObject) async {
    if (selectedObject?.id == mapObject.id) return;
    unawaited(moveCameraToMatchBBox(mapObject.bounds.toBBox()));
    final object = widget.objects.firstWhereOrNull((element) =>
        element.id == extractNumberFromText(mapObject.id.toString()));
    if (object != null) {
      widget.onObjectTap?.call(object);
    }
  }

  @override
  Future<void> moveCameraToMatchBBox(BBox bbox) async {
    await _mapController.animatedFitBounds(
      bbox.toBounds(),
      options: FitBoundsOptions(
        padding: const EdgeInsets.all(12),
        maxZoom: widget.interactivePolygonVisibilityThreshold,
      ),
    );
    widget.checkVisibleObjects?.call();
  }

  @override
  Future<void> moveCameraToLocation(lat_lng.LatLng location) async {
    await _mapController.animateTo(
      dest: LatLng(location.latitude, location.longitude),
      zoom: max(widget.interactivePolygonVisibilityThreshold,
          _mapController.mapController.zoom),
    );
    widget.checkVisibleObjects?.call();
  }

  @override
  void resolveIfCameraCenteredOnUser(lat_lng.LatLng center) {
    var isCentered = false;
    if (center.latitude.toStringAsFixed(4) ==
            widget.userPosition?.latitude.toStringAsFixed(4) &&
        center.longitude.toStringAsFixed(4) ==
            widget.userPosition?.longitude.toStringAsFixed(4)) {
      isCentered = true;
    }
    if (isCentered != _isCameraCenteredOnUser) {
      setState(() {
        _isCameraCenteredOnUser = isCentered;
        widget.isCameraCentredOnUserCallback?.call(isCentered);
      });
    }
  }
}
