import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/landing_screen.dart';
import 'package:food_delivery_app/screens/main_screen.dart';
import 'package:food_delivery_app/services/user_services.dart';
import 'package:pinput/pin_put/pin_put.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String smsOtp;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  String screen;
  String address;
  String location;
  DocumentSnapshot snapshot;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );

  double _latitude;
  double _longitude;

  double get latitude => _latitude;
  double get longitude => _longitude;

  set latitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  set longitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  Future<void> verifyPhone({BuildContext context, String number}) async {
    this.loading = true;
    notifyListeners();

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              Navigator.pushReplacementNamed(context, LandingScreen.id);
            }
          });
        },
        verificationFailed: (FirebaseException e) {
          print(e.message);
        },
        codeSent: (String verificationID, int resendToken) {
          _verificationCode = verificationID;
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationCode = verificationID;
        },
        timeout: Duration(seconds: 60));
  }

  // Future<void> verifyPhone({BuildContext context, String number}) async {
  //   this.loading = true;
  //   notifyListeners();

  //   final PhoneVerificationCompleted verificationCompleted =
  //       (PhoneAuthCredential credential) async {
  //     this.loading = false;
  //     notifyListeners();

  //     await _auth.signInWithCredential(credential);
  //   };

  //   final PhoneVerificationFailed verificationFailed =
  //       (FirebaseAuthException e) {
  //     this.loading = false;
  //     print(e.code);
  //     this.error = e.toString();
  //     notifyListeners();
  //   };

  //   final PhoneCodeSent smsOtpSend = (String verId, int resendToken) async {
  //     this.verificationId = verId;

  //     //dialog to enter recieved OTP message
  //     smsOtpDialog(context, number);
  //   };

  //   try {
  //     _auth.verifyPhoneNumber(
  //         phoneNumber: number,
  //         verificationCompleted: verificationCompleted,
  //         verificationFailed: verificationFailed,
  //         codeSent: smsOtpSend,
  //         codeAutoRetrievalTimeout: (String verId) {
  //           this.verificationId = verId;
  //         },
  //         timeout: Duration(seconds: 60));
  //   } catch (e) {
  //     this.error = e.toString();
  //     this.loading = false;
  //     notifyListeners();
  //     print(e);
  //   }
  // }

  Future<bool> smsOtpDialog(BuildContext context, String number) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            title: Expanded(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        number,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 26),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: PinPut(
                      fieldsCount: 6,
                      textStyle:
                          const TextStyle(fontSize: 25.0, color: Colors.white),
                      eachFieldWidth: 40.0,
                      eachFieldHeight: 55.0,
                      // onSubmit: (String pin) => _showSnackBar(pin),
                      focusNode: _pinPutFocusNode,
                      controller: _pinPutController,
                      submittedFieldDecoration: pinPutDecoration,
                      selectedFieldDecoration: pinPutDecoration,
                      followingFieldDecoration: pinPutDecoration,
                      pinAnimationType: PinAnimationType.fade,
                      // ... (previous code)

                      // ... (previous code)

                      onSubmit: (pin) async {
                        try {
                          await FirebaseAuth.instance
                              .signInWithCredential(
                                  PhoneAuthProvider.credential(
                                      verificationId: _verificationCode,
                                      smsCode: pin))
                              .then((value) async {
                            if (value.user != null) {
                              this.loading = false;
                              notifyListeners();

                              // User login successful

                              _userServices
                                  .getUserById(value.user.uid)
                                  .then((snapShot) {
                                if (snapShot.exists) {
                                  //user data already exists
                                  if (this.screen == 'Login') {
                                    //need to check user data already exxists in db or not.
                                    //if it's 'login' no new data, so no need to update
                                    if (snapShot.data()['address'] != null) {
                                      Navigator.pushReplacementNamed(
                                          context, MainScreen.id);
                                    }
                                    Navigator.pushReplacementNamed(
                                        context, LandingScreen.id);
                                  } else {
                                    //need to update new selected address
                                    updateUser(
                                        id: value.user.uid,
                                        number: value.user.phoneNumber);
                                    Navigator.pushReplacementNamed(
                                        context, MainScreen.id);
                                  }
                                } else {
                                  //user data does not exists
                                  //will create new data in db
                                  _createUser(
                                      id: value.user.uid,
                                      number: value.user.phoneNumber);
                                  Navigator.pushReplacementNamed(
                                      context, LandingScreen.id);
                                }
                              });
                            } else {
                              // User login failed
                              print('Login failed');
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invalid OTP')));
                            }
                          });
                        } catch (e) {
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid OTP')));
                        }
                      },
// ... (rest of the code)

// ... (rest of the code)
                    ),
                  ),
                ],
              ),
            ),
          );
        }).whenComplete(() {
      this.loading = false;
      notifyListeners();
    });
  }

  void _createUser({String id, String number}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
      'location': this.location,
    });
    this.loading = false;
    notifyListeners();
  }

  Future<bool> updateUser({
    String id,
    String number,
  }) async {
    try {
      _userServices.updateUserData({
        'id': id,
        'number': number,
        'latitude': this.latitude,
        'longitude': this.longitude,
        'address': this.address,
        'location': this.location,
      });
      this.loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error $e');
      return false;
    }
  }

  getUserDetails() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .get();
    if (result != null) {
      this.snapshot = result;
      notifyListeners();
    } else {
      this.snapshot = null;
      notifyListeners();
    }

    return result;
  }
}
