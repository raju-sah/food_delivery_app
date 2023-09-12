// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:food_delivery_app/providers/location-provider.dart';
// import 'package:food_delivery_app/screens/main_screen.dart';
// import 'package:pinput/pin_put/pin_put.dart';
// import 'package:flutter/cupertino.dart';

// import 'user_services.dart';

// class OTPScreen extends StatefulWidget {
//   static const String id = 'map-screen';
//   final String phone;
//   OTPScreen(this.phone);

//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   String smsOtp;
//   String error = '';
//   UserServices _userServices = UserServices();
//   bool loading = false;
//   LocationProvider locationData = LocationProvider();
//   String screen;
//   double latitude;
//   double longitude;
//   String address;
//   String location;
//   DocumentSnapshot snapshot;
//   final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
//   String _verificationCode;
//   final TextEditingController _pinPutController = TextEditingController();
//   final FocusNode _pinPutFocusNode = FocusNode();
//   final BoxDecoration pinPutDecoration = BoxDecoration(
//     color: const Color.fromRGBO(43, 46, 66, 1),
//     borderRadius: BorderRadius.circular(10.0),
//     border: Border.all(
//       color: const Color.fromRGBO(126, 203, 224, 1),
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('OTP Verification'),
//       ),
//       body: Column(
//         children: [
//           Container(
//             margin: EdgeInsets.only(top: 40),
//             child: Center(
//               child: Text(
//                 'verify +977${widget.phone}',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: PinPut(
//               fieldsCount: 6,
//               textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
//               eachFieldWidth: 40.0,
//               eachFieldHeight: 55.0,
//               // onSubmit: (String pin) => _showSnackBar(pin),
//               focusNode: _pinPutFocusNode,
//               controller: _pinPutController,
//               submittedFieldDecoration: pinPutDecoration,
//               selectedFieldDecoration: pinPutDecoration,
//               followingFieldDecoration: pinPutDecoration,
//               pinAnimationType: PinAnimationType.fade,
//               // ... (previous code)

//               // ... (previous code)

//               onSubmit: (pin) async {
//                 try {
//                   await FirebaseAuth.instance
//                       .signInWithCredential(PhoneAuthProvider.credential(
//                           verificationId: _verificationCode, smsCode: pin))
//                       .then((value) async {
//                     if (value.user != null) {
//                       // User login successful
//                       DocumentSnapshot snapshot =
//                           await _userServices.getUserById(value.user.uid);
//                       if (snapshot.exists) {
//                         // User data already exists
//                         if (this.screen == 'Login') {
//                           Navigator.pushReplacementNamed(
//                               context, MainScreen.id);
//                         } else {
//                           await updateUser(
//                               id: value.user.uid,
//                               number: value.user.phoneNumber);
//                           Navigator.pushReplacementNamed(
//                               context, MainScreen.id);
//                         }
//                       } else {
//                         await _createUser(
//                             id: value.user.uid, number: value.user.phoneNumber);
//                         Navigator.pushReplacementNamed(context, MainScreen.id);
//                       }
//                     } else {
//                       // User login failed
//                       print('Login failed');
//                       ScaffoldMessenger.of(context)
//                           .showSnackBar(SnackBar(content: Text('Invalid OTP')));
//                     }
//                   });
//                 } catch (e) {
//                   FocusScope.of(context).unfocus();
//                   ScaffoldMessenger.of(context)
//                       .showSnackBar(SnackBar(content: Text('Invalid OTP')));
//                 }
//               },
// // ... (rest of the code)

// // ... (rest of the code)
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   _verifyPhone() async {
//     await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: '+977${widget.phone}',
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance
//               .signInWithCredential(credential)
//               .then((value) async {
//             if (value.user != null) {
//               Navigator.pushReplacementNamed(context, MainScreen.id);
//             }
//           });
//         },
//         verificationFailed: (FirebaseException e) {
//           print(e.message);
//         },
//         codeSent: (String verificationID, int resendToken) {
//           setState(() {
//             _verificationCode = verificationID;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationID) {
//           setState(() {
//             _verificationCode = verificationID;
//           });
//         },
//         timeout: Duration(seconds: 60));
//   }

//   @override
//   void initState() {
//     super.initState();
//     _verifyPhone();
//   }

//   void _createUser({String id, String number}) async {
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(id).set({
//         'id': id,
//         'number': number,
//         'latitude': this.latitude,
//         'longitude': this.longitude,
//         'address': this.address,
//         'location': this.location
//       });
//     } catch (error) {
//       print('Error creating user: $error');
//     }
//   }

//   Future<void> updateUser({String id, String number}) async {
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(id).update({
//         'id': id,
//         'number': number,
//         'latitude': this.latitude,
//         'longitude': this.longitude,
//         'address': this.address,
//         'location': this.location
//       });
//     } catch (error) {
//       print('Error updating user: $error');
//     }
//   }

//   getUserDetails() async {
//     DocumentSnapshot result = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(_auth.currentUser.uid)
//         .get();
//     if (result != null) {
//       this.snapshot = result;
//     } else {
//       this.snapshot = null;
//     }

//     return result;
//   }
// }
