import 'package:flutter/material.dart';

@immutable
final class UserMarkerStyle {
  final double devicePixelRatio;
  final double width;
  final double height;
  final double borderWidth;
  final double radius;

  final double shadowRadius;
  final String? userMarkerViewPath;

  final List<BoxShadow> userLocationShadow;

  final Color fillColor;
  final Color borderColor;

  const UserMarkerStyle({
    double? devicePixelRatio,
    double? width,
    double? height,
    double? borderWidth,
    double? radius,
    double? shadowRadius,
    List<BoxShadow>? userLocationShadow,
    Color? fillColor,
    Color? borderColor,
    this.userMarkerViewPath,
  })  : devicePixelRatio = devicePixelRatio ?? 1,
        width = width ?? 40,
        height = height ?? 40,
        borderWidth = borderWidth ?? 4,
        radius = radius ?? 11,
        shadowRadius = shadowRadius ?? 12,
        userLocationShadow = userLocationShadow ?? _userLocationShadow,
        fillColor = fillColor ?? const Color.fromRGBO(52, 148, 241, 1),
        borderColor = borderColor ?? Colors.white;
}

const _userLocationShadow = <BoxShadow>[
  BoxShadow(
    offset: Offset.zero,
    color: Color.fromRGBO(52, 148, 241, 0.46),
    blurRadius: 16,
    spreadRadius: 6,
  ),
  BoxShadow(
    offset: Offset.zero,
    color: Color.fromRGBO(52, 148, 241, 1),
    blurRadius: 4.5,
    spreadRadius: 0,
  ),
];
