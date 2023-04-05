import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MapApp());

class MapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Example',
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController mapController = MapController();
  late LatLng markerLatLng;
  late LatLng currentLocationLatLng;


  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      if(currentLocationLatLng==null) {
        currentLocationLatLng =
            LatLng(position.latitude, position.longitude);
      }
    else LatLng(0,0);});
  }
  void _addMarker(LatLng latLng) {
    setState(() {
      markerLatLng = latLng;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Example')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentLocationLatLng ?? LatLng(52.229675, 21.012230),
          zoom: 13.0,
          onTap: _addMarker,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              if (markerLatLng != null)
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: markerLatLng,
                  builder: (ctx) => Container(
                    child: Icon(Icons.location_pin, color: Colors.red),
                  ),
                ),
              if (currentLocationLatLng != null)
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: currentLocationLatLng,
                  builder: (ctx) => Container(
                    child: Icon(Icons.location_on, color: Colors.blue),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

MarkerLayerOptions({required List<Marker> markers}) {
}

TileLayerOptions({required String urlTemplate, required List<String> subdomains}) {
}
