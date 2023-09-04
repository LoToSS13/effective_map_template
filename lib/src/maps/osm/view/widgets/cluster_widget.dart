import 'package:effective_map/src/models/styles/cluster_marker_style.dart';
import 'package:flutter/material.dart';

class ClusterWidget extends StatelessWidget {
  final int count;
  final ClusterMarkerStyle style;

  const ClusterWidget({super.key, required this.count, required this.style});

  @override
  Widget build(BuildContext context) => Container(
        height: style.height * style.devicePixelRatio,
        width: style.width * style.devicePixelRatio,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.radius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: style.gradientColors,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(style.borderWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(style.radius),
              color: style.fillColor,
            ),
            child: Center(
              child: SizedBox(
                height: style.radius * style.devicePixelRatio,
                width: style.radius * style.devicePixelRatio,
                child: Text(
                  count.toString(),
                  style: style.countTextStyle,
                ),
              ),
            ),
          ),
        ),
      );
}
