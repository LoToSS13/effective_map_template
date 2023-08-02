import 'dart:async';

import 'package:flutter/material.dart';

import '../bbox.dart';

import '../map_object_with_geometry.dart';

abstract class IMapState<Widget extends StatefulWidget, O, Marker, MapPosition,
    LatLng> extends State<Widget> with TickerProviderStateMixin {
  Future<void> generateMarkers(List<MapObjectWithGeometry> objects);
  O? generateObject(MapObjectWithGeometry mapObject);
  void deselectAll();
  void onMarkerTap(Marker marker);
  Future<void> onObjectTap(O object);
  void selectObject(O object, {bool selected = false});
  Future<void> moveCameraToMatchBBox(BBox bbox);
  Future<void> moveCameraToLocation(LatLng location);
  Future<void> checkIfMarkersInBBox();
  bool searchForObjectsInPoints(LatLng latLng);
  void resolveIfCameraCenteredOnPoint(LatLng center, LatLng? point);
  void onCameraPositionChange(MapPosition position);
}
