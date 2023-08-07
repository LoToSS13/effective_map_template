import 'dart:async';

import 'package:effective_map/src/models/effective_map_position.dart';
import 'package:effective_map/src/models/effective_marker.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';

import 'src/models/bbox.dart';

abstract class IMapState<O, Marker> {
  void onCameraPositionChanged(EffectiveMapPosition position, bool finished);

  void onMapTap(EffectiveLatLng latLng);
  void onClusterTap(BBox bbox);
  void onMarkerTap(Marker marker);
  Future<void> onObjectTap(O object);

  Future<void> moveCameraToMatchBBox(BBox bbox);
  Future<void> moveCameraToLocation(EffectiveLatLng location);

  void resolveIfCameraCenteredOnUser(EffectiveLatLng cameraPosition);

  O? convertObject(MapObjectWithGeometry mapObject, {bool selected = false});
  Marker? convertMarker(EffectiveMarker effectiveMarker,
      {bool selected = false});

  O? get selectedObject;
  Marker? get selectedMarker;
  bool get isCameraCentredOnUser;
  List<Marker> get markers;
  List<O> get objects;
}
