import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/models/map_object_geometry.dart';

const _coordOfZoomStep = 0.0004;

BBox createBBoxFrom(List<PointObjectGeometry> points) {
  if (points.isEmpty) throw ArgumentError('points can not be empty');
  final firstPoint = points.first;
  var eastest = firstPoint.center.latitude;
  var northest = firstPoint.center.longitude;
  var westest = firstPoint.center.latitude;
  var southest = firstPoint.center.longitude;
  for (final point in points) {
    if (point.center.latitude < eastest) {
      eastest = point.center.latitude;
    }
    if (point.center.longitude < northest) {
      northest = point.center.longitude;
    }
    if (point.center.latitude > westest) {
      westest = point.center.latitude;
    }
    if (point.center.longitude > southest) {
      southest = point.center.longitude;
    }
  }
  final box = BBox(
    upperCorner: LatLng(
      latitude: eastest - _coordOfZoomStep,
      longitude: northest - _coordOfZoomStep,
    ),
    lowerCorner: LatLng(
      latitude: westest + _coordOfZoomStep,
      longitude: southest + _coordOfZoomStep,
    ),
  );
  return box;
}
