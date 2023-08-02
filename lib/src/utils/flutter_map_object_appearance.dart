import 'package:effective_map/src/models/map_state/flutter_map_state.dart';
import 'package:effective_map/src/utils/osm_object_extension.dart';
import 'package:flutter_map/flutter_map.dart';

import '../common/package_colors.dart';
import '../models/map_object_wrappers/circle_wrapper.dart';
import '../models/map_object_wrappers/map_object.dart';
import '../models/map_object_wrappers/multi_polygon_wrapper.dart';
import '../models/map_object_wrappers/multi_polyline_wrapper.dart';
import '../models/map_object_wrappers/polygon_wrapper.dart';
import '../models/map_object_wrappers/polyline_wrapper.dart';

extension FlutterMapObjectAppearance on IFlutterMapState {
  MapObject setAppearance({
    required MapObject mapObject,
    bool selected = true,
  }) {
    if (mapObject is PolylineWrapper) {
      final newPolyline = mapObject.polyline.copyWith(
        color: selected
            ? PackageColors.selectedStrokeColor
            : PackageColors.strokeColor,
        strokeWidth: selected ? 3 : 2,
      );
      return mapObject.copyWith(polyline: newPolyline);
    }
    if (mapObject is PolygonWrapper) {
      final newPolygon = mapObject.polygon.copyWith(
        borderStrokeWidth: selected ? 3 : 2,
        color: selected
            ? PackageColors.selectedFillColor
            : PackageColors.fillColor,
        borderColor: selected
            ? PackageColors.selectedStrokeColor
            : PackageColors.strokeColor,
      );
      return mapObject.copyWith(polygon: newPolygon);
    }
    if (mapObject is MultiPolylineWrapper) {
      final newPolylines = <Polyline>[];
      for (final polyline in mapObject.polylines) {
        final newPolyline = polyline.copyWith(
          color: selected
              ? PackageColors.selectedStrokeColor
              : PackageColors.strokeColor,
          strokeWidth: selected ? 3 : 2,
        );
        newPolylines.add(newPolyline);
      }
      return mapObject.copyWith(polylines: newPolylines);
    }
    if (mapObject is MultiPolygonWrapper) {
      final newPolygons = <Polygon>[];
      for (final polygon in mapObject.polygons) {
        final newPolygon = polygon.copyWith(
          borderStrokeWidth: selected ? 3 : 2,
          color: selected
              ? PackageColors.selectedFillColor
              : PackageColors.fillColor,
          borderColor: selected
              ? PackageColors.selectedStrokeColor
              : PackageColors.strokeColor,
        );
        newPolygons.add(newPolygon);
      }
      return mapObject.copyWith(polygons: newPolygons);
    }
    if (mapObject is CircleWrapper) {
      final newCircle = mapObject.circle.copyWith(
        borderColor: selected
            ? PackageColors.selectedStrokeColor
            : PackageColors.strokeColor,
        color: selected
            ? PackageColors.selectedFillColor
            : PackageColors.fillColor,
        borderStrokeWidth: selected ? 3 : 2,
      );
      return mapObject.copyWith(circle: newCircle);
    }
    return mapObject;
  }
}
