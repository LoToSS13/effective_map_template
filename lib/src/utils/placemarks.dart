import 'dart:math';
import 'dart:ui';

import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../common/constants.dart';

PlacemarkIcon generatePlacemarkIcon({
  required bool selected,
  double devicePixelRatio = 1.0,
}) =>
    PlacemarkIcon.single(
      PlacemarkIconStyle(
        anchor: const Offset(0.5, 1),
        image: BitmapDescriptor.fromAssetImage(
          selected ? Constants.selectedPin : Constants.pin,
        ),
        scale: min(devicePixelRatio / 3, 3),
      ),
    );
