import 'dart:async';

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:effective_map/src/common/constants.dart';
import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_map_position.dart';
import 'package:effective_map/src/models/effective_marker.dart';
import 'package:effective_map/src/models/effective_network_tiles_provider.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_controller/effective_map_controller.dart';
import 'package:effective_map/src/models/map_controller/osm_effective_map_controller.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';
import 'package:effective_map/src/models/map_object_wrappers/circle_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/map_object.dart';
import 'package:effective_map/src/models/map_object_wrappers/multi_polygon_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/multi_polyline_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/polygon_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/polyline_wrapper.dart';
import 'package:effective_map/i_map_state.dart';
import 'package:effective_map/src/utils/bbox_extension.dart';
import 'package:effective_map/src/utils/cached_tile_provider.dart';
import 'package:effective_map/src/utils/flutter_map_extension.dart';
import 'package:effective_map/src/utils/number_extractor.dart';
import 'package:effective_map/src/view/widgets/any_map_object_layer.dart';
import 'package:effective_map/src/view/widgets/cluster_widget.dart';
import 'package:effective_map/src/view/widgets/user_location_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

const _initialCameraPosition =
    EffectiveLatLng(latitude: 55.796391, longitude: 49.108891);
const _initialCameraZoom = 12.5;
const _maxCameraZoom = 19.0;
const _minCameraZoom = 3.0;

const _interactivePolygonVisibilityThreshold = 17.3;

const _defaultTileTransition = TileDisplay.fadeIn(
  duration: Duration(milliseconds: 100),
);

const _clusterAnimationsDuration = Duration(milliseconds: 100);

class OSMEffectiveMap extends StatefulWidget {
  final void Function(EffectiveMapPosition position, bool finished)?
      onCameraPositionChanged;
  final void Function(EffectiveLatLng latLng)? onMapTap;
  final void Function(EffectiveMarker marker)? onMarkerTap;
  final void Function(MapObjectWithGeometry object)? onObjectTap;
  final void Function(EffectiveMapController controller)? onMapCreate;
  final void Function(bool isCentred)? isCameraCentredOnUserCallback;
  final void Function()? checkVisibleObjects;

  final List<EffectiveNetworkTileProvider> tiles;
  final List<EffectiveMarker> markers;
  final List<MapObjectWithGeometry> objects;

  final EffectiveMarker? selectedMarker;
  final MapObjectWithGeometry? selectedObject;

  final String? urlTemplate;
  final String userAgentPackageName;
  final EffectiveLatLng? userPosition;

  final double interactivePolygonVisibilityThreshold;
  final EffectiveLatLng initialCameraPosition;
  final double minCameraZoom;
  final double maxCameraZoom;
  final double initialCameraZoom;
  final bool areMarkersVisible;

  final Widget? selectedMarkerView;
  final Widget? unselectedMarkerView;

  final Color selectedStrokeColor;
  final Color unselectedStrokeColor;
  final Color selectedFillColor;
  final Color unselectedFillColor;

  const OSMEffectiveMap({
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
    this.urlTemplate,
    this.userPosition,
    this.checkVisibleObjects,
    this.selectedMarkerView,
    this.unselectedMarkerView,
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
    EffectiveLatLng? initialCameraPosition,
  })  : initialCameraZoom = initialCameraZoom ?? _initialCameraZoom,
        maxCameraZoom = maxCameraZoom ?? _maxCameraZoom,
        minCameraZoom = minCameraZoom ?? _minCameraZoom,
        selectedFillColor =
            selectedFillColor ?? PackageColors.selectedFillColor,
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
        initialCameraPosition = initialCameraPosition ?? _initialCameraPosition;

  @override
  State<OSMEffectiveMap> createState() => _OSMEffectiveMapState();
}

class _OSMEffectiveMapState extends State<OSMEffectiveMap>
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
  Marker? convertMarker(EffectiveMarker effectiveMarker,
          {bool selected = false}) =>
      Marker(
        key: effectiveMarker.key,
        height: 56,
        width: 50,
        point: effectiveMarker.position.toLatLng(),
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
        mapController: _mapController,
        options: MapOptions(
          center: widget.initialCameraPosition.toLatLng(),
          zoom: widget.initialCameraZoom,
          minZoom: widget.minCameraZoom,
          maxZoom: widget.maxCameraZoom,
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.pinchMove,
          onPositionChanged: (position, hasGesture) => onCameraPositionChanged(
              position.toEffectiveMapPosition(), !hasGesture),
          onMapEvent: (event) {
            if (event.source == MapEventSource.dragEnd) {
              widget.checkVisibleObjects?.call();
            }
          },
          onTap: (position, latLng) => onMapTap(latLng.toEffectiveLatLng()),
          onMapReady: () {
            widget.onMapCreate?.call(
              OSMEffectiveMapController(
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
            ),
        ],
      );

  @override
  void onCameraPositionChanged(EffectiveMapPosition position, bool finished) {
    if (position.center != null) {
      resolveIfCameraCenteredOnUser(position.center!);
    }
    widget.onCameraPositionChanged?.call(position, finished);
  }

  @override
  void onMapTap(EffectiveLatLng latLng) {
    final isFound = _searchForObjectsInPoints(latLng);
    if (!isFound) {
      widget.onMapTap?.call(latLng);
    }
  }

  @override
  void onClusterTap(BBox bbox) {
    _mapController.animatedFitBounds(
      bbox.toBounds(),
      options: const FitBoundsOptions(
        padding: EdgeInsets.all(12),
        maxZoom: _maxCameraZoom,
      ),
    );
  }

  @override
  void onMarkerTap(Marker marker) {
    if (_selectedMarker?.key == marker.key) return;
    moveCameraToLocation(marker.point.toEffectiveLatLng());
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
  Future<void> moveCameraToLocation(EffectiveLatLng location) async {
    await _mapController.animateTo(
      dest: LatLng(location.latitude, location.longitude),
      zoom: max(
          widget.interactivePolygonVisibilityThreshold, _mapController.zoom),
    );
    widget.checkVisibleObjects?.call();
  }

  bool _searchForObjectsInPoints(EffectiveLatLng effectiveLatLng) {
    if (widget.areMarkersVisible) return false;
    final latLng = effectiveLatLng.toLatLng();
    if (selectedObject?.bounds.contains(latLng) ?? false) {
      return true;
    }
    final object = _objects.firstWhereOrNull((object) {
      if (object is PolylineWrapper) {
        return object.polyline.boundingBox.contains(latLng);
      }
      if (object is PolygonWrapper) {
        return object.polygon.boundingBox.contains(latLng);
      }
      if (object is MultiPolylineWrapper) {
        return object.polylines.any(
          (polyline) => polyline.boundingBox.contains(latLng),
        );
      }
      if (object is MultiPolygonWrapper) {
        return object.polygons.any(
          (polygon) => polygon.boundingBox.contains(latLng),
        );
      }
      return false;
    });
    if (object != null) {
      onObjectTap(object);
      return true;
    }
    return false;
  }

  @override
  void resolveIfCameraCenteredOnUser(EffectiveLatLng center) {
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
