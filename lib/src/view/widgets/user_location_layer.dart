import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:effective_map/src/common/constants.dart';
import 'package:effective_map/src/common/package_colors.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/utils/flutter_map_extension.dart';

const inactiveUserLocationShadow = <BoxShadow>[
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

const activeUserLocationShadow = <BoxShadow>[
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

class UserLocationLayer extends StatelessWidget {
  final EffectiveLatLng location;
  final bool isCenteredOnUser;

  const UserLocationLayer({
    super.key,
    required this.location,
    this.isCenteredOnUser = false,
  });

  @override
  Widget build(BuildContext context) => MarkerLayer(
        markers: [
          Marker(
            height: 26,
            width: 26,
            point: location.toLatLng(),
            builder: (context) => DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isCenteredOnUser
                    ? activeUserLocationShadow
                    : inactiveUserLocationShadow,
                border: !isCenteredOnUser
                    ? Border.all(
                        width: 1,
                        color: PackageColors.borderColor,
                      )
                    : null,
              ),
              child: Image.asset(
                Constants.userLocationAsset,
                fit: BoxFit.contain,
                height: 24,
                width: 24,
              ),
            ),
          ),
        ],
      );
}
