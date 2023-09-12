import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/providers/Profile_provider.dart';
import 'package:food_delivery_app/services/user_services.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'profile_screen.dart';

class UpdateProfile extends StatefulWidget {
  static const String id = 'update-profile';

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  User user = FirebaseAuth.instance.currentUser;
  UserServices _user = UserServices();
  var firstName = TextEditingController();
  var lastName = TextEditingController();
  String selectedOption = '';
  var mobile = TextEditingController();
  var _emailTextController = TextEditingController();
  File _image;
  String email;
  String profileImageURL;

  // updateProfile() {
  //   return FirebaseFirestore.instance.collection('users').doc(user.uid).update({
  //     'firstName': firstName.text,
  //     'lastName': lastName.text,
  //     'email': email.text,
  //   });
  // }

  @override
  void initState() {
    _user.getUserById(user.uid).then((value) {
      if (mounted) {
        setState(() {
          firstName.text = value.data()['firstName'];
          lastName.text = value.data()['lastName'];
          _emailTextController.text = value.data()['email'];
          mobile.text = user.phoneNumber;
          selectedOption = value.data()['gender'];
          profileImageURL = value.data()['profileImage'];
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Create/Update Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      _provider.getProfileImage().then((image) {
                        setState(() {
                          _image = image;
                        });
                      });
                    },
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Card(
                        color: Theme.of(context).primaryColor,
                        child: _image == null
                            ? Center(
                                child: Text(
                                  'Select Image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Image.file(
                                _image, // Use Image.file instead of Image.network
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: firstName,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter First Name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'First Name',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: lastName,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Last Name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Last Name',
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor)),
                      focusColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender:',
                      style: TextStyle(),
                    ),
                    RadioListTile(
                      title: Text('Male'),
                      value: 'male',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Female'),
                      value: 'female',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Other'),
                      value: 'other',
                      groupValue: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                TextFormField(
                  controller: mobile,
                  enabled: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_android),
                    labelText: 'Mobile',
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2, color: Theme.of(context).primaryColor)),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                TextFormField(
                  controller: _emailTextController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Email',
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2, color: Theme.of(context).primaryColor)),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter Email';
                    }
                    final bool _isValid =
                        EmailValidator.validate(_emailTextController.text);
                    if (!_isValid) {
                      return 'Inavalid Email Format';
                    }
                    setState(() {
                      email = value;
                    });
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  height: 56,
                  color: Colors.blueGrey[900],
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState.validate()) {
                        if (_image != null) {
                          EasyLoading.show(status: 'Saving Profile...');
                          _provider.uploadProfileImage(_image.path).then((url) {
                            if (url != null) {
                              _provider.updateProfile(
                                  context: context,
                                  firstName: firstName.text,
                                  lastName: lastName.text,
                                  gender: selectedOption,
                                  email: _emailTextController.text);
                              EasyLoading.dismiss();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileScreen()));
                            } else {
                              _provider.alertDialog(
                                context: context,
                                title: 'IMAGE UPLOAD',
                                content: 'Failed to upload profile image',
                              );
                            }
                          });
                        } else {
                          _provider.alertDialog(
                            context: context,
                            title: 'PROFILE IMAGE',
                            content: 'Profile image not selected',
                          );
                        }
                      }
                    },
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
