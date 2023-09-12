//static const String id = 'openstreet-map';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/main_screen.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

import 'login_screen.dart';

class OpenStreetMapIntegration extends StatefulWidget {
  static const String id = 'openstreet-map';
  @override
  _OpenStreetMapIntegrationState createState() =>
      _OpenStreetMapIntegrationState();
}

class _OpenStreetMapIntegrationState extends State<OpenStreetMapIntegration> {
  TextEditingController _searchController = TextEditingController();
  MapController _mapController = MapController();
  LatLng _searchedLocation;
  LatLng _selectedLocation;
  String _selectedAddress = '';

  LatLng currentLocation = LatLng(37.421632, 122.084664);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation() async {
    String searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      final String apiUrl = "https://nominatim.openstreetmap.org/search";
      final Map<String, String> queryParams = {
        'format': 'json',
        'q': searchText,
      };
      final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

      try {
        final response = await http
            .get(uri, headers: {'User-Agent': 'OpenStreetMap-Flutter'});

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          if (data.isNotEmpty) {
            setState(() {
              _searchedLocation = LatLng(
                double.parse(data[0]['lat']),
                double.parse(data[0]['lon']),
              );
            });
            _mapController.move(_searchedLocation, 13.0);
          } else {
            // Handle no results found
            setState(() {
              _searchedLocation = null;
            });
          }
        } else {
          // Handle API error
          setState(() {
            _searchedLocation = null;
          });
        }
      } catch (e) {
        // Handle network or other errors
        setState(() {
          _searchedLocation = null;
        });
      }
    }
  }

  void _handleTap(LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _fetchAddressForSelectedLocation(); // Fetch address for the selected location
  }

  // void _saveSelectedLocation() {
  //   if (_selectedLocation != null) {
  //     Navigator.pushReplacementNamed(context, MainScreen.id);
  //     setState(() {
  //       _searchedLocation = _selectedLocation;
  //       _selectedLocation = null;
  //     });
  //   }
  // }

  Future<void> _fetchAddressForSelectedLocation() async {
    final String apiUrl = "https://nominatim.openstreetmap.org/reverse";
    final Map<String, String> queryParams = {
      'format': 'json',
      'lat': _selectedLocation.latitude.toString(),
      'lon': _selectedLocation.longitude.toString(),
    };
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

    try {
      final response =
          await http.get(uri, headers: {'User-Agent': 'OpenStreetMap-Flutter'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          setState(() {
            _selectedAddress = data['display_name'];
          });
        } else {
          setState(() {
            _selectedAddress = 'Address not found';
          });
        }
      } else {
        setState(() {
          _selectedAddress = 'Error fetching address';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Error fetching address';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter a location',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _searchLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            _selectedAddress,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(37.7749, -122.4194),
                zoom: 13.0,
                onTap: _handleTap, // Register tap events on the map
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_searchedLocation != null)
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _searchedLocation,
                        builder: (ctx) => Container(
                          child: Icon(Icons.location_on, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                if (_selectedLocation !=
                    null) // Marker for the selected location
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _selectedLocation,
                        builder: (ctx) => Container(
                          child: Icon(Icons.location_on, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedLocation != null) {
            locationData.savePrefs();
            if (_loggedIn == false) {
              Navigator.pushNamed(context, LoginScreen.id);
            } else {
              setState(() {
                _auth.latitude = _selectedLocation.latitude;
                _auth.longitude = _selectedLocation.longitude;
                _auth.address = _selectedAddress;
                _auth.location = _selectedAddress;
              });
              _auth.updateUser(
                id: user.uid,
                number: user.phoneNumber,
              );
              Navigator.pushNamed(context, MainScreen.id);
            }
          } else {
            print('Login failed');
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select Your location')));
          }
          //_saveSelectedLocation();
          _fetchAddressForSelectedLocation(); // Fetch address for the selected location
        },
        tooltip: 'Set Your Current Location',
        child: Icon(Icons.add_location),
      ),
    );
  }
}
