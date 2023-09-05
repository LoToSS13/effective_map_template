import 'package:effective_map/effective_map.dart';
import 'package:flutter/material.dart';

import 'package:effective_map/src/models/map_controller/map_controller.dart'
    as mc;

import 'package:effective_map/src/models/map_position.dart' as mp;

enum MapSample {
  yandex,
  flutter,
}

class EffectiveMap extends StatelessWidget {
  /// Using to choose map widget template
  ///
  /// For [MapSample.yandex] you can use only yandex background
  ///
  /// Also you have to provide yandex api key for using this sample
  final MapSample mapSample;

  /// Callback method for when user changes camera position
  final void Function(mp.MapPosition position, bool finished)?
      onCameraPositionChanged;

  /// Callback method for when user taps on map
  ///
  /// Use instead of [EffectiveMap.onObjectTap] for [MapSample.flutter] and handle it by received object position
  final void Function(LatLng latLng)? onMapTap;

  /// Callback method for when user taps on cluster
  final void Function(BBox bbox)? onClusterTap;

  /// Callback method for when user taps on marker
  final void Function(Marker marker)? onMarkerTap;

  /// Callback method for when user taps on object
  ///
  /// Works only for [MapSample.yandex]
  ///
  /// If needed in [MapSample.flutter] you have to use [EffectiveMap.onMapTap]
  final void Function(MapObjectWithGeometry object)? onObjectTap;

  /// Callback method for when the map is ready to be used.
  ///
  /// Pass to [EffectiveMap.onMapCreate] to receive a [MapController] when the
  ///
  /// map is created.
  final void Function(mc.MapController controller)? onMapCreate;

  /// Your tiles to show on map
  final List<NetworkTileProvider> tiles;

  /// Your layers to show on map
  final List<MapLayer> layers;

  /// URL for card background
  ///
  /// Needs only for [MapSample.flutter]
  ///
  ///[ MapSample.yandex] uses yandex background
  final String? urlTemplate;

  /// User agent package name
  ///
  /// Needs only for [MapSample.flutter]
  final String? userAgentPackageName;

  /// User position
  ///
  /// Needs only for [MapSample.flutter]
  ///
  /// [MapSample.yandex] gets user position itself, but you have to handle persmission
  final LatLng? userPosition;

  /// Maximum zoom when using [MapController.moveTo]
  final double? interactivePolygonVisibilityThreshold;

  /// Initial camera position
  final LatLng? initialCameraPosition;

  /// Min camera zoom
  ///
  /// Works only for [MapSample.flutter]
  final double? minCameraZoom;

  /// Max camera zoom
  ///
  /// Works only for [MapSample.flutter]
  final double? maxCameraZoom;

  /// Initial camera zoom
  final double? initialCameraZoom;

  /// Are tiles visible on map
  final bool? areTilesVisible;

  /// Are user position visible on map
  final bool? areUserPositionVisible;

  /// Customization of user marker object on map
  final UserMarkerStyle? userMarkerStyle;

  const EffectiveMap(
    this.mapSample, {
    this.tiles = const [],
    this.layers = const [],
    this.onMapCreate,
    this.onMapTap,
    this.onCameraPositionChanged,
    this.urlTemplate,
    this.onMarkerTap,
    this.initialCameraZoom,
    this.maxCameraZoom,
    this.minCameraZoom,
    this.userPosition,
    this.userMarkerStyle,
    this.userAgentPackageName,
    this.interactivePolygonVisibilityThreshold,
    this.initialCameraPosition,
    this.areTilesVisible,
    this.onClusterTap,
    this.areUserPositionVisible,
    this.onObjectTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => switch (mapSample) {
        MapSample.yandex => YandexMap(
            //Data
            tiles: tiles,
            layers: layers,

            //Functions
            onCameraPositionChanged: onCameraPositionChanged,
            onMapTap: onMapTap,
            onClusterTap: onClusterTap,
            onMarkerTap: onMarkerTap,
            onObjectTap: onObjectTap,
            onMapCreate: onMapCreate,

            //Customization
            interactivePolygonVisibilityThreshold:
                interactivePolygonVisibilityThreshold,
            userMarkerStyle: userMarkerStyle,
            initialCameraPosition: mp.MapPosition(
              center: initialCameraPosition,
              zoom: initialCameraZoom,
            ),

            //Flags
            areTilesVisible: areTilesVisible,
            areUserLocationVisible: areUserPositionVisible,
          ),
        MapSample.flutter => FlutterMap(
            //Data
            tiles: tiles,
            layers: layers,
            userAgentPackageName: userAgentPackageName,
            userPosition: userPosition,

            //Functions
            onCameraPositionChanged: onCameraPositionChanged,
            onMapTap: onMapTap,
            onClusterTap: onClusterTap,
            onMarkerTap: onMarkerTap,
            onMapCreate: onMapCreate,
            urlTemplate: urlTemplate,

            //Customization
            interactivePolygonVisibilityThreshold:
                interactivePolygonVisibilityThreshold,
            initialCameraPosition: initialCameraPosition,
            minCameraZoom: minCameraZoom,
            maxCameraZoom: maxCameraZoom,
            initialCameraZoom: initialCameraZoom,
            userMarkerStyle: userMarkerStyle,

            // Flags
            areTilesVisible: areTilesVisible,
            areUserPositionVisible: areUserPositionVisible,
          ),
      };
}
