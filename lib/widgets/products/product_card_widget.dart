import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/screens/favourite_screen.dart';
import 'package:food_delivery_app/screens/product_details_screen.dart';
import 'package:food_delivery_app/widgets/cart/counter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ProductCard extends StatefulWidget {
  final DocumentSnapshot document;
  ProductCard(this.document);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  User user = FirebaseAuth.instance.currentUser;
  bool isButtonPressed = false;
  bool isProductInFavorites = false;

  StreamSubscription<QuerySnapshot>
      _subscription; // Subscription for real-time updates

  @override
  void initState() {
    super.initState();
    checkIfProductInFavorites();
  }

  void checkIfProductInFavorites() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    Query query = _favourite
        .where('customerId', isEqualTo: user.uid)
        .where('product.productId', isEqualTo: widget.document.id);

    _subscription = query.snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          isButtonPressed = true;
          isProductInFavorites = true;
        });
      } else {
        setState(() {
          isButtonPressed = false;
          isProductInFavorites = false;
        });
      }
    });
  }

  void _handleButtonPress() {
    setState(() {
      isButtonPressed = !isButtonPressed;
    });

    if (isButtonPressed) {
      String favoriteId =
          FirebaseFirestore.instance.collection('favourites').doc().id;
      saveForLater(favoriteId).then((value) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => FavouriteScreen(
        //       userId: user.uid,
        //     ),
        //   ),
        // );
        EasyLoading.showSuccess('Saved to Favorites Successfully');
      });
    } else {
      deleteFromFavorites().then((value) {
        EasyLoading.showSuccess('Removed from Favorites Successfully');
      });
    }
  }

  @override
  void dispose() {
    _subscription
        ?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String offer = ((widget.document.data()['comparedPrice'] -
                widget.document.data()['price']) /
            widget.document.data()['comparedPrice'] *
            100)
        .toStringAsFixed(0);
    return Container(
      height: 160,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Colors.grey[300]))),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
        child: Row(
          children: [
            Stack(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      pushNewScreenWithRouteSettings(
                        context,
                        settings: RouteSettings(name: ProductDetailsScreen.id),
                        screen: ProductDetailsScreen(
                          document: widget.document,
                        ),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          child: Image.network(
                            widget.document.data()['productImage'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.document.data()['comparedPrice'] > 0)
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 3, bottom: 3),
                      child: Text(
                        '$offer % OFF',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.document.data()['productName'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            Text(
                              '\Rs.${widget.document.data()['price'].toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            if (widget.document.data()['comparedPrice'] > 0)
                              Text(
                                '\Rs.${widget.document.data()['comparedPrice'].toStringAsFixed(0)}',
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width - 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isButtonPressed
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isButtonPressed
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: _handleButtonPress,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              CounterForCard(widget.document),
                            ],
                          )),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> saveForLater(String favoriteId) {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;
    return _favourite.add({
      'favoriteId': favoriteId,
      'product': widget.document.data(),
      'customerId': user.uid,
      'timestamp': DateTime.now().toString(),
    });
  }

  Future<void> deleteFromFavorites() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;

    // Query the collection for the document matching the user and product
    Query query = _favourite
        .where('customerId', isEqualTo: user.uid)
        .where('product.productId', isEqualTo: widget.document.id);

    // Delete the document
    return query.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Document found, delete it
        return snapshot.docs.first.reference.delete();
      }
    });
  }
}
