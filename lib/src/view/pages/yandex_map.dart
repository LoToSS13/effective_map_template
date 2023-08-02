import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../../models/map_state/yandex_map_state.dart';
import '../../utils/bounding_box_former.dart';
import '../../utils/geoobjects_canvas_painter.dart';

const _initialCameraPosition = CameraPosition(
  target: Point(latitude: 55.796391, longitude: 49.108891),
  zoom: _initialCameraZoom,
);
const _initialCameraZoom = 12.5;

class YandexEffectiveMap extends StatefulWidget {
  final double initialCameraZoom;
  final CameraPosition initialCameraPosition;
  const YandexEffectiveMap({
    super.key,
    this.initialCameraZoom = _initialCameraZoom,
    CameraPosition? initialCameraPosition,
  }) : initialCameraPosition = initialCameraPosition ?? _initialCameraPosition;

  @override
  State<YandexEffectiveMap> createState() => _YandexEffectiveMapState();
}

class _YandexEffectiveMapState extends IYandexMapState<YandexEffectiveMap> {
  @override
  Widget build(BuildContext context) => YandexMap(
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        mode2DEnabled: true,
        //TODO: place tiles here
        tiles: !areMarkersVisible || placemarks.isEmpty ? [] : [],
        onUserLocationAdded: (userLocationView) async =>
            userLocationView.copyWith(
          pin: userLocationView.pin.copyWith(
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(
                  await drawUserLocation(
                    devicePixelRatio: _devicePixelRatio,
                  ),
                ),
                scale: 1,
              ),
            ),
          ),
          arrow: userLocationView.arrow.copyWith(
            opacity: 1,
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(
                  await drawUserLocation(
                    devicePixelRatio: _devicePixelRatio,
                  ),
                ),
                scale: 1,
              ),
            ),
          ),
          accuracyCircle: userLocationView.accuracyCircle.copyWith(
            isVisible: false,
            fillColor: Colors.transparent,
            strokeColor: Colors.transparent,
          ),
        ),
        onMapCreated: (controller) {
          controller = controller;
          controller
            ..moveCamera(
              CameraUpdate.newCameraPosition(
                widget.initialCameraPosition,
              ),
            )
            ..toggleUserLayer(visible: true);
          //TODO:  on map Created
        },
        onMapTap: (_) {
          //TODO: on MapTap
          deselectAll();
        },
        mapObjects: [
          if (areMarkersVisible)
            ClusterizedPlacemarkCollection(
              mapId: const MapObjectId('excavation_cluster'),
              placemarks: visiblePlacemarks,
              radius: 30,
              minZoom: 18,
              onClusterAdded: (self, cluster) async => cluster.copyWith(
                appearance: cluster.appearance.copyWith(
                  opacity: 1,
                  icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                      image: BitmapDescriptor.fromBytes(
                        await drawCluster(
                          cluster,
                          devicePixelRatio: _devicePixelRatio,
                        ),
                      ),
                      scale: 1,
                    ),
                  ),
                ),
              ),
              onClusterTap: (self, cluster) {
                final box = createPaddedBoundingBoxFrom(
                  cluster.placemarks.map((e) => e.point).toList(),
                );
                controller.moveCamera(
                  CameraUpdate.newBounds(box),
                  animation: const MapAnimation(duration: 1),
                );
              },
            ),
          if (arePolygonsVisible) ...visibleObjects,
        ],
        onCameraPositionChanged: (position, reason, finished) {
          onCameraZoomChanged(position);
          if (finished) {
            checkIfMarkersInBBox();
            onCameraPositionChange(position);
          }
        },
      );

  double get _devicePixelRatio => MediaQuery.of(context).devicePixelRatio;
}
