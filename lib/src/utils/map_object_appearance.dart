import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/utils/placemarks.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../models/map_state/yandex_map_state.dart';

extension MapObjectAppearance on IYandexMapState {
  MapObject setAppearance({
    required MapObject mapObject,
    double zIndex = 0.0,
    bool selected = false,
  }) {
    if (mapObject is PlacemarkMapObject) {
      return mapObject.copyWith(
        zIndex: zIndex,
        icon: selected
            ? generatePlacemarkIcon(
                selected: true,
                devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
              )
            : generatePlacemarkIcon(
                selected: false,
                devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
              ),
      );
    }
    if (mapObject is PolylineMapObject) {
      return mapObject.copyWith(
        zIndex: zIndex,
        strokeColor: selected
            ? PackageColors.selectedStrokeColor
            : PackageColors.strokeColor,
        strokeWidth: selected ? 2 : 1,
      );
    }
    if (mapObject is PolygonMapObject) {
      return mapObject.copyWith(
        zIndex: zIndex,
        strokeColor: selected
            ? PackageColors.selectedStrokeColor
            : PackageColors.strokeColor,
        fillColor: selected
            ? PackageColors.selectedFillColor
            : PackageColors.fillColor,
        strokeWidth: selected ? 2 : 1,
      );
    }
    return mapObject;
  }
}
