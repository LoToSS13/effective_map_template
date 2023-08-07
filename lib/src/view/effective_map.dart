import 'package:effective_map/src/models/effective_marker.dart';
import 'package:effective_map/src/models/effective_network_tiles_provider.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_controller/effective_map_controller.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';
import 'package:effective_map/src/view/osm_map.dart';
import 'package:effective_map/src/view/yandex_map.dart';
import 'package:flutter/material.dart';

import 'package:effective_map/src/models/effective_map_position.dart';

enum MapSamples {
  yandex,
  osm,
}

class EffectiveMap extends StatelessWidget {
  final MapSamples mapSample;

  final void Function(EffectiveMapPosition position, bool finished)?
      onCameraPositionChanged;
  final void Function(EffectiveLatLng latLng)? onMapTap;
  final void Function(EffectiveMarker marker)? onMarkerTap;
  final void Function(MapObjectWithGeometry object)? onObjectTap;
  final void Function(EffectiveMapController controller)? onMapCreate;
  final void Function(bool isCentred)? isCameraCentredOnUserCallback;
  final void Function()? checkVisibleObjects;

  final List<EffectiveNetworkTileProvider> tiles;
  final List<EffectiveMarker> markers;
  final List<MapObjectWithGeometry> objects;

  final EffectiveMarker? selectedMarker;
  final MapObjectWithGeometry? selectedObject;

  final String? urlTemplate;
  final String? userAgentPackageName;
  final EffectiveLatLng? userPosition;

  final double? interactivePolygonVisibilityThreshold;
  final EffectiveLatLng? initialCameraPosition;
  final double? minCameraZoom;
  final double? maxCameraZoom;
  final double? initialCameraZoom;
  final bool? areMarkersVisible;

  final Image? selectedMarkerView;
  final Widget? unselectedMarkerView;

  final Color? selectedStrokeColor;
  final Color? unselectedStrokeColor;
  final Color? selectedFillColor;
  final Color? unselectedFillColor;

  const EffectiveMap({
    super.key,
    required this.mapSample,
    this.markers = const [],
    this.tiles = const [],
    this.objects = const [],
    this.onMapCreate,
    this.onMapTap,
    this.onCameraPositionChanged,
    this.urlTemplate,
    this.selectedMarker,
    this.selectedObject,
    this.onMarkerTap,
    this.onObjectTap,
    this.isCameraCentredOnUserCallback,
    this.initialCameraZoom,
    this.maxCameraZoom,
    this.minCameraZoom,
    this.userPosition,
    this.checkVisibleObjects,
    this.selectedMarkerView,
    this.unselectedMarkerView,
    this.selectedStrokeColor,
    this.unselectedStrokeColor,
    this.selectedFillColor,
    this.unselectedFillColor,
    this.areMarkersVisible,
    this.userAgentPackageName,
    this.interactivePolygonVisibilityThreshold,
    this.initialCameraPosition,
  });

  @override
  Widget build(BuildContext context) => switch (mapSample) {
        MapSamples.yandex => YandexEffectiveMap(
            // Data
            tiles: tiles,
            urlTemplate: urlTemplate,
            userAgentPackageName: userAgentPackageName,
            markers: markers,
            objects: objects,
            selectedMarker: selectedMarker,
            selectedObject: selectedObject,
            userPosition: userPosition,
            areMarkersVisible: areMarkersVisible,
            // Functions
            onMarkerTap: onMarkerTap,
            onObjectTap: onObjectTap,
            onMapTap: onMapTap,
            onCameraPositionChanged: onCameraPositionChanged,
            onMapCreate: onMapCreate,
            isCameraCentredOnUserCallback: isCameraCentredOnUserCallback,
            checkVisibleObjects: checkVisibleObjects,
            // Customization
            selectedMarkerView: selectedMarkerView,
            unselectedMarkerView: unselectedMarkerView,
            initialCameraZoom: initialCameraZoom,

            selectedStrokeColor: selectedStrokeColor,
            unselectedStrokeColor: unselectedStrokeColor,
            selectedFillColor: selectedFillColor,
            unselectedFillColor: unselectedFillColor,
            interactivePolygonVisibilityThreshold:
                interactivePolygonVisibilityThreshold,
            initialCameraPosition: EffectiveMapPosition(
              center: initialCameraPosition,
              zoom: initialCameraZoom,
            ),
          ),
        MapSamples.osm => OSMEffectiveMap(
            // Data
            tiles: tiles,
            urlTemplate: urlTemplate,
            userAgentPackageName: userAgentPackageName,
            markers: markers,
            objects: objects,
            selectedMarker: selectedMarker,
            selectedObject: selectedObject,
            userPosition: userPosition,
            areMarkersVisible: areMarkersVisible,
            // Functions
            onMarkerTap: onMarkerTap,
            onObjectTap: onObjectTap,
            onMapTap: onMapTap,
            onCameraPositionChanged: onCameraPositionChanged,
            onMapCreate: onMapCreate,
            isCameraCentredOnUserCallback: isCameraCentredOnUserCallback,
            checkVisibleObjects: checkVisibleObjects,
            // Customization
            selectedMarkerView: selectedMarkerView,
            unselectedMarkerView: unselectedMarkerView,
            initialCameraZoom: initialCameraZoom,
            maxCameraZoom: maxCameraZoom,
            minCameraZoom: minCameraZoom,
            selectedStrokeColor: selectedStrokeColor,
            unselectedStrokeColor: unselectedStrokeColor,
            selectedFillColor: selectedFillColor,
            unselectedFillColor: unselectedFillColor,
            interactivePolygonVisibilityThreshold:
                interactivePolygonVisibilityThreshold,
            initialCameraPosition: initialCameraPosition,
          ),
      };
}
