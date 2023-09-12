import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_delivery_app/providers/rating.provider.dart';
import 'package:food_delivery_app/services/user_services.dart';
import 'package:provider/provider.dart';

class RatingVendorScreen extends StatefulWidget {
  static const String id = 'vendor-rating';

  final DocumentSnapshot document;

  RatingVendorScreen({this.document});

  @override
  State<RatingVendorScreen> createState() => _RatingVendorScreenState();
}

class _RatingVendorScreenState extends State<RatingVendorScreen> {
  User user = FirebaseAuth.instance.currentUser;
  UserServices _user = UserServices();
  String userName = '';
  String userImage = '';
  String userMobile = '';
  String sellerId = '';
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
    sellerId = widget.document.id;

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
        .collection('vendors')
        .doc(widget.document.id)
        .snapshots()
        .listen((snapshot) {
      var vendorData = snapshot.data();
      if (vendorData != null && vendorData.containsKey('VendorRating')) {
        setState(() {
          ratingsAndComments = vendorData['VendorRating'];
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

    double averageRating = calculateAverageRating();

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Review Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Row(
              children: [
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
                        _provider.savevendorRatingAndCommentinUsers(
                          context: context,
                          rating: rating,
                          comment: comment.text,
                          vendor: widget.document.data(),
                        );
                        _provider.savevendorRatingAndCommentinVendors(
                          context: context,
                          comment: comment.text,
                          rating: rating,
                          userId: user.uid,
                          userName: userName,
                          sellerId: sellerId,
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
}
