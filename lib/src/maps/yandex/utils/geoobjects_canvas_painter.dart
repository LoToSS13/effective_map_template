import 'dart:async';

import 'dart:ui' as ui;

import 'package:effective_map/src/models/styles/user_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

Future<Uint8List> drawUserLocation({
  required UserMarkerStyle style,
  String? userMarkerViewPath,
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

  for (final shadow in style.activeUserLocationShadow) {
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

  if (userMarkerViewPath != null) {
    final data = await rootBundle.load(userMarkerViewPath);
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
  double devicePixelRatio = 1.0,
}) =>
    drawClusterWithCount(cluster.size, devicePixelRatio: devicePixelRatio);

Future<Uint8List> drawClusterWithCount(
  int count, {
  double devicePixelRatio = 1.0,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size(60 * devicePixelRatio, 60 * devicePixelRatio);
  final circleOffset = Offset(size.height / 2, size.width / 2);
  final fillPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;
  final gradient =
      ui.Gradient.linear(Offset(circleOffset.dx, 0), circleOffset, const [
    Color.fromRGBO(134, 136, 224, 1),
    Color.fromRGBO(83, 85, 169, 1),
  ]);
  final strokePaint = Paint()
    ..shader = gradient
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.85 * devicePixelRatio;
  final radius = 19.0 * devicePixelRatio;

  final clusterSizeAsString = count < 1000 ? count.toString() : '999+';

  final textPainter = TextPainter(
    text: TextSpan(
      text: clusterSizeAsString,
      style: TextStyle(color: Colors.black, fontSize: 14 * devicePixelRatio),
    ),
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: size.width);

  final textOffset = Offset(
    (size.width - textPainter.width) / 2,
    (size.height - textPainter.height) / 2,
  );

  canvas
    ..drawCircle(circleOffset, radius, fillPaint)
    ..drawCircle(circleOffset, radius, strokePaint);
  textPainter.paint(canvas, textOffset);

  final image = await recorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

  return pngBytes!.buffer.asUint8List();
}
