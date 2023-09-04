import 'dart:async';

import 'dart:ui' as ui;

import 'package:effective_map/src/models/styles/cluster_marker_style.dart';
import 'package:effective_map/src/models/styles/user_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

Future<Uint8List> drawUserLocation({
  required UserMarkerStyle style,
}) async {
  final size = Size(style.width * style.devicePixelRatio,
      style.height * style.devicePixelRatio);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final circleOffset = Offset(size.height / 2, size.width / 2);
  final fillPaint = Paint()
    ..color = style.fillColor
    ..style = PaintingStyle.fill;
  final strokePaint = Paint()
    ..color = style.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = style.borderWidth * style.devicePixelRatio;

  for (final shadow in style.userLocationShadow) {
    canvas.drawCircle(
      circleOffset.translate(shadow.offset.dx, shadow.offset.dy),
      style.shadowRadius * style.devicePixelRatio,
      shadow.toPaint(),
    );
  }

  canvas
    ..drawCircle(circleOffset, style.radius * style.devicePixelRatio, fillPaint)
    ..drawCircle(
        circleOffset, style.radius * style.devicePixelRatio, strokePaint);

  if (style.userMarkerViewPath != null) {
    final data = await rootBundle.load(style.userMarkerViewPath!);
    final image = await decodeImageFromList(data.buffer.asUint8List());

    canvas.drawImage(
      image,
      Offset(size.height / 2, size.width / 2),
      Paint(),
    );
  }

  final image = await recorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return pngBytes!.buffer.asUint8List();
}

Future<Uint8List> drawCluster(
  Cluster cluster, {
  required ClusterMarkerStyle style,
}) =>
    drawClusterWithCount(cluster.size, style: style);

Future<Uint8List> drawClusterWithCount(
  int count, {
  required ClusterMarkerStyle style,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(style.height * style.devicePixelRatio,
      style.width * style.devicePixelRatio);
  final circleOffset = Offset(size.height / 2, size.width / 2);
  final fillPaint = Paint()
    ..color = style.fillColor
    ..style = PaintingStyle.fill;
  final gradient = ui.Gradient.linear(
      Offset(circleOffset.dx, 0), circleOffset, style.gradientColors);
  final strokePaint = Paint()
    ..shader = gradient
    ..style = PaintingStyle.stroke
    ..strokeWidth = style.borderWidth * style.devicePixelRatio;
  final paintRadius = style.radius * style.devicePixelRatio;

  final clusterSizeAsString = count < 1000 ? count.toString() : '999+';

  final textPainter = TextPainter(
    text: TextSpan(
      text: clusterSizeAsString,
      style: style.countTextStyle,
    ),
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: size.width);

  final textOffset = Offset(
    (size.width - textPainter.width) / 2,
    (size.height - textPainter.height) / 2,
  );

  canvas
    ..drawCircle(circleOffset, paintRadius, fillPaint)
    ..drawCircle(circleOffset, paintRadius, strokePaint);
  textPainter.paint(canvas, textOffset);

  final image = await recorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return pngBytes!.buffer.asUint8List();
}
