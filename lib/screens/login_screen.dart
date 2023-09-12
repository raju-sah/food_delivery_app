import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/homeScreen.dart';
import 'package:food_delivery_app/services/otp.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _validPhoneNumber = false;
  var _phoneNumberController = TextEditingController();
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      setState(() {
                        _validPhoneNumber = true;
                      });
                    } else {
                      setState(() {
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
                          onPressed: () {
                            setState(() {
                              auth.loading = true;
                            });

                            String number =
                                '+977${_phoneNumberController.text}';
                            auth
                                .verifyPhone(context: context, number: number)
                                .then((value) {
                              _phoneNumberController.clear();
                            });
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
        ),
      ),
    );
  }
}
