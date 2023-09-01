import 'package:flutter/material.dart';

class ClusterWidget extends StatelessWidget {
  final int count;

  const ClusterWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) => Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(134, 136, 224, 1),
              Color.fromRGBO(83, 85, 169, 1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.85),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(color: Colors.black),
              ),
            ),
          ),
        ),
      );
}
