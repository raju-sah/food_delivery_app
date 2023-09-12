import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/map_screen.dart';
import 'package:food_delivery_app/screens/osmMapscreen.dart';

class LandingScreen extends StatefulWidget {
  static const String id = 'landing-screen';

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider _locationProvider = LocationProvider();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Delivery Address not set',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please update your Delivery Location to find nearest Restaurant/Hotel for you',
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
            ),
            Container(
                width: 600,
                child: Image.asset(
                  'images/city.png',
                  fit: BoxFit.fill,
                )),
            _loading
                ? CircularProgressIndicator()
                : FlatButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                      });

                      await _locationProvider.getCurrentPosition();
                      if (_locationProvider.selectedAddress != true) {
                        Navigator.pushReplacementNamed(
                            context, OpenStreetMapIntegration.id);
                      } else {
                        Future.delayed(Duration(seconds: 4), () {
                          if (_locationProvider.selectedAddress != false) {
                            print('Permission not allowed');
                            setState(() {
                              _loading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Please allow permission to find nearest Restaurants/Hotels for you'),
                            ));
                          }
                        });
                      }
                    },
                    child: Text(
                      'Set Your Location',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
