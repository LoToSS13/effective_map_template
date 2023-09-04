import 'package:flutter/material.dart';

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/map_layer.dart';
import 'package:effective_map/src/models/map_position.dart';
import 'package:effective_map/src/models/marker.dart';
import 'package:effective_map/src/models/network_tiles_provider.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/models/map_controller/map_controller.dart';
import 'package:effective_map/src/maps/yandex/map_controller/yandex_map_controller.dart';
import 'package:effective_map/src/models/map_object_with_geometry.dart';
import 'package:effective_map/src/maps/i_map_state.dart';
import 'package:effective_map/src/maps/yandex/utils/bbox_extension.dart';
import 'package:effective_map/src/maps/yandex/utils/bounding_box_former.dart';
import 'package:effective_map/src/maps/yandex/utils/geoobjects_canvas_painter.dart';
import 'package:effective_map/src/maps/yandex/utils/map_geometry_creator.dart';
import 'package:effective_map/src/maps/yandex/utils/placemarks.dart';
import 'package:effective_map/src/maps/yandex/utils/yandex_map_extension.dart';
import 'package:effective_map/src/models/styles/marker_style.dart';
import 'package:effective_map/src/models/styles/object_style.dart';
import 'package:effective_map/src/models/styles/user_marker_style.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart' as yandex;

const _initialCameraPosition = MapPosition(
  center: LatLng(latitude: 55.796391, longitude: 49.108891),
  zoom: _initialCameraZoom,
);

const _initialCameraZoom = 12.5;
const _interactivePolygonVisibilityThreshold = 17.3;

class YandexMap extends StatefulWidget {
  final void Function(MapPosition position, bool finished)?
      onCameraPositionChanged;
  final void Function(LatLng latLng)? onMapTap;
  final void Function(BBox bbox)? onClusterTap;
  final void Function(Marker marker)? onMarkerTap;
  final void Function(MapObjectWithGeometry object)? onObjectTap;
  final void Function(MapController controller)? onMapCreate;

  final List<NetworkTileProvider> tiles;
  final List<MapLayer> layers;

  final double interactivePolygonVisibilityThreshold;
  final MapPosition initialCameraPosition;

  final bool areTilesVisible;
  final bool areUserLocationVisible;

  final UserMarkerStyle userMarkerStyle;

  const YandexMap({
    super.key,
    required this.tiles,
    required this.layers,
    this.onMapTap,
    this.onCameraPositionChanged,
    this.onMarkerTap,
    this.onObjectTap,
    this.onClusterTap,
    this.onMapCreate,
    UserMarkerStyle? userMarkerStyle,
    bool? areTilesVisible,
    bool? areUserLocationVisible,
    double? interactivePolygonVisibilityThreshold,
    MapPosition? initialCameraPosition,
  })  : areTilesVisible = areTilesVisible ?? false,
        areUserLocationVisible = areUserLocationVisible ?? false,
        interactivePolygonVisibilityThreshold =
            interactivePolygonVisibilityThreshold ??
                _interactivePolygonVisibilityThreshold,
        initialCameraPosition = initialCameraPosition ?? _initialCameraPosition,
        userMarkerStyle = userMarkerStyle ?? const UserMarkerStyle();

  @override
  State<YandexMap> createState() => _YandexMapState();
}

class _YandexMapState extends State<YandexMap>
    implements
        IMapState<yandex.MapObject<dynamic>, yandex.PlacemarkMapObject,
            yandex.MapObject<dynamic>> {
  late final yandex.YandexMapController _mapController;

  late final List<yandex.MapObject<dynamic>> _layers = [];

  @override
  List<yandex.MapObject<dynamic>> get layers => _layers;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    for (final layer in widget.layers) {
      final widget = convertLayer(layer);
      if (widget != null) {
        _layers.add(widget);
      }
    }
  }

  @override
  yandex.MapObject? convertLayer(MapLayer layer) {
    return layer.mapOrNull<yandex.MapObject?>(
      mapObjectLayer: (layer) {
        final List<yandex.MapObject> objects = [];
        for (final object in layer.objects) {
          final yandexObject = convertObject(object, layer.style);
          if (yandexObject != null) {
            objects.add(yandexObject);
          }
        }

        return yandex.MapObjectCollection(
          mapId: yandex.MapObjectId('map_objects_${objects.hashCode}'),
          mapObjects: objects,
        );
      },
      markerLayer: (layer) {
        final List<yandex.PlacemarkMapObject> markers = [];
        for (final object in layer.objects) {
          final yandexObject = convertMarker(object, layer.style);
          if (yandexObject != null) {
            markers.add(yandexObject);
          }
        }
        return yandex.MapObjectCollection(
          mapId: yandex.MapObjectId('markers_${markers.hashCode}'),
          mapObjects: markers,
        );
      },
      clusterizedMarkerLayer: (layer) {
        final List<yandex.PlacemarkMapObject> markers = [];
        for (final object in layer.objects) {
          final yandexObject = convertMarker(object, layer.style.markerStyle);
          if (yandexObject != null) {
            markers.add(yandexObject);
          }
        }
        return yandex.ClusterizedPlacemarkCollection(
          mapId: yandex.MapObjectId('clustarized_markers_${markers.hashCode}'),
          placemarks: markers,
          radius: layer.clusterRadius,
          minZoom: layer.minZoom,
          onClusterAdded: (self, cluster) async => cluster.copyWith(
            appearance: cluster.appearance.copyWith(
              opacity: 1,
              icon: yandex.PlacemarkIcon.single(
                yandex.PlacemarkIconStyle(
                  image: yandex.BitmapDescriptor.fromBytes(
                    await drawCluster(
                      cluster,
                      style: layer.style,
                    ),
                  ),
                  scale: 1,
                ),
              ),
            ),
          ),
          onClusterTap: (self, cluster) => widget.onClusterTap?.call(
              createPaddedBoundingBoxFrom(
                      cluster.placemarks.map((e) => e.point).toList())
                  .toBBox()),
        );
      },
    );
  }

  @override
  yandex.PlacemarkMapObject? convertMarker(
          Marker packageMarker, MarkerStyle style) =>
      yandex.PlacemarkMapObject(
        mapId: yandex.MapObjectId(packageMarker.key.toString()),
        point: packageMarker.position.toPoint(),
        consumeTapEvents: true,
        onTap: (placemark, _) => widget.onMarkerTap?.call(packageMarker),
        opacity: 1,
        icon: generatePlacemarkIcon(selected: packageMarker.selected),
      );

  @override
  yandex.MapObject<dynamic>? convertObject(
          MapObjectWithGeometry mapObject, ObjectStyle style) =>
      mapObject.geometry.mapOrNull<yandex.MapObject<dynamic>>(
        point: (point) => yandex.CircleMapObject(
          mapId: yandex.MapObjectId('${mapObject.id}_point'),
          circle: MapGeometryCreator.createPoint(
              point.center.toPoint(), style.pointRadius),
          zIndex: mapObject.selected ? 1 : 0,
          onTap: (object, _) => widget.onObjectTap?.call(mapObject),
          consumeTapEvents: true,
          strokeColor: mapObject.selected
              ? style.selectedStrokeColor
              : style.unselectedStrokeColor,
          fillColor: mapObject.selected
              ? style.selectedFillColor
              : style.unselectedFillColor,
          strokeWidth: style.strokeWidth,
        ),
        line: (line) => yandex.PolylineMapObject(
          mapId: yandex.MapObjectId('${mapObject.id}_line'),
          polyline: MapGeometryCreator.createPolyline(line.points),
          strokeWidth: style.strokeWidth,
          turnRadius: 0,
          zIndex: mapObject.selected ? 1 : 0,
          strokeColor: mapObject.selected
              ? style.selectedStrokeColor
              : style.unselectedStrokeColor,
          onTap: (object, _) => widget.onObjectTap?.call(mapObject),
        ),
        multiline: (multiline) => yandex.MapObjectCollection(
          mapId: yandex.MapObjectId('${mapObject.id}_multiline'),
          onTap: (object, _) => widget.onObjectTap?.call(mapObject),
          zIndex: mapObject.selected ? 1 : 0,
          mapObjects: multiline.lines
              .map(
                (e) => yandex.PolylineMapObject(
                  mapId:
                      yandex.MapObjectId('${mapObject.id}_line_${e.hashCode}'),
                  polyline: MapGeometryCreator.createPolyline(e.points),
                  strokeWidth: 1,
                  turnRadius: 0,
                  strokeColor: mapObject.selected
                      ? style.selectedStrokeColor
                      : style.unselectedStrokeColor,
                ),
              )
              .toList(),
        ),
        polygon: (polygon) => yandex.PolygonMapObject(
          mapId: yandex.MapObjectId('${mapObject.id}_polygon'),
          zIndex: mapObject.selected ? 1 : 0,
          polygon: MapGeometryCreator.createPolygon(
            polygon.outerRing,
            polygon.innerRings ?? [],
          ),
          strokeWidth: style.strokeWidth,
          strokeColor: mapObject.selected
              ? style.selectedStrokeColor
              : style.unselectedStrokeColor,
          fillColor: mapObject.selected
              ? style.selectedFillColor
              : style.unselectedFillColor,
          onTap: (object, _) => widget.onObjectTap?.call(mapObject),
        ),
        multipolygon: (multipolygon) => yandex.MapObjectCollection(
          mapId: yandex.MapObjectId('${mapObject.id}_multipolygon'),
          zIndex: mapObject.selected ? 1 : 0,
          onTap: (object, _) => widget.onObjectTap?.call(mapObject),
          mapObjects: multipolygon.polygons
              .map(
                (e) => yandex.PolygonMapObject(
                  mapId: yandex.MapObjectId(
                      '${mapObject.id}_polygon_${e.hashCode}'),
                  polygon: MapGeometryCreator.createPolygon(
                    e.outerRing,
                    e.innerRings ?? [],
                  ),
                  strokeWidth: style.strokeWidth,
                  strokeColor: mapObject.selected
                      ? style.selectedStrokeColor
                      : style.unselectedStrokeColor,
                  fillColor: mapObject.selected
                      ? style.selectedFillColor
                      : style.unselectedFillColor,
                ),
              )
              .toList(),
        ),
      );

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => yandex.YandexMap(
        tiltGesturesEnabled: false,
        rotateGesturesEnabled: false,
        mode2DEnabled: true,
        tiles: widget.areTilesVisible ? widget.tiles.toYandexTiles() : [],
        onUserLocationAdded: (yandex.UserLocationView userLocationView) async =>
            userLocationView.copyWith(
          pin: userLocationView.pin.copyWith(
              opacity: 1,
              icon: yandex.PlacemarkIcon.single(
                yandex.PlacemarkIconStyle(
                  image: yandex.BitmapDescriptor.fromBytes(
                    await drawUserLocation(
                      style: widget.userMarkerStyle,
                    ),
                  ),
                  scale: 1,
                ),
              ),
              isVisible: widget.areUserLocationVisible),
          arrow: userLocationView.arrow.copyWith(
            opacity: 1,
            isVisible: widget.areUserLocationVisible,
            icon: yandex.PlacemarkIcon.single(
              yandex.PlacemarkIconStyle(
                image: yandex.BitmapDescriptor.fromBytes(
                  await drawUserLocation(
                    style: widget.userMarkerStyle,
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
        onMapCreated: (yandex.YandexMapController controller) {
          _mapController = controller;

          _mapController
            ..moveCamera(
              yandex.CameraUpdate.newCameraPosition(
                widget.initialCameraPosition.toCameraPosition(),
              ),
            )
            ..toggleUserLayer(visible: true);
          widget.onMapCreate?.call(YandexMapController(
            controller: _mapController,
            interactivePolygonVisibilityThreshold:
                widget.interactivePolygonVisibilityThreshold,
          ));
        },
        onMapTap: (point) => widget.onMapTap?.call(point.toLatLng()),
        mapObjects: layers,
        onCameraPositionChanged: (position, _, finished) => widget
            .onCameraPositionChanged
            ?.call(position.toMapPosition(), finished),
      );
}
