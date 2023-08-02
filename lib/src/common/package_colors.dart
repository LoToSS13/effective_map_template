import 'package:flutter/material.dart';

sealed class PackageColors {
  static const zoomRulerColor = Color(0xFF545F70);
  static const borderColor = Color(0xFFBBC7DB);

  static const strokeColor = Color.fromRGBO(108, 110, 196, 1);
  static const selectedStrokeColor = Color(0xFF3494F1);
  static const fillColor = Color.fromRGBO(192, 193, 255, 0.6);
  static final selectedFillColor = selectedStrokeColor.withOpacity(0.6);
}
