import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';

import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/map_screen.dart';
import 'package:food_delivery_app/screens/onboard_screen.dart';
import 'package:food_delivery_app/screens/osmMapscreen.dart';
import 'package:food_delivery_app/services/otp.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet(context) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      bool _validPhoneNumber = false;
      var _phoneNumberController = TextEditingController();
      showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, StateSetter myState) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      child: Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'LOGIN',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Enter your phone number to process',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: '10 digit mobile number',
                        prefix: Padding(
                          padding: EdgeInsets.all(4),
                          child: Text('+977'),
                        ),
                      ),
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      controller: _phoneNumberController,
                      maxLength: 10,
                      onChanged: (value) {
                        if (value.length == 10) {
                          myState(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          myState(() {
                            _validPhoneNumber = false;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: _validPhoneNumber ? false : true,
                            child: FlatButton(
                              onPressed: () async {
                                myState(() {
                                  auth.loading = true;
                                });

                                String number =
                                    'Verify +977${_phoneNumberController.text}';
                                await auth.verifyPhone(
                                    context: context, number: number);
                                myState(() {
                                  auth.loading = false;
                                });

                                // Call the smsOtpDialog method here
                                auth.smsOtpDialog(context, number);
                              },
                              color: _validPhoneNumber
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              child: auth.loading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      _validPhoneNumber
                                          ? 'CONTINUE'
                                          : 'ENTER PHONE NUMBER',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ).whenComplete(() {
        setState(() {
          auth.loading = false;
          _phoneNumberController.clear();
        });
      });
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: 10.0,
              child: FlatButton(
                child: Text(
                  'SKIP',
                  style: TextStyle(color: Colors.deepOrangeAccent),
                ),
                onPressed: () {},
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: OnBoardScreen(),
                ),
                Text(
                  'Login to order from your nearest Restaurant/Hotel?',
                  style: TextStyle(
                    color: Colors.grey[850],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FlatButton(
                  color: Colors.deepOrangeAccent,
                  child: Text(
                    'LOG IN',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    setState(() {
                      auth.screen = 'Login';
                    });
                    showBottomSheet(context);
                  },
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
