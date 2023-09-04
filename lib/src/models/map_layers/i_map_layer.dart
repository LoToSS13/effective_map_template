import 'package:effective_map/effective_map.dart';
import 'package:effective_map/src/models/styles/cluster_marker_style.dart';
import 'package:effective_map/src/models/styles/i_map_object_style.dart';
import 'package:effective_map/src/models/styles/marker_style.dart';
import 'package:effective_map/src/models/styles/object_style.dart';

sealed class MapLayer<T> {
  final List<T> objects;
  final IMapObjectStyle style;

  O? mapOrNull<O extends Object?>({
    O? Function(MapObjectLayer value)? mapObjectLayer,
    O? Function(MarkerLayer value)? markerLayer,
    O? Function(ClusterizedMarkerLayer value)? clusterizedMarkerLayer,
  }) =>
      switch (this) {
        MapObjectLayer() => mapObjectLayer?.call(this as MapObjectLayer),
        MarkerLayer() => markerLayer?.call(this as MarkerLayer),
        ClusterizedMarkerLayer() =>
          clusterizedMarkerLayer?.call(this as ClusterizedMarkerLayer),
      };

  const MapLayer({required this.objects, required this.style});
}

final class MapObjectLayer extends MapLayer<MapObjectWithGeometry> {
  @override
  final ObjectStyle style;
  const MapObjectLayer(
      {required List<MapObjectWithGeometry> objects, required this.style})
      : super(objects: objects, style: style);
}

final class MarkerLayer extends MapLayer<Marker> {
  @override
  final MarkerStyle style;
  const MarkerLayer({required List<Marker> markers, required this.style})
      : super(objects: markers, style: style);
}

final class ClusterizedMarkerLayer extends MapLayer<Marker> {
  final double clusterRadius;
  final int minZoom;

  @override
  final ClusterMarkerStyle style;
  const ClusterizedMarkerLayer(
      {required List<Marker> markers,
      required this.style,
      this.clusterRadius = 30,
      this.minZoom = 18})
      : super(objects: markers, style: style);
}
