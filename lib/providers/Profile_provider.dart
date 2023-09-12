import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:food_delivery_app/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileProvider with ChangeNotifier {
  File image;
  String pickerError;
  String customerName;
  String profileUrl;
  // String selectedOption = '';

  resetProvider() {
    this.image = null;
    this.profileUrl = null;
    notifyListeners();
  }

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

//upload product image

  Future<String> uploadProfileImage(filepath) async {
    File file = File(filepath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('profileImage/${this.customerName}/$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    String downloadURL = await _storage
        .ref('profileImage/${this.customerName}/$timeStamp')
        .getDownloadURL();
    this.profileUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File> getProfileImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'No image selected';
      print('No image selected');
      notifyListeners();
    }
    return this.image;
  }

  //save product data to firestore

  Future<void> updateProfile(
      {firstName, lastName, email, gender, context}) async {
    User user = FirebaseAuth.instance.currentUser;

    CollectionReference __users =
        FirebaseFirestore.instance.collection('users');
    try {
      String userId = user.uid; // Get the user ID
      await __users.doc(userId).update({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'gender': gender,
        'profileImage': this.profileUrl,
      });

      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: 'Profile saved successfully',
      );
    } catch (e) {
      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: '${e.toString()}',
      );
    }
    return null;
  }
}
