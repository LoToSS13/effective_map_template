import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:effective_map/src/utils/bbox_extension.dart';
import 'package:effective_map/src/utils/flutter_map_extension.dart';
import 'package:effective_map/src/utils/flutter_map_object_appearance.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

import '../../common/constants.dart';
import '../../common/package_colors.dart';
import '../bbox.dart';
import '../map_object_with_geometry.dart';
import '../map_object_wrappers/circle_wrapper.dart';
import '../map_object_wrappers/map_object.dart';
import '../map_object_wrappers/multi_polygon_wrapper.dart';
import '../map_object_wrappers/multi_polyline_wrapper.dart';
import '../map_object_wrappers/polygon_wrapper.dart';
import '../map_object_wrappers/polyline_wrapper.dart';

import 'i_map_state.dart';

const _markersVisibilityThreshold = 14.67;
const _interactivePolygonVisibilityThreshold = 17.3;

abstract class IFlutterMapState<Widget extends StatefulWidget>
    extends IMapState<Widget, MapObject, Marker, MapPosition, LatLng> {
  late final AnimatedMapController mapController =
      AnimatedMapController(vsync: this);
  final Map<Key, Object?> markerKeyToMapObjectId = {};
  final List<MapObject> mapObjects = [];

  final double interactivePolygonVisibilityThreshold;
  final double markersVisibilityThreshold;

  var markers = <Marker>[];
  var visibleMarkers = <Marker>[];
  var visibleObjects = <MapObject>[];

  LatLng? lastUserPosition;
  bool isCameraCenteredOnUser = false;
  bool areMarkersVisible = false;
  Marker? selectedMarker;
  MapObject? selectedMapObject;

  double currentZoom = 0;

  IFlutterMapState({
    this.interactivePolygonVisibilityThreshold =
        _interactivePolygonVisibilityThreshold,
    this.markersVisibilityThreshold = _markersVisibilityThreshold,
  });

  @override
  Future<void> checkIfMarkersInBBox() async {
    if (mapController.bounds == null) return;
    final objectIds = <Object>{};
    final bounds = mapController.bounds!;
    final filteredMarkers = markers.where(
      (marker) {
        if (bounds.contains(marker.point)) {
          if (markerKeyToMapObjectId[marker.key] != null) {
            objectIds.add(markerKeyToMapObjectId[marker.key]!);
          }
          return true;
        }
        return false;
      },
    ).toList();

    final filteredMapObjects =
        mapObjects.where((element) => objectIds.contains(element.id)).toList();

    if (visibleMarkers != filteredMarkers) {
      setState(() {
        visibleMarkers = filteredMarkers;
        visibleObjects = filteredMapObjects;
      });
    }
  }

  @override
  void deselectAll() {
    final object = mapObjects
        .firstWhereOrNull((element) => element.id == selectedMapObject?.id);
    if (object != null) {
      selectObject(object);
    }
    setState(() {
      if (selectedMapObject != null) {
        final notActiveMapObject =
            setAppearance(mapObject: selectedMapObject!, selected: false);
        mapObjects.add(notActiveMapObject);
        visibleObjects.add(notActiveMapObject);
        selectedMapObject = null;
      }
      if (selectedMarker != null) {
        markers = List.from([...markers, selectedMarker]);
        visibleMarkers = List.from([...visibleMarkers, selectedMarker]);
        selectedMarker = null;
      }
    });
  }

  @override
  MapObject? generateObject(MapObjectWithGeometry mapObject) =>
      mapObject.geometry.mapOrNull(
        point: (geometry) {
          final circle = CircleMarker(
            point: LatLng(geometry.center.latitude, geometry.center.longitude),
            radius: 4,
            borderStrokeWidth: 2,
            borderColor: PackageColors.strokeColor,
            color: PackageColors.fillColor,
          );
          return CircleWrapper(
            id: '${mapObject.id}_circle',
            circle: circle,
          );
        },
        line: (geometry) {
          final polyline = Polyline(
            points: geometry.points
                .map((e) => LatLng(e.center.latitude, e.center.longitude))
                .toList(),
            strokeWidth: 2,
            color: PackageColors.strokeColor,
          );
          return PolylineWrapper(
            id: '${mapObject.id}_polyline',
            polyline: polyline,
          );
        },
        multiline: (geometry) {
          final polylines = <Polyline>[];
          for (final lines in geometry.lines) {
            polylines.add(
              Polyline(
                points: lines.points
                    .map((e) => LatLng(e.center.latitude, e.center.longitude))
                    .toList(),
                strokeWidth: 2,
                color: PackageColors.strokeColor,
              ),
            );
          }
          return MultiPolylineWrapper(
            id: '${mapObject.id}_multiline',
            polylines: polylines,
          );
        },
        polygon: (geometry) {
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
            borderColor: PackageColors.strokeColor,
            borderStrokeWidth: 2,
            color: PackageColors.fillColor,
            isFilled: true,
          );
          return PolygonWrapper(
            id: '${mapObject.id}_polygon',
            polygon: polygon,
          );
        },
        multipolygon: (geometry) {
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
                borderColor: PackageColors.strokeColor,
                borderStrokeWidth: 2,
                color: PackageColors.fillColor,
                isFilled: true,
              ),
            );
          }
          return MultiPolygonWrapper(
            id: '${mapObject.id}_multipolygon',
            polygons: polygons,
          );
        },
      );

  @override
  Future<void> generateMarkers(List<MapObjectWithGeometry> objects) async {
    for (final obj in objects) {
      final key = ValueKey('${obj.id}_marker');
      final vectorObject = await Future(() => generateObject(obj));
      if (vectorObject != null) {
        mapObjects.add(vectorObject);
      }
      final marker = Marker(
        key: key,
        height: 56,
        width: 50,
        point:
            LatLng(obj.geometry.center.latitude, obj.geometry.center.longitude),
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (context) => Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            key == selectedMarker?.key ? Constants.selectedPin : Constants.pin,
          ),
        ),
      );
      markers.add(marker);
      markerKeyToMapObjectId.putIfAbsent(key, () => vectorObject?.id);
    }
    checkIfMarkersInBBox();
  }

  @override
  Future<void> moveCameraToLocation(LatLng location) async {
    await mapController.animateTo(
      dest: LatLng(location.latitude, location.longitude),
      zoom: max(interactivePolygonVisibilityThreshold, mapController.zoom),
    );
    checkIfMarkersInBBox();
  }

  @override
  Future<void> moveCameraToMatchBBox(BBox bbox) async {
    await mapController.animatedFitBounds(
      bbox.toBounds(),
      options: FitBoundsOptions(
        padding: const EdgeInsets.all(12),
        maxZoom: interactivePolygonVisibilityThreshold,
      ),
    );
    checkIfMarkersInBBox();
  }

  @override
  void onCameraPositionChange(MapPosition position) {
    if (position.center != null) {
      resolveIfCameraCenteredOnPoint(
        position.center!,
        lastUserPosition,
      );
    }
    if (position.zoom != null) {
      setState(() {
        areMarkersVisible = position.zoom! > markersVisibilityThreshold;
        currentZoom = position.zoom!;
      });
    }
  }

  @override
  void onMarkerTap(Marker marker) {
    if (selectedMarker?.key == marker.key) return;

    moveCameraToLocation(marker.point);
    markers = [...markers..remove(marker)];
    visibleMarkers = [...visibleMarkers..remove(marker)];
    selectedMarker = marker;
    final mapObjectId = markerKeyToMapObjectId[marker.key];
    final mapObject =
        mapObjects.firstWhereOrNull((element) => element.id == mapObjectId);
    if (mapObject != null) {
      moveCameraToMatchBBox(mapObject.bounds.toBBox());
      setState(() {
        mapObjects.remove(mapObject);
        visibleObjects.remove(mapObject);
        selectedMapObject = setAppearance(mapObject: mapObject, selected: true);
      });
    }
  }

  @override
  Future<void> onObjectTap(MapObject object) async {
    if (selectedMapObject?.id == object.id) return;

    mapObjects.remove(object);
    visibleObjects.remove(object);
    selectedMapObject = setAppearance(mapObject: object, selected: true);
    final markerId = markerKeyToMapObjectId.entries
        .firstWhereOrNull((element) => element.value == selectedMapObject?.id)
        ?.key;
    final marker = markers.firstWhere((marker) => marker.key == markerId);
    unawaited(moveCameraToMatchBBox(object.bounds.toBBox()));
    setState(() {
      selectedMarker = marker;
      markers = [...markers..remove(marker)];
      visibleMarkers = [...visibleMarkers..remove(marker)];
    });
  }

  @override
  void resolveIfCameraCenteredOnPoint(LatLng center, LatLng? point) {
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
  bool searchForObjectsInPoints(LatLng latLng) {
    if (!areMarkersVisible) return false;
    if (selectedMapObject?.bounds.contains(latLng) ?? false) {
      return true;
    }
    final object = visibleObjects.firstWhereOrNull((object) {
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
  void selectObject(MapObject object, {bool selected = false}) {
    final objectIndex =
        mapObjects.indexWhere((element) => element.id == object.id);
    final visibleObjectIndex =
        visibleObjects.indexWhere((element) => element.id == object.id);
    if (objectIndex == -1) return;
    setState(() {
      final newObject = setAppearance(mapObject: object, selected: selected);
      mapObjects[objectIndex] = newObject;
      if (visibleObjectIndex != -1) {
        visibleObjects[visibleObjectIndex] = newObject;
      }
    });
  }
}
