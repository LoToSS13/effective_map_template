import 'package:effective_map/src/models/styles/user_marker_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/maps/flutter/utils/flutter_map_extension.dart';

class UserLocationLayer extends StatelessWidget {
  final LatLng location;

  final UserMarkerStyle style;

  const UserLocationLayer({
    super.key,
    required this.location,
    required this.style,
  });

  @override
  Widget build(BuildContext context) => MarkerLayer(
        markers: [
          Marker(
            height: style.height * style.devicePixelRatio,
            width: style.width * style.devicePixelRatio,
            point: location.toLatLng(),
            builder: (context) => Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              height: style.radius * 2 * style.devicePixelRatio,
              width: style.radius * 2 * style.devicePixelRatio,
              decoration: BoxDecoration(
                color: style.fillColor,
                shape: BoxShape.circle,
                boxShadow: style.userLocationShadow,
                border: Border.all(
                  width: style.borderWidth * style.devicePixelRatio,
                  color: style.borderColor,
                ),
              ),
              child: style.userMarkerViewPath != null
                  ? Image.asset(
                      style.userMarkerViewPath!,
                      fit: BoxFit.contain,
                      height: style.radius * 2 * style.devicePixelRatio,
                      width: style.radius * 2 * style.devicePixelRatio,
                    )
                  : SizedBox(
                      height: style.radius * 2 * style.devicePixelRatio,
                      width: style.radius * 2 * style.devicePixelRatio,
                    ),
            ),
          ),
        ],
      );
}
