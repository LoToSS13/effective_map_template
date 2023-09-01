import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/map_position.dart';
import 'package:effective_map/src/models/marker.dart';
import 'package:effective_map/src/models/network_tiles_provider.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/models/map_controller/map_controller.dart';
import 'package:effective_map/src/maps/yandex/map_controller/yandex_map_controller.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';
import 'package:effective_map/src/maps/i_map_state.dart';
import 'package:effective_map/src/maps/yandex/utils/bbox_extension.dart';
import 'package:effective_map/src/maps/yandex/utils/bounding_box_former.dart';
import 'package:effective_map/src/maps/yandex/utils/geoobjects_canvas_painter.dart';
import 'package:effective_map/src/maps/yandex/utils/map_geometry_creator.dart';
import 'package:effective_map/src/common/number_extractor.dart';
import 'package:effective_map/src/maps/yandex/utils/placemarks.dart';
import 'package:effective_map/src/maps/yandex/utils/yandex_map_extension.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as yandex;

const _initialCameraPosition = MapPosition(
  center: LatLng(latitude: 55.796391, longitude: 49.108891),
  zoom: _initialCameraZoom,
);

const _initialCameraZoom = 12.5;
const _interactivePolygonVisibilityThreshold = 17.3;

class YandexMap extends StatefulWidget {
  final void Function(MapPosition position, bool finished)?
      onCameraPositionChanged;
  final void Function(LatLng latLng)? onMapTap;
  final void Function(Marker marker)? onMarkerTap;
  final void Function(MapObjectWithGeometry object)? onObjectTap;
  final void Function(MapController controller)? onMapCreate;
  final void Function(bool isCentred)? isCameraCentredOnUserCallback;
  final void Function()? checkVisibleObjects;

  final List<NetworkTileProvider> tiles;
  final List<Marker> markers;
  final List<MapObjectWithGeometry> objects;

  final Marker? selectedMarker;
  final MapObjectWithGeometry? selectedObject;

  final String userAgentPackageName;
  final LatLng? userPosition;

  final double interactivePolygonVisibilityThreshold;
  final MapPosition initialCameraPosition;

  final bool areMarkersVisible;

  final Widget? selectedMarkerView;
  final Widget? unselectedMarkerView;

  final Color selectedStrokeColor;
  final Color unselectedStrokeColor;
  final Color selectedFillColor;
  final Color unselectedFillColor;

  const YandexMap({
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
    this.isCameraCentredOnUserCallback,
    this.userPosition,
    this.checkVisibleObjects,
    this.selectedMarkerView,
    this.unselectedMarkerView,
    double? maxCameraZoom,
    double? minCameraZoom,
    Color? selectedStrokeColor,
    Color? unselectedStrokeColor,
    Color? selectedFillColor,
    Color? unselectedFillColor,
    bool? areMarkersVisible,
    String? userAgentPackageName,
    double? interactivePolygonVisibilityThreshold,
    MapPosition? initialCameraPosition,
  })  : selectedFillColor =
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
  State<YandexMap> createState() => _YandexMapState();
}

class _YandexMapState extends State<YandexMap>
    implements IMapState<yandex.MapObject<dynamic>, yandex.PlacemarkMapObject> {
  late final yandex.YandexMapController _mapController;

  bool _isCameraCenteredOnUser = false;

  late final List<yandex.PlacemarkMapObject> _markers = [];
  late final List<yandex.MapObject<dynamic>> _objects = [];
  late final yandex.PlacemarkMapObject? _selectedMarker;
  late final yandex.MapObject<dynamic>? _selectedObject;

  @override
  bool get isCameraCentredOnUser => _isCameraCenteredOnUser;

  @override
  List<yandex.PlacemarkMapObject> get markers => _markers;

  @override
  yandex.PlacemarkMapObject? get selectedMarker => _selectedMarker;

  @override
  yandex.MapObject<dynamic>? get selectedObject => _selectedObject;

  @override
  List<yandex.MapObject<dynamic>> get objects => _objects;

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
  yandex.PlacemarkMapObject? convertMarker(Marker packageMarker,
          {bool selected = false}) =>
      yandex.PlacemarkMapObject(
        mapId: yandex.MapObjectId(packageMarker.key.toString()),
        point: packageMarker.position.toPoint(),
        consumeTapEvents: true,
        onTap: (placemark, _) => onMarkerTap(placemark),
        opacity: 1,
        icon: generatePlacemarkIcon(selected: selected),
      );

  @override
  yandex.MapObject<dynamic>? convertObject(MapObjectWithGeometry mapObject,
          {bool selected = false}) =>
      mapObject.geometry.mapOrNull<yandex.MapObject<dynamic>>(
        line: (line) => yandex.PolylineMapObject(
          mapId: yandex.MapObjectId('${mapObject.id}_line'),
          polyline: MapGeometryCreator.createPolyline(line.points),
          strokeWidth: 1,
          turnRadius: 0,
          zIndex: selected ? 1 : 0,
          strokeColor: selected
              ? widget.selectedStrokeColor
              : widget.unselectedStrokeColor,
          onTap: (object, _) => onObjectTap(object),
        ),
        multiline: (multiline) => yandex.MapObjectCollection(
          mapId: yandex.MapObjectId('${mapObject.id}_multiline'),
          onTap: (object, _) => onObjectTap(object),
          zIndex: selected ? 1 : 0,
          mapObjects: multiline.lines
              .map(
                (e) => yandex.PolylineMapObject(
                  mapId:
                      yandex.MapObjectId('${mapObject.id}_line_${e.hashCode}'),
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
        polygon: (polygon) => yandex.PolygonMapObject(
          mapId: yandex.MapObjectId('${mapObject.id}_polygon'),
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
        multipolygon: (multipolygon) => yandex.MapObjectCollection(
          mapId: yandex.MapObjectId('${mapObject.id}_multipolygon'),
          zIndex: selected ? 1 : 0,
          onTap: (object, _) => onObjectTap(object),
          mapObjects: multipolygon.polygons
              .map(
                (e) => yandex.PolygonMapObject(
                  mapId: yandex.MapObjectId(
                      '${mapObject.id}_polygon_${e.hashCode}'),
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
  Widget build(BuildContext context) => yandex.YandexMap(
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        mode2DEnabled: true,
        tiles: widget.areMarkersVisible || markers.isEmpty
            ? widget.tiles.toYandexTiles()
            : [],
        onUserLocationAdded: (yandex.UserLocationView userLocationView) async =>
            userLocationView.copyWith(
          pin: userLocationView.pin.copyWith(
            opacity: 1,
            icon: yandex.PlacemarkIcon.single(
              yandex.PlacemarkIconStyle(
                image: yandex.BitmapDescriptor.fromBytes(
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
            icon: yandex.PlacemarkIcon.single(
              yandex.PlacemarkIconStyle(
                image: yandex.BitmapDescriptor.fromBytes(
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
        onMapCreated: (yandex.YandexMapController controller) {
          _mapController = controller;

          _mapController
            ..moveCamera(
              yandex.CameraUpdate.newCameraPosition(
                widget.initialCameraPosition.toCameraPosition(),
              ),
            )
            ..toggleUserLayer(visible: true);
          widget.onMapCreate?.call(YandexMapController(
            controller: _mapController,
            interactivePolygonVisibilityThreshold:
                widget.interactivePolygonVisibilityThreshold,
          ));
        },
        onMapTap: (point) => onMapTap(point.toLatLng()),
        mapObjects: [
          if (widget.areMarkersVisible)
            yandex.ClusterizedPlacemarkCollection(
              mapId: const yandex.MapObjectId('excavation_cluster'),
              placemarks: markers,
              radius: 30,
              minZoom: 18,
              onClusterAdded: (self, cluster) async => cluster.copyWith(
                appearance: cluster.appearance.copyWith(
                  opacity: 1,
                  icon: yandex.PlacemarkIcon.single(
                    yandex.PlacemarkIconStyle(
                      image: yandex.BitmapDescriptor.fromBytes(
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
            onCameraPositionChanged(position.toMapPosition(), finished),
      );

  double get _devicePixelRatio => MediaQuery.of(context).devicePixelRatio;

  @override
  void onMarkerTap(yandex.PlacemarkMapObject marker) {
    if (selectedMarker == marker.mapId) return;
    moveCameraToLocation(marker.point.toLatLng());
    widget.onMarkerTap?.call(marker.toMarker());
  }

  @override
  Future<void> onObjectTap(yandex.MapObject<dynamic> mapObject) async {
    if ((await _mapController.getCameraPosition()).zoom <
        widget.interactivePolygonVisibilityThreshold) return;
    final object = widget.objects.firstWhereOrNull(
      (element) =>
          element.id ==
          extractNumberFromText(
            mapObject.mapId.value,
          ),
    );
    if (object != null) {
      widget.onObjectTap?.call(object);
    }
  }

  @override
  Future<void> onCameraPositionChanged(
    MapPosition position,
    bool finished,
  ) async {
    resolveIfCameraCenteredOnUser(position.center);

    if (context.mounted) {
      widget.onCameraPositionChanged?.call(position, finished);
    }
  }

  @override
  void resolveIfCameraCenteredOnUser(LatLng? position) {
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
  Future<void> moveCameraToLocation(LatLng location) async {
    final zoom = (await _mapController.getCameraPosition()).zoom;
    _mapController.moveCamera(
      yandex.CameraUpdate.newCameraPosition(
        yandex.CameraPosition(
          target: yandex.Point(
            latitude: location.latitude,
            longitude: location.longitude,
          ),
          zoom: max(widget.interactivePolygonVisibilityThreshold, zoom),
        ),
      ),
      animation: const yandex.MapAnimation(duration: 1),
    );
  }

  @override
  Future<void> moveCameraToMatchBBox(BBox bbox) => _mapController.moveCamera(
        yandex.CameraUpdate.newBounds(bbox.toBoundringBox()),
        animation: const yandex.MapAnimation(duration: 1),
      );

  @override
  void onClusterTap(BBox bbox) {
    moveCameraToMatchBBox(bbox);
  }

  @override
  void onMapTap(LatLng latLng) {
    widget.onMapTap?.call(latLng);
  }
}
