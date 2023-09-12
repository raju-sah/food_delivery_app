import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:food_delivery_app/models/product_model.dart';

class RatingProvider with ChangeNotifier {
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

  Future<void> saveRatingAndCommentinUsers(
      {rating, product, comment, context}) async {
    User user = FirebaseAuth.instance.currentUser;

    CollectionReference __users =
        FirebaseFirestore.instance.collection('users');

    try {
      String userId = user.uid; // Get the user ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await __users.doc(userId).set({
        'FoodRating': FieldValue.arrayUnion([
          {
            'timestamp': DateTime.now().toString(),
            'rating': rating,
            'comment': comment,
            'product': product,
            'published': true,
          }
        ])
      }, SetOptions(merge: true));
      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: 'Rating saved successfully',
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

  Future<void> saveRatingAndCommentinProducts(
      {rating,
      comment,
      context,
      userId,
      productId,
      userName,
      userImage,
      userMobile}) async {
    User user = FirebaseAuth.instance.currentUser;

    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');

    try {
      String userId = user.uid; // Get the user ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _products.doc(productId).set({
        'FoodRating': FieldValue.arrayUnion([
          {
            'timestamp': DateTime.now().toString(),
            'rating': rating,
            'comment': comment,
            'userId': userId,
            'userName': userName,
            'userImage': userImage,
            'userMobile': userMobile,
            'published': true,
          }
        ])
      }, SetOptions(merge: true));
    } catch (e) {
      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: '${e.toString()}',
      );
    }
    return null;
  }

  Future<void> savevendorRatingAndCommentinUsers(
      {rating, vendor, comment, context}) async {
    User user = FirebaseAuth.instance.currentUser;

    CollectionReference __users =
        FirebaseFirestore.instance.collection('users');

    try {
      String userId = user.uid; // Get the user ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await __users.doc(userId).set(
        {
          'VendorRating': FieldValue.arrayUnion([
            // Updated field name
            {
              'timestamp': DateTime.now().toString(),
              'rating': rating,
              'comment': comment,
              'vendor': vendor,
              'published': true,
            }
          ])
        },
        SetOptions(merge: true),
      );
      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: 'Rating saved successfully',
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

  Future<void> savevendorRatingAndCommentinVendors(
      {rating,
      comment,
      context,
      userId,
      sellerId,
      userName,
      userImage,
      userMobile}) async {
    User user = FirebaseAuth.instance.currentUser;

    CollectionReference _vendors =
        FirebaseFirestore.instance.collection('vendors');

    try {
      String vendorId = sellerId; // Get the vendor ID
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _vendors.doc(vendorId).set(
        {
          'VendorRating': FieldValue.arrayUnion([
            // Updated field name
            {
              'timestamp': DateTime.now().toString(),
              'rating': rating,
              'comment': comment,
              'userId': userId,
              'userName': userName,
              'userImage': userImage,
              'userMobile': userMobile,
              'published': true,
            }
          ])
        },
        SetOptions(merge: true),
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
