import 'package:effective_map/src/models/effective_map_position.dart';
import 'package:effective_map/src/models/effective_marker.dart';
import 'package:effective_map/src/models/effective_latlng.dart';

import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

extension EffectiveMapPositionConverter on MapPosition {
  EffectiveMapPosition toEffectiveMapPosition() => EffectiveMapPosition(
        center: center?.toEffectiveLatLng(),
        zoom: zoom,
      );
}

extension LatLngConverter on LatLng {
  EffectiveLatLng toEffectiveLatLng() =>
      EffectiveLatLng(latitude: latitude, longitude: longitude);
}

extension EffectiveLatLngConverter on EffectiveLatLng {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension FlutterMarkerConverter on Marker {
  EffectiveMarker toEffectiveMarker() =>
      EffectiveMarker(key: key, position: point.toEffectiveLatLng());
}
