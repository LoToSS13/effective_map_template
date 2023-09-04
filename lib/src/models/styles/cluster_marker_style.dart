import 'package:effective_map/src/models/styles/i_map_object_style.dart';
import 'package:effective_map/src/models/styles/marker_style.dart';
import 'package:flutter/material.dart';

@immutable
final class ClusterMarkerStyle implements IMapObjectStyle {
  final double devicePixelRatio;
  final double height;
  final double width;
  final double radius;
  final double borderWidth;
  final Color fillColor;
  final List<Color> gradientColors;
  final TextStyle? countTextStyle;
  final MarkerStyle markerStyle;

  const ClusterMarkerStyle({
    double? devicePixelRatio,
    double? height,
    double? width,
    Color? fillColor,
    List<Color>? gradientColors,
    double? borderWidth,
    double? radius,
    MarkerStyle? markerStyle,
    this.countTextStyle,
  })  : devicePixelRatio = devicePixelRatio ?? 1,
        height = height ?? 60,
        width = width ?? 60,
        fillColor = fillColor ?? const Color(0xFFFFFFFF),
        gradientColors = gradientColors ??
            const [
              Color.fromRGBO(134, 136, 224, 1),
              Color.fromRGBO(83, 85, 169, 1),
            ],
        borderWidth = borderWidth ?? 2.85,
        radius = radius ?? 19,
        markerStyle = markerStyle ?? const MarkerStyle();
}
