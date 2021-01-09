import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _homeloc = "searching...";
  Position _currentPosition;
  String gmaploc = "";
  CameraPosition _userpos;
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  Set<Marker> markers = Set();
  MarkerId markerId1 = MarkerId("12");
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.teal[50],
          appBar: AppBar(
            backgroundColor: Colors.tealAccent[700],
            centerTitle: true,
            title: Text(
              "Map",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 330,
                  width: 400,
                  child: GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: _userpos,
                      markers: markers.toSet(),
                      onMapCreated: (controller) {
                        _controller.complete(controller);
                      },
                      onTap: (newLatLng) {
                        _loadLoc(newLatLng);
                      }),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          child: Text("Address: ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    _homeloc,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(
                    "Current position:",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: Text(
                    "Latitude: " + latitude.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    "Longitude: " + longitude.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _loadLoc(LatLng loc) async {
    markers.clear();
    latitude = loc.latitude;
    longitude = loc.longitude;
    _getLocationfromlatlng(latitude, longitude);
    markers.add(Marker(
      markerId: markerId1,
      position: LatLng(latitude, longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: "Latitude:" +
            latitude.toStringAsFixed(7) +
            "," +
            "Longitude: " +
            longitude.toStringAsFixed(7),
      ),
    ));
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
  }

  _getLocationfromlatlng(double lat, double lng) async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _homeloc = first.addressLine;

    setState(() {
      _homeloc = first.addressLine;
    });
  }

  Future<void> _getLocation() async {
    try {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() async {
        print(position);
        markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
            }
          });
        }
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}
