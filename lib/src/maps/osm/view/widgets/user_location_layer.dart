import 'package:effective_map/src/models/styles/user_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/maps/osm/utils/flutter_map_extension.dart';

class UserLocationLayer extends StatelessWidget {
  final LatLng location;
  final bool isCenteredOnUser;
  final String? userMarkerViewPath;
  final UserMarkerStyle style;

  const UserLocationLayer({
    super.key,
    required this.location,
    required this.style,
    this.isCenteredOnUser = false,
    this.userMarkerViewPath,
  });

  @override
  Widget build(BuildContext context) => MarkerLayer(
        markers: [
          Marker(
            height: style.height * style.devicePixelRatio,
            width: style.width + style.borderWidth * style.devicePixelRatio,
            point: location.toLatLng(),
            builder: (context) => DecoratedBox(
                decoration: BoxDecoration(
                  color: style.fillColor,
                  shape: BoxShape.circle,
                  boxShadow: isCenteredOnUser
                      ? style.activeUserLocationShadow
                      : style.inactiveUserLocationShadow,
                  border: !isCenteredOnUser
                      ? Border.all(
                          width: style.borderWidth * style.devicePixelRatio,
                          color: style.borderColor,
                        )
                      : null,
                ),
                child: SizedBox(
                  height: style.shadowRadius * 2 * style.devicePixelRatio,
                  width: style.shadowRadius * 2 * style.devicePixelRatio,
                  child: userMarkerViewPath != null
                      ? Image.asset(
                          userMarkerViewPath!,
                          fit: BoxFit.contain,
                          height: style.radius * 2 * style.devicePixelRatio,
                          width: style.radius * 2 * style.devicePixelRatio,
                        )
                      : SizedBox(
                          height: style.radius * 2 * style.devicePixelRatio,
                          width: style.radius * 2 * style.devicePixelRatio,
                        ),
                )),
          ),
        ],
      );
}
