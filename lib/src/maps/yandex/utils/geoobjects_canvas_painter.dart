import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

Future<Uint8List> drawUserLocation({
  bool isActive = false,
  double devicePixelRatio = 1.0,
}) async {
  final size = Size(40 * devicePixelRatio, 40 * devicePixelRatio);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final circleOffset = Offset(size.height / 2, size.width / 2);
  final fillPaint = Paint()
    ..color = const Color.fromRGBO(52, 148, 241, 1)
    ..style = PaintingStyle.fill;
  final strokePaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4 * devicePixelRatio;

  for (final shadow
      in isActive ? _activeUserLocationShadow : _inactiveUserLocationShadow) {
    canvas.drawCircle(
      circleOffset.translate(shadow.offset.dx, shadow.offset.dy),
      isActive ? 12 * devicePixelRatio : 13 * devicePixelRatio,
      shadow.toPaint(),
    );
  }

  canvas
    ..drawCircle(circleOffset, 11 * devicePixelRatio, fillPaint)
    ..drawCircle(circleOffset, 11 * devicePixelRatio, strokePaint);

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
