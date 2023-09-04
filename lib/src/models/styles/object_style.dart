import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/models/styles/i_map_object_style.dart';
import 'package:flutter/material.dart';

@immutable
final class ObjectStyle implements IMapObjectStyle {
  final Color selectedStrokeColor;
  final Color unselectedStrokeColor;
  final Color selectedFillColor;
  final Color unselectedFillColor;
  final double pointRadius;
  final double strokeWidth;

  const ObjectStyle(
      {Color? selectedStrokeColor,
      Color? unselectedStrokeColor,
      Color? selectedFillColor,
      Color? unselectedFillColor,
      double? pointRadius,
      double? borderWidth})
      : selectedStrokeColor =
            selectedStrokeColor ?? PackageColors.selectedStrokeColor,
        unselectedStrokeColor =
            unselectedStrokeColor ?? PackageColors.strokeColor,
        selectedFillColor =
            selectedFillColor ?? PackageColors.selectedStrokeColor,
        unselectedFillColor = unselectedFillColor ?? PackageColors.fillColor,
        pointRadius = pointRadius ?? 4,
        strokeWidth = borderWidth ?? 2;
}
