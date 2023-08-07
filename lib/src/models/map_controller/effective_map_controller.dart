import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_latlng.dart';

abstract class EffectiveMapController {
  Future<double> get zoom;
  Future<BBox?> get bbox;

  Future<void> zoomIn();
  Future<void> zoomOut();
  Future<void> zoomFitBBox(BBox bbox);
  Future<void> moveTo(EffectiveLatLng latlng);
}
