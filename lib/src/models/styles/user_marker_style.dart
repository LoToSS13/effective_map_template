import 'package:flutter/material.dart';

@immutable
final class UserMarkerStyle {
  final double devicePixelRatio;
  final double width;
  final double height;
  final double borderWidth;
  final double radius;

  final double shadowRadius;

  final List<BoxShadow> activeUserLocationShadow;
  final List<BoxShadow> inactiveUserLocationShadow;
  final Color fillColor;
  final Color borderColor;

  const UserMarkerStyle({
    double? devicePixelRatio,
    double? width,
    double? height,
    double? borderWidth,
    double? radius,
    double? shadowRadius,
    List<BoxShadow>? activeUserLocationShadow,
    List<BoxShadow>? inactiveUserLocationShadow,
    Color? fillColor,
    Color? borderColor,
  })  : devicePixelRatio = devicePixelRatio ?? 1,
        width = width ?? 40,
        height = height ?? 40,
        borderWidth = borderWidth ?? 4,
        radius = radius ?? 11,
        shadowRadius = shadowRadius ?? 12,
        inactiveUserLocationShadow =
            inactiveUserLocationShadow ?? _inactiveUserLocationShadow,
        activeUserLocationShadow =
            activeUserLocationShadow ?? _activeUserLocationShadow,
        fillColor = fillColor ?? const Color.fromRGBO(52, 148, 241, 1),
        borderColor = borderColor ?? Colors.white;
}

const _inactiveUserLocationShadow = <BoxShadow>[
  BoxShadow(
    offset: Offset(0, 6),
    color: Color.fromRGBO(0, 28, 56, 0.08),
    blurRadius: 10,
    spreadRadius: 4,
  ),
  BoxShadow(
    offset: Offset(0, 2),
    color: Color.fromRGBO(0, 28, 56, 0.16),
    blurRadius: 3,
    spreadRadius: 0,
  ),
];

const _activeUserLocationShadow = <BoxShadow>[
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
