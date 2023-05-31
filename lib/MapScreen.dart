import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:test2/main.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'uq3mIDo6JrLvcUXVIr8PUU56gTXbMFtqM2kuPPga';
  final keyClientKey = 'jcYVbSnDf2phLSJJV4RYMb3LgU2t84KUb6vOV0Ge';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);
}

class LocationData {
  double latitude;
  double longitude;

  LocationData({required this.latitude, required this.longitude});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationData? currentLocation;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // Check and request location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current user location
    LocationData locationData = (await location.getLocation()) as LocationData;
    setState(() {
      currentLocation = LocationData(latitude: locationData.latitude!, longitude: locationData.longitude!);
    });
  }

  Future<void> saveLocation(LocationData locationData) async {

    final ParseObject newLocation = ParseObject('Location')

      ..set('latitude', locationData.latitude)
      ..set('longitude', locationData.longitude);

    try {
      await newLocation.save();
      print('Location saved successfully!');
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0),
          zoom: 13.0,
          onTap: (tapPosition, LatLng latLng) {
            setState(() {
              currentLocation = LocationData(latitude: latLng.latitude, longitude: latLng.longitude);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(currentLocation?.latitude ?? 0.0, currentLocation?.longitude ?? 0.0),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SavePage()),
          );
        },
        child: Icon(Icons.save),
      ),
    );
  }
}


