import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../models/map_state/flutter_map_state.dart';
import '../../utils/cached_tile_provider.dart';
import '../widgets/any_map_object_layer.dart';
import '../widgets/cluster_widget.dart';
import '../widgets/user_location_layer.dart';

final _initialCameraPosition = LatLng(55.796391, 49.108891);
const _initialCameraZoom = 12.5;
const _maxCameraZoom = 19.0;
const _minCameraZoom = 3.0;

const _defaultTileTransition = TileDisplay.fadeIn(
  duration: Duration(milliseconds: 100),
);

const _clusterAnimationsDuration = Duration(milliseconds: 100);

class OSMMapPage extends StatefulWidget {
  static const routeName = '/osm-map-page';

  final double minCameraZoom;
  final double maxCameraZoom;
  final double initialCameraZoom;
  final LatLng initialCameraPosition;

  OSMMapPage({
    super.key,
    this.initialCameraZoom = _initialCameraZoom,
    this.maxCameraZoom = _maxCameraZoom,
    this.minCameraZoom = _minCameraZoom,
    LatLng? initialCameraPosition,
  }) : initialCameraPosition = initialCameraPosition ?? _initialCameraPosition;

  @override
  State<OSMMapPage> createState() => _OSMMapPageState();
}

class _OSMMapPageState extends IFlutterMapState<OSMMapPage> {
  @override
  Widget build(BuildContext context) => FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: _initialCameraPosition,
          zoom: _initialCameraZoom,
          minZoom: _minCameraZoom,
          maxZoom: _maxCameraZoom,
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.pinchMove,
          onPositionChanged: (position, hasGesture) {
            if (position.center != null) {
              resolveIfCameraCenteredOnPoint(
                  position.center!, lastUserPosition);
            }
            if (position.zoom != null) {
              setState(() {
                areMarkersVisible = position.zoom! > markersVisibilityThreshold;
                currentZoom = position.zoom!;
              });
            }
            //TODO: onPositionChange(MapPosition position)
          },
          onMapEvent: (event) {
            if (event.source == MapEventSource.dragEnd) {
              checkIfMarkersInBBox();
            }
          },
          onTap: (position, latLng) {
            final isFound = searchForObjectsInPoints(latLng);
            // TODO: onTap(bool isFound)
            if (!isFound) {
              deselectAll();
            }
          },
          onMapReady: () {
            //TODO: onMapReady
          },
        ),
        nonRotatedChildren: const [
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
            ],
          ),
        ],
        children: [
          TileLayer(
            // TODO: put url here
            urlTemplate: '',
            maxZoom: _maxCameraZoom,
            panBuffer: 3,
            tileDisplay: _defaultTileTransition,
            subdomains: const ['a', 'b', 'c'],
            // TODO: put package name here
            userAgentPackageName: '',
            tileProvider: CachedTileProvider(),
          ),
          // TODO: put check here
          if ((markers.isEmpty || !areMarkersVisible))
            TileLayer(
              //TODO: put url here
              urlTemplate: '',
              maxZoom: _maxCameraZoom,
              panBuffer: 3,
              backgroundColor: Colors.transparent,
              zoomOffset: 1,
              tileProvider: CachedTileProvider(
                  // TODO: put headers here

                  ),
              userAgentPackageName: 'com.gemsdev.sodalite',
            ),
          if (areMarkersVisible) AnyMapObjectLayer(mapObjects: visibleObjects),
          if (selectedMapObject != null)
            AnyMapObjectLayer(
              mapObjects: [selectedMapObject!],
            ),
          if (visibleMarkers.isNotEmpty && areMarkersVisible)
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                size: const Size(38, 38),
                maxClusterRadius: 80,
                disableClusteringAtZoom: 18,
                markers: visibleMarkers,
                animationsOptions: const AnimationsOptions(
                  zoom: _clusterAnimationsDuration,
                  fitBound: _clusterAnimationsDuration,
                  centerMarker: _clusterAnimationsDuration,
                  spiderfy: _clusterAnimationsDuration,
                ),
                spiderfyCluster: false,
                zoomToBoundsOnClick: false,
                centerMarkerOnClick: false,
                onClusterTap: (clusterNode) {
                  mapController.animatedFitBounds(
                    clusterNode.bounds,
                    options: const FitBoundsOptions(
                      padding: EdgeInsets.all(12),
                      maxZoom: _maxCameraZoom,
                    ),
                  );
                },
                onMarkerTap: onMarkerTap,
                builder: (
                  BuildContext context,
                  List<Marker> markers,
                ) =>
                    ClusterWidget(count: markers.length),
              ),
            ),
          if (selectedMarker != null)
            GestureDetector(
              onTap: () => onMarkerTap(
                selectedMarker!,
              ),
              child: MarkerLayer(markers: [selectedMarker!]),
            ),
          if (lastUserPosition != null)
            UserLocationLayer(
              location: lastUserPosition!,
              isCenteredOnUser: isCameraCenteredOnUser,
            ),
        ],
      );
}
