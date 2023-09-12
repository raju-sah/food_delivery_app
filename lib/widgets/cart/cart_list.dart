import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/services/cart_services.dart';
import 'package:food_delivery_app/widgets/cart/cart_card.dart';

class CartList extends StatefulWidget {
  final DocumentSnapshot document;

  CartList({this.document});

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  CartServices _cart = CartServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _cart.cart.doc(_cart.user.uid).collection('products').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return CartCard(document: document);
            }).toList(),
          ),
        );
      },
    );
  }
}
