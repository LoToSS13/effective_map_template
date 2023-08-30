import 'dart:async';

import 'package:effective_map/src/models/map_position.dart';
import 'package:effective_map/src/models/marker.dart' as marker;
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';

import 'package:effective_map/src/models/bbox.dart';

abstract class IMapState<O, Marker> {
  void onCameraPositionChanged(MapPosition position, bool finished);

  void onMapTap(LatLng latLng);
  void onClusterTap(BBox bbox);
  void onMarkerTap(Marker marker);
  Future<void> onObjectTap(O object);

  Future<void> moveCameraToMatchBBox(BBox bbox);
  Future<void> moveCameraToLocation(LatLng location);

  void resolveIfCameraCenteredOnUser(LatLng cameraPosition);

  O? convertObject(MapObjectWithGeometry mapObject, {bool selected = false});
  Marker? convertMarker(marker.Marker effectiveMarker, {bool selected = false});

  O? get selectedObject;
  Marker? get selectedMarker;
  bool get isCameraCentredOnUser;
  List<Marker> get markers;
  List<O> get objects;
}
