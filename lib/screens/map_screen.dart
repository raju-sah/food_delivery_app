import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/homeScreen.dart';
import 'package:food_delivery_app/screens/landing_screen.dart';
import 'package:food_delivery_app/screens/login_screen.dart';
import 'package:food_delivery_app/screens/main_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map-screen';
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentLocation = LatLng(37.421632, 122.084664);
  GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  User user;

  @override
  void initState() {
    //check user logged in or not while opening map screen
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
    if (user != null) {
      setState(() {
        _loggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    final _auth = Provider.of<AuthProvider>(context);

    setState(() {
      currentLocation = LatLng(locationData.latitude, locationData.longitude);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 14.4746,
              ),
              zoomControlsEnabled: false,
              minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.8),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              mapToolbarEnabled: true,
              onCameraMove: (CameraPosition position) {
                setState(() {
                  _locating = true;
                });
                // locationData.onCameraMove(position);
              },
              onMapCreated: onCreated,
              onCameraIdle: () {
                setState(() {
                  _locating = false;
                });
                // locationData.getMoveCamera();
              },
            ),
            Center(
              child: Container(
                height: 50,
                margin: EdgeInsets.only(bottom: 40),
                child: Image.asset(
                  'images/marker.png',
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: SpinKitPulse(
                color: Colors.black54,
                size: 100.0,
              ),
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _locating
                        ? LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 20),
                      child: TextButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            Icons.location_searching,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            _locating
                                ? 'Locating.....'
                                : locationData.selectedAddress == null
                                    ? 'Locating...'
                                    : locationData.selectedAddress.featureName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        _locating
                            ? ''
                            : locationData.selectedAddress == null
                                ? ''
                                : locationData.selectedAddress.addressLine,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: AbsorbPointer(
                          absorbing: _locating ? true : false,
                          child: FlatButton(
                            onPressed: () {
                              locationData.savePrefs();
                              if (_loggedIn == false) {
                                Navigator.pushNamed(context, LoginScreen.id);
                              } else {
                                setState(() {
                                  _auth.latitude = locationData.latitude;
                                  _auth.longitude = locationData.longitude;
                                  _auth.address =
                                      locationData.selectedAddress.addressLine;
                                  _auth.location =
                                      locationData.selectedAddress.featureName;
                                });
                                _auth.updateUser(
                                  id: user.uid,
                                  number: user.phoneNumber,
                                );
                                Navigator.pushNamed(context, MainScreen.id);
                              }
                            },
                            color: _locating
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            child: Text(
                              'CONFIRM LOCATION',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
