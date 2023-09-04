import 'package:effective_map/src/common/constants.dart';
import 'package:effective_map/src/models/styles/i_map_object_style.dart';
import 'package:flutter/material.dart';

@immutable
final class MarkerStyle implements IMapObjectStyle {
  final Offset offset;

  final String selectedMarkerViewPath;
  final String unselectedMarkerViewPath;

  final double devicePixelRatio;
  final double height;
  final double width;

  const MarkerStyle({
    Offset? offset,
    String? selectedMarkerViewPath,
    String? unselectedMarkerViewPath,
    String? markerViewPath,
    double? devicePixelRatio,
    double? height,
    double? width,
  })  : offset = offset ?? const Offset(0, 0),
        selectedMarkerViewPath =
            selectedMarkerViewPath ?? Constants.selectedPin,
        unselectedMarkerViewPath = selectedMarkerViewPath ?? Constants.pin,
        devicePixelRatio = devicePixelRatio ?? 1,
        height = height ?? 50,
        width = width ?? 50;
}
