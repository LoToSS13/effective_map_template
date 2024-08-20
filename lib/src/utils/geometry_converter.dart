import 'dart:math' as math;

double get pi => math.pi;

const double degrees2Radians = math.pi / 180.0;

double radianToDeg(final double rad) => rad * (180.0 / pi);

double degToRadian(final double deg) => deg * (pi / 180.0);
