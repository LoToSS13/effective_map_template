import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_map_position.dart';
import 'package:effective_map/src/models/effective_marker.dart';
import 'package:effective_map/src/models/effective_network_tiles_provider.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_controller/effective_map_controller.dart';
import 'package:effective_map/src/models/map_controller/yandex_effective_map_controller.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';
import 'package:effective_map/i_map_state.dart';
import 'package:effective_map/src/utils/bbox_extension.dart';
import 'package:effective_map/src/utils/bounding_box_former.dart';
import 'package:effective_map/src/utils/geoobjects_canvas_painter.dart';
import 'package:effective_map/src/utils/map_geometry_creator.dart';
import 'package:effective_map/src/utils/number_extractor.dart';
import 'package:effective_map/src/utils/placemarks.dart';
import 'package:effective_map/src/utils/yandex_map_extension.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

const _initialCameraPosition = EffectiveMapPosition(
  center: EffectiveLatLng(latitude: 55.796391, longitude: 49.108891),
  zoom: _initialCameraZoom,
);

const _initialCameraZoom = 12.5;
const _markersVisibilityThreshold = 14.67;

const _interactivePolygonVisibilityThreshold = 17.3;

class YandexEffectiveMap extends StatefulWidget {
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
  final EffectiveMapPosition initialCameraPosition;
  final double initialCameraZoom;
  final bool areMarkersVisible;

  final Widget? selectedMarkerView;
  final Widget? unselectedMarkerView;

  final Color selectedStrokeColor;
  final Color unselectedStrokeColor;
  final Color selectedFillColor;
  final Color unselectedFillColor;

  const YandexEffectiveMap({
    super.key,
    required this.tiles,
    required this.markers,
    required this.objects,
    this.selectedMarker,
    this.selectedObject,
    this.onMapTap,
    this.onCameraPositionChanged,
    this.onMarkerTap,
    this.onObjectTap,
    this.onMapCreate,
    this.urlTemplate,
    this.isCameraCentredOnUserCallback,
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
    EffectiveMapPosition? initialCameraPosition,
  })  : initialCameraZoom = initialCameraZoom ?? _initialCameraZoom,
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
  State<YandexEffectiveMap> createState() => _YandexEffectiveMapState();
}

class _YandexEffectiveMapState extends State<YandexEffectiveMap>
    implements IMapState<MapObject, PlacemarkMapObject> {
  late final YandexMapController _mapController;

  bool _isCameraCenteredOnUser = false;

  late final List<PlacemarkMapObject> _markers;
  late final List<MapObject> _objects;
  late final PlacemarkMapObject? _selectedMarker;
  late final MapObject? _selectedObject;

  @override
  bool get isCameraCentredOnUser => _isCameraCenteredOnUser;

  @override
  List<PlacemarkMapObject> get markers => _markers;

  @override
  PlacemarkMapObject? get selectedMarker => _selectedMarker;

  @override
  MapObject? get selectedObject => _selectedObject;

  @override
  List<MapObject> get objects => _objects;

  @override
  void initState() {
    _init();
    super.initState();
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
  PlacemarkMapObject? convertMarker(EffectiveMarker effectiveMarker,
          {bool selected = false}) =>
      PlacemarkMapObject(
        mapId: MapObjectId(effectiveMarker.key.toString()),
        point: effectiveMarker.position.toPoint(),
        consumeTapEvents: true,
        onTap: (placemark, _) => onMarkerTap(placemark),
        opacity: 1,
        icon: generatePlacemarkIcon(selected: selected),
      );

  @override
  MapObject? convertObject(MapObjectWithGeometry mapObject,
          {bool selected = false}) =>
      mapObject.geometry.mapOrNull<MapObject>(
        line: (line) => PolylineMapObject(
          mapId: MapObjectId('${mapObject.id}_line'),
          polyline: MapGeometryCreator.createPolyline(line.points),
          strokeWidth: 1,
          turnRadius: 0,
          zIndex: selected ? 1 : 0,
          strokeColor: selected
              ? widget.selectedStrokeColor
              : widget.unselectedStrokeColor,
          onTap: (object, _) => onObjectTap(object),
        ),
        multiline: (multiline) => MapObjectCollection(
          mapId: MapObjectId('${mapObject.id}_multiline'),
          onTap: (object, _) => onObjectTap(object),
          zIndex: selected ? 1 : 0,
          mapObjects: multiline.lines
              .map(
                (e) => PolylineMapObject(
                  mapId: MapObjectId('${mapObject.id}_line_${e.hashCode}'),
                  polyline: MapGeometryCreator.createPolyline(e.points),
                  strokeWidth: 1,
                  turnRadius: 0,
                  strokeColor: selected
                      ? widget.selectedStrokeColor
                      : widget.unselectedStrokeColor,
                ),
              )
              .toList(),
        ),
        polygon: (polygon) => PolygonMapObject(
          mapId: MapObjectId('${mapObject.id}_polygon'),
          zIndex: selected ? 1 : 0,
          polygon: MapGeometryCreator.createPolygon(
            polygon.outerRing,
            polygon.innerRings ?? [],
          ),
          strokeColor: selected
              ? widget.selectedStrokeColor
              : widget.unselectedStrokeColor,
          fillColor:
              selected ? widget.selectedFillColor : widget.unselectedFillColor,
          onTap: (object, _) => onObjectTap(object),
        ),
        multipolygon: (multipolygon) => MapObjectCollection(
          mapId: MapObjectId('${mapObject.id}_multipolygon'),
          zIndex: selected ? 1 : 0,
          onTap: (object, _) => onObjectTap(object),
          mapObjects: multipolygon.polygons
              .map(
                (e) => PolygonMapObject(
                  mapId: MapObjectId('${mapObject.id}_polygon_${e.hashCode}'),
                  polygon: MapGeometryCreator.createPolygon(
                    e.outerRing,
                    e.innerRings ?? [],
                  ),
                  strokeColor: selected
                      ? widget.selectedStrokeColor
                      : widget.unselectedStrokeColor,
                  fillColor: selected
                      ? widget.selectedFillColor
                      : widget.unselectedFillColor,
                ),
              )
              .toList(),
        ),
      );

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => YandexMap(
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        mode2DEnabled: true,
        tiles: widget.areMarkersVisible || markers.isEmpty
            ? widget.tiles.toYandexTiles()
            : [],
        onUserLocationAdded: (userLocationView) async =>
            userLocationView.copyWith(
          pin: userLocationView.pin.copyWith(
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(
                  await drawUserLocation(
                    devicePixelRatio: _devicePixelRatio,
                  ),
                ),
                scale: 1,
              ),
            ),
          ),
          arrow: userLocationView.arrow.copyWith(
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(
                  await drawUserLocation(
                    devicePixelRatio: _devicePixelRatio,
                  ),
                ),
                scale: 1,
              ),
            ),
          ),
          accuracyCircle: userLocationView.accuracyCircle.copyWith(
            isVisible: false,
            fillColor: Colors.transparent,
            strokeColor: Colors.transparent,
          ),
        ),
        onMapCreated: (controller) {
          _mapController = controller;

          _mapController
            ..moveCamera(
              CameraUpdate.newCameraPosition(
                widget.initialCameraPosition.toCameraPosition(),
              ),
            )
            ..toggleUserLayer(visible: true);
          widget.onMapCreate?.call(YandexEffectiveMapController(
            controller: _mapController,
            interactivePolygonVisibilityThreshold:
                widget.interactivePolygonVisibilityThreshold,
          ));
        },
        onMapTap: (point) => onMapTap(point.toEffectiveLatLng()),
        mapObjects: [
          if (widget.areMarkersVisible)
            ClusterizedPlacemarkCollection(
              mapId: const MapObjectId('excavation_cluster'),
              placemarks: markers,
              radius: 30,
              minZoom: 18,
              onClusterAdded: (self, cluster) async => cluster.copyWith(
                appearance: cluster.appearance.copyWith(
                  opacity: 1,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromBytes(
                        await drawCluster(
                          cluster,
                          devicePixelRatio: _devicePixelRatio,
                        ),
                      ),
                      scale: 1,
                    ),
                  ),
                ),
              ),
              onClusterTap: (self, cluster) => onClusterTap(
                  createPaddedBoundingBoxFrom(
                          cluster.placemarks.map((e) => e.point).toList())
                      .toBBox()),
            ),
          if (widget.areMarkersVisible) ...objects,
        ],
        onCameraPositionChanged: (position, _, finished) =>
            onCameraPositionChanged(
                position.toEffectiveMapPosition(), finished),
      );

  double get _devicePixelRatio => MediaQuery.of(context).devicePixelRatio;

  @override
  void onMarkerTap(PlacemarkMapObject marker) {
    if (selectedMarker == marker.mapId) return;
    moveCameraToLocation(marker.point.toEffectiveLatLng());
    widget.onMarkerTap?.call(marker.toEffectiveMerker());
  }

  @override
  Future<void> onObjectTap(MapObject mapObject) async {
    if ((await _mapController.getCameraPosition()).zoom <
        widget.interactivePolygonVisibilityThreshold) return;
    final object = widget.objects.firstWhereOrNull((element) =>
        element.id == extractNumberFromText(mapObject.mapId.value));
    if (object != null) {
      widget.onObjectTap?.call(object);
    }
  }

  @override
  Future<void> onCameraPositionChanged(
      EffectiveMapPosition position, bool finished) async {
    resolveIfCameraCenteredOnUser(position.center);
    if (position.zoom == null || position.zoom! < _markersVisibilityThreshold) {
      return;
    }

    if (context.mounted) {
      widget.onCameraPositionChanged?.call(position, finished);
    }
  }

  @override
  void resolveIfCameraCenteredOnUser(EffectiveLatLng? position) {
    var isCentered = false;
    if (position?.latitude.toStringAsFixed(4) ==
            widget.userPosition?.latitude.toStringAsFixed(4) &&
        position?.longitude.toStringAsFixed(4) ==
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

  @override
  Future<void> moveCameraToLocation(EffectiveLatLng location) async {
    final zoom = (await _mapController.getCameraPosition()).zoom;
    _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: location.latitude,
            longitude: location.longitude,
          ),
          zoom: max(_interactivePolygonVisibilityThreshold, zoom),
        ),
      ),
      animation: const MapAnimation(duration: 1),
    );
  }

  @override
  Future<void> moveCameraToMatchBBox(BBox bbox) => _mapController.moveCamera(
        CameraUpdate.newBounds(bbox.toBoundringBox()),
        animation: const MapAnimation(duration: 1),
      );

  @override
  void onClusterTap(BBox bbox) {
    moveCameraToMatchBBox(bbox);
  }

  @override
  void onMapTap(EffectiveLatLng latLng) {
    widget.onMapTap?.call(latLng);
  }
}
