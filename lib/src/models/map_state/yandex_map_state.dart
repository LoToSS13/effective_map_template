import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/models/map_state/i_map_state.dart';
import 'package:effective_map/src/utils/bbox_extension.dart';
import 'package:effective_map/src/utils/map_object_appearance.dart';
import 'package:effective_map/src/utils/yandex_map_extension.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../utils/map_geometry_creator.dart';
import '../../utils/placemarks.dart';
import '../bbox.dart';
import '../latlng.dart';
import '../map_object_with_geometry.dart';

const _markersVisibilityThreshold = 14.67;
const _polygonsVisibilityThreshold = 14.67;
const _interactivePolygonVisibilityThreshold = 17.3;

abstract class IYandexMapState<Widget extends StatefulWidget> extends IMapState<
    Widget, MapObject, PlacemarkMapObject, CameraPosition, LatLng> {
  late final YandexMapController controller;

  final placemarks = <PlacemarkMapObject>[];
  final mapObjects = <MapObject>[];
  final placemarkIdToMapObjectId = <MapObjectId, MapObjectId?>{};
  final double interactivePolygonVisibilityThreshold;
  final double markersVisibilityThreshold;
  final double polygonsVisibilityThreshold;

  var visiblePlacemarks = <PlacemarkMapObject>[];
  var visibleObjects = <MapObject>[];

  bool areMarkersVisible = false;
  bool arePolygonsVisible = false;
  MapObjectId? selectedMapObjectId;
  MapObjectId? selectedPlacemarkId;
  LatLng? lastUserPosition;
  bool isCameraCenteredOnUser = false;

  IYandexMapState({
    this.interactivePolygonVisibilityThreshold =
        _interactivePolygonVisibilityThreshold,
    this.markersVisibilityThreshold = _markersVisibilityThreshold,
    this.polygonsVisibilityThreshold = _polygonsVisibilityThreshold,
  });
  late PlacemarkIcon _placemarkIcon;
  double get _devicePixelRatio => MediaQuery.of(context).devicePixelRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _placemarkIcon = generatePlacemarkIcon(
      selected: false,
      devicePixelRatio: _devicePixelRatio,
    );
  }

  @override
  Future<void> generateMarkers(List<MapObjectWithGeometry> objects) async {
    for (final obj in objects) {
      final mapObject = generateObject(obj);
      if (mapObject != null) {
        mapObjects.add(mapObject);
      }
      final placemark = PlacemarkMapObject(
        mapId: MapObjectId('${obj.id}_pin'),
        point: Point(
          latitude: obj.geometry.center.latitude,
          longitude: obj.geometry.center.longitude,
        ),
        consumeTapEvents: true,
        onTap: (placemark, _) => onMarkerTap(placemark),
        opacity: 1,
        // TODO: generate placemark
        icon: _placemarkIcon,
      );
      placemarks.add(placemark);
      placemarkIdToMapObjectId.putIfAbsent(
        placemark.mapId,
        () => mapObject?.mapId,
      );
    }
  }

  @override
  MapObject? generateObject(MapObjectWithGeometry mapObject) =>
      mapObject.geometry.mapOrNull<MapObject>(
        line: (line) => PolylineMapObject(
          mapId: MapObjectId('${mapObject.id}_line'),
          polyline: MapGeometryCreator.createPolyline(line.points),
          strokeWidth: 1,
          turnRadius: 0,
          strokeColor: PackageColors.strokeColor,
          onTap: (object, _) => onObjectTap(object),
        ),
        multiline: (multiline) => MapObjectCollection(
          mapId: MapObjectId('${mapObject.id}_multiline'),
          onTap: (object, _) => onObjectTap(object),
          mapObjects: multiline.lines
              .map(
                (e) => PolylineMapObject(
                  mapId: MapObjectId('${mapObject.id}_line_${e.hashCode}'),
                  polyline: MapGeometryCreator.createPolyline(e.points),
                  strokeWidth: 1,
                  turnRadius: 0,
                  strokeColor: PackageColors.strokeColor,
                ),
              )
              .toList(),
        ),
        polygon: (polygon) => PolygonMapObject(
          mapId: MapObjectId('${mapObject.id}_polygon'),
          polygon: MapGeometryCreator.createPolygon(
            polygon.outerRing,
            polygon.innerRings ?? [],
          ),
          strokeColor: PackageColors.strokeColor,
          fillColor: PackageColors.fillColor,
          onTap: (object, _) => onObjectTap(object),
        ),
        multipolygon: (multipolygon) => MapObjectCollection(
          mapId: MapObjectId('${mapObject.id}_multipolygon'),
          onTap: (object, _) => onObjectTap(object),
          mapObjects: multipolygon.polygons
              .map(
                (e) => PolygonMapObject(
                  mapId: MapObjectId('${mapObject.id}_polygon_${e.hashCode}'),
                  polygon: MapGeometryCreator.createPolygon(
                    e.outerRing,
                    e.innerRings ?? [],
                  ),
                  strokeColor: PackageColors.strokeColor,
                  fillColor: PackageColors.fillColor,
                ),
              )
              .toList(),
        ),
      );

  @override
  void deselectAll() {
    final placemark = placemarks
        .firstWhereOrNull((element) => element.mapId == selectedPlacemarkId);
    if (placemark != null) {
      _selectPlacemark(placemark);
    }
    final object = mapObjects
        .firstWhereOrNull((element) => element.mapId == selectedMapObjectId);
    if (object != null) {
      selectObject(object);
    }
    selectedMapObjectId = null;
    selectedPlacemarkId = null;
  }

  @override
  void onMarkerTap(PlacemarkMapObject marker) {
    if (selectedPlacemarkId == marker.mapId) return;

    selectedPlacemarkId = marker.mapId;
    _selectPlacemark(marker, selected: true);
    final mapObjectId = placemarkIdToMapObjectId[selectedPlacemarkId];
    final mapObject =
        mapObjects.firstWhereOrNull((element) => element.mapId == mapObjectId);
    if (mapObject != null && selectedMapObjectId != mapObjectId) {
      selectObject(mapObject, selected: true);
    }
    selectedMapObjectId = mapObjectId;
  }

  @override
  Future<void> onObjectTap(MapObject object) async {
    if ((await controller.getCameraPosition()).zoom <
        interactivePolygonVisibilityThreshold) return;
    if (selectedMapObjectId == object.mapId) return;

    selectedMapObjectId = object.mapId;
    selectObject(object, selected: true);
    final placemarkId = placemarkIdToMapObjectId.entries
        .firstWhereOrNull((element) => element.value == selectedMapObjectId)
        ?.key;
    final placemark =
        placemarks.firstWhereOrNull((element) => element.mapId == placemarkId);
    if (placemark != null && selectedPlacemarkId != placemarkId) {
      unawaited(_selectPlacemark(placemark, selected: true));
    }
    selectedPlacemarkId = placemarkId;
  }

  @override
  void selectObject(MapObject object, {bool selected = false}) {
    final objectIndex =
        mapObjects.indexWhere((element) => element.mapId == object.mapId);
    final visibleObjectIndex =
        visibleObjects.indexWhere((element) => element.mapId == object.mapId);
    if (objectIndex == -1) return;
    setState(() {
      late final MapObject newObject;
      if (object is MapObjectCollection) {
        newObject = object.copyWith(
          mapObjects: object.mapObjects
              .map(
                (e) => setAppearance(
                  mapObject: e,
                  selected: selected,
                  zIndex: selected ? 1.0 : 0.0,
                ),
              )
              .toList(),
        );
      } else {
        newObject = setAppearance(
          mapObject: object,
          selected: selected,
          zIndex: selected ? 1.0 : 0.0,
        );
      }
      mapObjects[objectIndex] = newObject;
      if (visibleObjectIndex != -1) {
        visibleObjects[visibleObjectIndex] = newObject;
      }
    });
  }

  @override
  Future<void> moveCameraToMatchBBox(BBox bbox) {
    // TODO: implement moveCameraToMatchBBox
    throw UnimplementedError();
  }

  @override
  Future<void> moveCameraToLocation(LatLng location) async {
    final zoom = (await controller.getCameraPosition()).zoom;
    unawaited(
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: location.latitude,
              longitude: location.longitude,
            ),
            zoom: max(interactivePolygonVisibilityThreshold, zoom),
          ),
        ),
        animation: const MapAnimation(duration: 1),
      ),
    );
  }

  @override
  Future<void> checkIfMarkersInBBox() async {
    final visibleRegion = await controller.getVisibleRegion();
    final box = visibleRegion.toBBox();
    final objectIds = <MapObjectId>{};
    final filteredPlacemarks = placemarks.where(
      (element) {
        final includes = box.includes(
          LatLng(
            latitude: element.point.latitude,
            longitude: element.point.longitude,
          ),
        );
        if (includes) {
          if (placemarkIdToMapObjectId[element.mapId] != null) {
            objectIds.add(placemarkIdToMapObjectId[element.mapId]!);
          }
          return true;
        }
        return false;
      },
    ).toList();

    final filteredMapObjects = mapObjects
        .where((element) => objectIds.contains(element.mapId))
        .toList();

    if (filteredPlacemarks != visiblePlacemarks ||
        filteredMapObjects != visibleObjects) {
      setState(() {
        visiblePlacemarks = filteredPlacemarks;
        visibleObjects = filteredMapObjects;
      });
    }
  }

  @override
  bool searchForObjectsInPoints(LatLng latLng) {
    //TODO: implemet
    throw UnimplementedError();
  }

  @override
  void resolveIfCameraCenteredOnPoint(LatLng center, LatLng? point) async {
    var isCentered = false;
    if (center.latitude.toStringAsFixed(4) ==
            point?.latitude.toStringAsFixed(4) &&
        center.longitude.toStringAsFixed(4) ==
            point?.longitude.toStringAsFixed(4)) {
      isCentered = true;
    }
    if (isCentered != isCameraCenteredOnUser) {
      setState(() {
        isCameraCenteredOnUser = isCentered;
      });
    }
  }

  @override
  void onCameraPositionChange(CameraPosition position) async {
    resolveIfCameraCenteredOnPoint(
      position.target.toLatLng(),
      lastUserPosition,
    );
    if (position.zoom < markersVisibilityThreshold) return;
    final visibleRegion = await controller.getVisibleRegion();
    final area = visibleRegion.toBBox();
    //TODO: place users onCameraPositionChange
  }

  Future<void> _selectPlacemark(
    PlacemarkMapObject placemark, {
    bool selected = false,
  }) async {
    final placemarkIndex =
        placemarks.indexWhere((element) => element.mapId == placemark.mapId);
    final visiblePlacemarkIndex = visiblePlacemarks
        .indexWhere((element) => element.mapId == placemark.mapId);
    if (selected) {
      final zoom = (await controller.getCameraPosition()).zoom;
      unawaited(
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: placemark.point,
              zoom: max(_interactivePolygonVisibilityThreshold, zoom),
            ),
          ),
          animation: const MapAnimation(),
        ),
      );
    }
    setState(() {
      final newPlacemark = setAppearance(
        mapObject: placemark,
        selected: selected,
        zIndex: selected ? 1.0 : 0.0,
      ) as PlacemarkMapObject;
      if (placemarkIndex != -1) {
        placemarks[placemarkIndex] = newPlacemark;
      }
      if (visiblePlacemarkIndex != -1) {
        visiblePlacemarks[visiblePlacemarkIndex] = newPlacemark;
      }
    });
  }

  Future<void> onCameraZoomChanged(CameraPosition position) async {
    final zoom = position.zoom;
    setState(() {
      if (zoom >= _markersVisibilityThreshold) {
        areMarkersVisible = true;
      } else {
        areMarkersVisible = false;
      }
      if (zoom >= polygonsVisibilityThreshold) {
        arePolygonsVisible = true;
      } else {
        arePolygonsVisible = false;
      }
    });
  }
}
