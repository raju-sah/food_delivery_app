import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/profile_update_screen.dart';

class ProfileHomeScreen extends StatelessWidget {
  static const String id = 'profile-home-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          color: Colors.deepOrangeAccent,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => UpdateProfile()));
          },
          child: Text('Create Profile', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
