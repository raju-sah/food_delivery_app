import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/providers/rating.provider.dart';
import 'package:food_delivery_app/services/user_services.dart';
import 'package:food_delivery_app/widgets/products/bottom_sheet_container.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String id = 'product-details-screen';

  final DocumentSnapshot document;

  ProductDetailsScreen({this.document});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  User user = FirebaseAuth.instance.currentUser;
  UserServices _user = UserServices();
  String userName = '';
  String userImage = '';
  String userMobile = '';
  String productId = '';

  double rating = 0.0;
  var comment = TextEditingController();
  List<dynamic> ratingsAndComments = [];

  @override
  void initState() {
    _user.getUserById(user.uid).then((value) {
      if (mounted) {
        setState(() {
          String firstName = value.data()['firstName'];
          String lastName = value.data()['lastName'];
          userImage = value.data()['profileImage'];
          userMobile = value.data()['number'];
          userName =
              '$firstName $lastName'; // Combine the first name and last name
          comment.text = value.data()['comment'];
          rating = value.data()['rating'] ?? 0.0;
        });
      }
    });
    productId = widget.document.id;

    super.initState();
    fetchRatingsAndComments();
  }

  StreamSubscription<DocumentSnapshot> ratingsAndCommentsSubscription;

  @override
  void dispose() {
    ratingsAndCommentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchRatingsAndComments() async {
    // Listen for changes in the 'FoodRating' field using a stream
    ratingsAndCommentsSubscription = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.document.id)
        .snapshots()
        .listen((snapshot) {
      var productData = snapshot.data();
      if (productData != null && productData.containsKey('FoodRating')) {
        setState(() {
          ratingsAndComments = productData['FoodRating'];
        });
      }
    });
  }

  double calculateAverageRating() {
    if (ratingsAndComments.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;
    for (var ratingData in ratingsAndComments) {
      totalRating += ratingData['rating'];
    }

    return totalRating / ratingsAndComments.length;
  }

  @override
  Widget build(BuildContext context) {
    var _provider = Provider.of<RatingProvider>(context);
    var offer = ((widget.document.data()['comparedPrice'] -
            widget.document.data()['price']) /
        widget.document.data()['comparedPrice'] *
        100);

    double averageRating = calculateAverageRating();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomSheet: BottomSheetContainer(widget.document),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(
              widget.document.data()['productName'],
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  '\Rs.${widget.document.data()['price'].toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                if (offer > 0)
                  Text(
                    '\Rs.${widget.document.data()['comparedPrice'].toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough),
                  ),
                SizedBox(
                  width: 10,
                ),
                if (offer > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 3, bottom: 3),
                      child: Text(
                        '${offer.toStringAsFixed(0)}% OFF',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12),
                      ),
                    ),
                  ),
                if (averageRating > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        RatingBar.builder(
                          initialRating: averageRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 20,
                          ignoreGestures: true,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.orange,
                          ),
                          onRatingUpdate: (value) {},
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Center(
              child: Container(
                height: 300,
                width: 300,
                child: Image.network(widget.document.data()['productImage']),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 6,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'About This Product',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
              child: ExpandableText(
                widget.document.data()['description'],
                expandText: 'View more',
                collapseText: 'View less',
                maxLines: 2,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Other Food Info',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hotel/Restaurant : ${widget.document.data()['seller']['shopName']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(color: Colors.grey[400]),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Review Food',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Divider(color: Colors.grey[400]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate the food:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.star,
                            color: rating >= 1 ? Colors.orange : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 1.0;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star,
                            color: rating >= 2 ? Colors.orange : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 2.0;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star,
                            color: rating >= 3 ? Colors.orange : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 3.0;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star,
                            color: rating >= 4 ? Colors.orange : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 4.0;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star,
                            color: rating >= 5 ? Colors.orange : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 5.0;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Leave a comment:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: comment,
                    decoration: InputDecoration(
                      hintText: 'Enter your comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrangeAccent,
                    ),
                    onPressed: () {
                      if (rating != null && comment != null) {
                        EasyLoading.show(
                            status: 'Saving Rating and Comment...');
                        _provider.saveRatingAndCommentinUsers(
                          context: context,
                          rating: rating,
                          comment: comment.text,
                          product: widget.document.data(),
                        );
                        _provider.saveRatingAndCommentinProducts(
                          context: context,
                          comment: comment.text,
                          rating: rating,
                          userId: user.uid,
                          userName: userName,
                          productId: productId,
                          userImage: userImage,
                          userMobile: userMobile,
                        );
                        EasyLoading.dismiss();
                      }
                      if (rating == null && comment == null) {
                        _provider.alertDialog(
                          context: context,
                          title: 'Rating',
                          content: 'Please Rate this Food',
                        );
                      }
                    },
                    child: Text(
                      'Submit',
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Ratings and Comments',
                    style: TextStyle(fontSize: 20),
                  ),
                  Divider(color: Colors.grey[400]),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: ratingsAndComments.length,
                    itemBuilder: (context, index) {
                      var ratingData = ratingsAndComments[index];
                      var userName = ratingData['userName'];
                      var userImage = ratingData['userImage'];
                      var rating = ratingData['rating'];
                      var comment = ratingData['comment'];

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userImage),
                              radius: 20,
                            ),
                            title: Text(
                              userName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                RatingBar.builder(
                                  initialRating: rating,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemSize: 16,
                                  ignoreGestures: true,
                                  itemPadding:
                                      EdgeInsets.symmetric(horizontal: 0),
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                  ),
                                  onRatingUpdate: (value) {},
                                ),
                                SizedBox(height: 4),
                                Text(
                                  comment,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey[400],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveForLater() {
    CollectionReference _favourite =
        FirebaseFirestore.instance.collection('favourites');
    User user = FirebaseAuth.instance.currentUser;
    return _favourite.add({
      'product': widget.document.data(),
      'customerId': user.uid,
    });
  }
}
