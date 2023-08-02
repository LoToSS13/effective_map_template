import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../models/latlng.dart';

extension LatLngConverter on Point {
  LatLng toLatLng() => LatLng(
        latitude: latitude,
        longitude: longitude,
      );
}
