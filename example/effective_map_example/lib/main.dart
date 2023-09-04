import 'package:flutter/material.dart';
import 'package:effective_map/effective_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Effective map example ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final MapController _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
            onPressed: () => _controller.zoomOut(),
            child: const Icon(Icons.remove)),
        ElevatedButton(
            style: ElevatedButton.styleFrom(),
            onPressed: () => _controller.zoomIn(),
            child: const Icon(Icons.add))
      ]),
      body: EffectiveMap(
        MapSample.osm,
        urlTemplate:
            'http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
        initialCameraPosition:
            const LatLng(latitude: 54.986351, longitude: 73.371185),
        onMapCreate: (controller) {
          debugPrint('map was created');
          _controller = controller;
        },
        onObjectTap: (object) {
          debugPrint('object tap');
        },
        onCameraPositionChanged: (position, finished) {
          debugPrint('moving camera');
        },
        onClusterTap: (bbox) {
          debugPrint('cluster tap');
        },
        onMapTap: (latLng) {
          debugPrint('map tap');
        },
        onMarkerTap: (marker) {
          debugPrint('marker tap');
        },
        layers: [
          const MapObjectLayer(
              objects: [
                MapObjectWithGeometry(
                  id: '1',
                  geometry: MapObjectGeometry.point(
                    center: LatLng(
                        latitude: 54.985981539382834,
                        longitude: 73.37164874229191),
                  ),
                ),
                MapObjectWithGeometry(
                  id: '2',
                  geometry: MapObjectGeometry.line(
                    points: [
                      PointObjectGeometry(
                        center: LatLng(
                            latitude: 54.98683243800384,
                            longitude: 73.37096804013746),
                      ),
                      PointObjectGeometry(
                        center: LatLng(
                            latitude: 54.985981539382834,
                            longitude: 73.37164874229191),
                      ),
                    ],
                    center: LatLng(
                        latitude: 54.985981539382834,
                        longitude: 73.37164874229191),
                  ),
                ),
              ],
              style: ObjectStyle(
                unselectedFillColor: Colors.red,
                unselectedStrokeColor: Colors.green,
              )),
          ClusterizedMarkerLayer(
              minZoom: 18,
              clusterRadius: 30,
              markers: const [
                Marker(
                  key: ValueKey(1),
                  position:
                      LatLng(latitude: 54.985981539382834, longitude: 73.372),
                ),
                Marker(
                  key: ValueKey(2),
                  position: LatLng(
                      latitude: 54.98683243800384,
                      longitude: 73.37096804013746),
                ),
                Marker(
                  key: ValueKey(3),
                  position: LatLng(
                      latitude: 54.985981539382834,
                      longitude: 73.37164874229191),
                ),
              ],
              style: ClusterMarkerStyle(
                fillColor: Colors.green,
                width: 40,
                height: 40,
                devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                radius: 50,
                markerStyle: MarkerStyle(
                  height: 35,
                  width: 35,
                  devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                  unselectedMarkerViewPath: 'assets/pin.png',
                  selectedMarkerViewPath: 'assets/selected_pin.png',
                ),
              )),
          MarkerLayer(
            markers: const [
              Marker(
                key: ValueKey(11),
                position: LatLng(latitude: 54.987, longitude: 73.372),
              ),
              Marker(
                key: ValueKey(12),
                position:
                    LatLng(latitude: 54.987, longitude: 73.37096804013746),
              ),
              Marker(
                key: ValueKey(13),
                position:
                    LatLng(latitude: 54.987, longitude: 73.37164874229191),
              ),
            ],
            style: MarkerStyle(
              offset: const Offset(0.5, 1),
              height: 35,
              width: 35,
              devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
              unselectedMarkerViewPath: 'assets/selected_pin.png',
              selectedMarkerViewPath: 'assets/pin.png',
            ),
          ),
        ],
        userAgentPackageName: 'com.effective.map',
        areTilesVisible: false,
        areUserPositionVisible: true,
        interactivePolygonVisibilityThreshold: 17,
        maxCameraZoom: 20,
        minCameraZoom: 3,
        initialCameraZoom: 18,
        userMarkerStyle: UserMarkerStyle(
            height: 10,
            borderWidth: 1,
            fillColor: Colors.green,
            borderColor: Colors.black,
            devicePixelRatio: MediaQuery.devicePixelRatioOf(context)),
        userPosition: const LatLng(latitude: 54.986351, longitude: 73.371185),
      ),
    );
  }
}
