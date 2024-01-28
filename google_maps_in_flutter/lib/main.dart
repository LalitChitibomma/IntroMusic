import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'locations.dart' as locations;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Marker> markerz = [];
  int id = 1;

  Position target = Position(
    latitude: 0.0, // replace with your desired target latitude
    longitude: 0.0, // replace with your desired target longitude
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  late LocationData currentLocation;

  AudioPlayer audioPlayer = AudioPlayer();

  void playAudio() {
    const pathway = 'CanYouFeel.mp3';
    audioPlayer.play(AssetSource(pathway));
  }

  void getCurrentLocation() {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        setState(() {});

        double dist = ((currentLocation.latitude ?? 0) - target.latitude) *
                ((currentLocation.latitude ?? 0) - target.latitude) +
            ((currentLocation.longitude ?? 0) - target.longitude) *
                ((currentLocation.longitude ?? 0) - target.longitude);
        print('Distance $dist');
        if (dist < 0.000001) {
          playAudio();
        }

        print('$currentLocation');
      },
    );
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  // void initLocationTracking() {
  //   void playAudioWhenCloseToTarget() {

  //   }

  //   getCurrentLocation();
  //   playAudioWhenCloseToTarget();
  // }

  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IntroMusic'),
          elevation: 2,
        ),
        body: GoogleMap(
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (LatLng latLng) {
            Marker newMarker = Marker(
              markerId: MarkerId('$id'),
              position: LatLng(latLng.latitude, latLng.longitude),
              infoWindow: InfoWindow(title: 'New Place'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            );

            markerz.add(newMarker);
            double newLatitude =
                latLng.latitude; // replace with your desired latitude
            double newLongitude =
                latLng.longitude; // replace with your desired latitude
            target = Position(
              latitude: newLatitude,
              longitude: newLongitude,
              timestamp: target.timestamp,
              accuracy: target.accuracy,
              altitude: target.altitude,
              altitudeAccuracy: target.altitudeAccuracy,
              heading: target.heading,
              headingAccuracy: target.headingAccuracy,
              speed: target.speed,
              speedAccuracy: target.speedAccuracy,
            );
            id = id + 1;
            setState(() {});

            print('Our lat nad long is: $latLng and id is $id');
          },
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(100, -84),
            zoom: 2,
          ),
          markers: markerz.map((e) => e).toSet(),
        ),
      ),
    );
  }
}
