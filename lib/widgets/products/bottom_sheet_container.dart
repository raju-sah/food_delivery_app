import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/favourite_screen.dart';
import 'package:food_delivery_app/widgets/products/save_for_later.dart';

import 'add_to_cart_widget.dart';

class BottomSheetContainer extends StatefulWidget {
  final DocumentSnapshot document;
  BottomSheetContainer(this.document);

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> {
  User user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // Flexible(
          //   child: SaveForLater(widget.document),
          // ),
          Flexible(flex: 1, child: AddToCartWidget(widget.document)),
        ],
      ),
    );
  }
}
