import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatementScreen extends StatefulWidget {
  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  User user = FirebaseAuth.instance.currentUser;
  Future<int> calculateTotalRewardPoints() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .get();

    int totalPoints = 0;

    for (DocumentSnapshot document in querySnapshot.docs) {
      if (document.exists && document.data().containsKey('rewardPoints')) {
        totalPoints += document.data()['rewardPoints'] ?? 0;
      }
    }

    return totalPoints;
  }

  String formatTimestamp(String timestamp) {
    // Convert timestamp string to DateTime
    DateTime dateTime = DateTime.parse(timestamp);

    // Define the date and time format you desire
    DateFormat dateFormat = DateFormat('yyyy MMMM dd');
    DateFormat timeFormat = DateFormat('hh:mm a');

    // Format the date and time using the defined format
    String formattedDate = dateFormat.format(dateTime);
    String formattedTime = timeFormat.format(dateTime);

    // Return the formatted date and time string
    return '$formattedDate, $formattedTime';
  }

  Future<List<DocumentSnapshot>> getOrderDocuments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.history,
              size: 30,
            ),
            SizedBox(
              width: 4,
            ),
            Text('Reward History'),
          ],
        ),
        actions: [
          FutureBuilder<int>(
            future: calculateTotalRewardPoints(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError) {
                return Container();
              } else {
                int totalRewardPoints = snapshot.data ?? 0;
                return Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard_outlined,
                              size: 25,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '$totalRewardPoints',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Total Reward Points',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: getOrderDocuments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> orderDocuments = snapshot.data;
            return ListView.builder(
              itemCount: orderDocuments.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = orderDocuments[index];
                String orderId = document['orderId'];
                List<dynamic> products = document['products'];
                String timestamp = document['timestamp'];
                double total = document['total'];
                String shopName = document['shopName'];
                int rewardpoints = document['rewardPoints'];
                String timestampString = formatTimestamp(timestamp);

                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '$timestampString',
                        style: TextStyle(fontSize: 16),
                      ),
                      Card(
                        shadowColor: Colors.deepOrangeAccent,
                        color: Colors.white54,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Order ID: $orderId'),
                                        Text(
                                          'shop Name: $shopName',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.green,
                                    size: 33,
                                  ),
                                  Text(
                                    '$rewardpoints',
                                    style: TextStyle(
                                        color: Colors.green, fontSize: 16),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> product =
                                    products[index] as Map<String, dynamic>;
                                String productId = product['productId'];
                                String productImage = product['productImage'];
                                String productName = product['productName'];

                                return ListTile(
                                  leading: Image.network(
                                    productImage,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Product ID: $productId'),
                                      Text('Product Name: $productName'),
                                      Text('Total Price: $total'),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
