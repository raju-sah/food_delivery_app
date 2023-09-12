// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class SaveForLater extends StatefulWidget {
//   final DocumentSnapshot document;

//   SaveForLater(this.document);

//   @override
//   _SaveForLaterState createState() => _SaveForLaterState();
// }

// class _SaveForLaterState extends State<SaveForLater> {
//   bool _isLoading = false;
//   bool _isSaved = false;

//   @override
//   Widget build(BuildContext context) {
//     User user = FirebaseAuth.instance.currentUser;
//     return InkWell(
//       onTap: () {
//         if (!_isLoading && !_isSaved) {
//           setState(() {
//             _isLoading = true;
//           });

//           saveForLater().then((value) {
//             setState(() {
//               _isLoading = false;
//               _isSaved = true;
//             });

//             Future.delayed(Duration(seconds: 2), () {
//               setState(() {
//                 _isSaved = false;
//               });
//             });
//           });
//         }
//       },
//       child: Container(
//         color: _isSaved ? Colors.red[400] : Colors.grey[800],
//         height: 56,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   CupertinoIcons.bookmark,
//                   color: Colors.white,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 if (!_isLoading)
//                   Text(
//                     _isSaved ? 'Save for Later' : 'Already in Favorites',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 if (_isLoading)
//                   SizedBox(
//                     width: 10,
//                   ),
//                 if (_isLoading)
//                   SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       strokeWidth: 2.0,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> saveForLater() async {
//     CollectionReference _favorites =
//         FirebaseFirestore.instance.collection('favorites');
//     User user = FirebaseAuth.instance.currentUser;

//     // Check if the product already exists in the user's favorites
//     QuerySnapshot querySnapshot = await _favorites
//         .where('product.productId',
//             isEqualTo: widget.document.data()['productId'])
//         .where('product.productName',
//             isEqualTo: widget.document.data()['productName'])
//         .where('customerId', isEqualTo: user.uid)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       // Product already exists in favorites
//       return;
//     } else {
//       // Product doesn't exist, save it to favorites
//       await _favorites.add({
//         'product': widget.document.data(),
//         'customerId': user.uid,
//       });
//     }
//   }
// }
