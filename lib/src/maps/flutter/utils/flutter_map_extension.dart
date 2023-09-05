import 'package:effective_map/src/models/map_position.dart' as mp;
import 'package:effective_map/src/models/marker.dart' as marker;
import 'package:effective_map/src/models/latlng.dart' as lat_lng;

import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

extension MapPositionConverter on MapPosition {
  mp.MapPosition toMapPosition() => mp.MapPosition(
        center: center?.toLatLng(),
        zoom: zoom,
      );
}

extension LatLngConverter on LatLng {
  lat_lng.LatLng toLatLng() =>
      lat_lng.LatLng(latitude: latitude, longitude: longitude);
}

extension PackageLatLngConverter on lat_lng.LatLng {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension FlutterMarkerConverter on Marker {
  marker.Marker toPackageMarker() =>
      marker.Marker(key: key, position: point.toLatLng());
}
