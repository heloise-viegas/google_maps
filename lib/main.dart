import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController googleMapController;
  LatLng _latLong = const LatLng(45.521563, -122.677433);
  late loc.LocationData currentPos;
  late String address, dateTime;

  late Marker marker;
  loc.Location location = loc.Location();
  List<Marker> _markers = <Marker>[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
  }

  getLoc() async {
    late bool _serviceEnab;
    late loc.PermissionStatus _permissionGranted;
    _serviceEnab = await location.serviceEnabled();
    if (!_serviceEnab) {
      _serviceEnab = await location.requestService();

      if (_serviceEnab) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
    currentPos = await location.getLocation();
    _latLong = LatLng(
        currentPos.latitude!.toDouble(), currentPos.longitude!.toDouble());
    location.onLocationChanged.listen((event) {
      print('lat:');
      print(event.latitude);
      setState(() {
        currentPos = event;
        _latLong = LatLng(
            currentPos.latitude!.toDouble(), currentPos.longitude!.toDouble());
      });
    });

    _markers.add(Marker(
        markerId: MarkerId('SomeId'),
        position: _latLong,
        infoWindow: InfoWindow(title: 'You')));
  }

  // Future<List<Address>> _getAddress(double lat, double lang) async {
  //   final coordinates = new Coordinates(lat, lang);
  //   List<Address> add =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   return add;
  // }

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    location.onLocationChanged.listen((l) {
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(l.latitude!.toDouble(), l.longitude!.toDouble()),
              zoom: 15),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _latLong,
            zoom: 11.0,
          ),
          markers: Set<Marker>.of(_markers),
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
