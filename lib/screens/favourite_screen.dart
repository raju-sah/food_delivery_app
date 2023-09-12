import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavouriteScreen extends StatefulWidget {
  final String userId;

  FavouriteScreen({this.userId});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _favorites;
  List<bool> _isSelected = [];
  bool _isSelectionMode = false;

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

  @override
  void initState() {
    super.initState();
    _subscribeToFavorites();
  }

  void _subscribeToFavorites() {
    _firestoreService.getFavoritesStream(widget.userId).listen((favorites) {
      setState(() {
        _favorites = favorites;
        _isSelected = List<bool>.filled(favorites.length, false);
      });
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      _isSelected[index] = !_isSelected[index];
    });
  }

  void _selectAll() {
    setState(() {
      _isSelected = List<bool>.filled(_favorites.length, true);
    });
  }

  void _deleteSelected() {
    final selectedIndexes = <int>[];
    for (var i = 0; i < _isSelected.length; i++) {
      if (_isSelected[i]) {
        selectedIndexes.add(i);
      }
    }

    for (var i = selectedIndexes.length - 1; i >= 0; i--) {
      final selectedIndex = selectedIndexes[i];
      final favorite = _favorites[selectedIndex];
      final favoriteId = favorite['favoriteId'] as String;
      _firestoreService.deleteFavorite(favoriteId);
    }

    setState(() {
      _isSelectionMode = false;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.black,
              size: 30,
            ),
            SizedBox(
              width: 5,
            ),
            Text('Favourites'),
          ],
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteSelected,
                ),
              ]
            : [],
      ),
      body: GestureDetector(
        onTap: _exitSelectionMode,
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: getOrderDocuments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData && snapshot.data.isNotEmpty) {
              _favorites = snapshot.data.map((doc) => doc.data()).toList();
              _isSelected = List<bool>.filled(_favorites.length, false);

              return ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final favorite = _favorites[index];
                  final timestamp = favorite['timestamp'] as String;
                  String timestampString = formatTimestamp(timestamp);
                  final product = favorite['product'] as Map<String, dynamic>;
                  final seller = product['seller'] as Map<String, dynamic>;

                  final productName = product['productName'] as String;
                  final productImage = product['productImage'] as String;
                  final price =
                      (product['price'] as num).toDouble().toStringAsFixed(0);
                  final comparedPrice = (product['comparedPrice'] as num)
                      .toDouble()
                      .toStringAsFixed(0);
                  final shopName = seller['shopName'] as String;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        ListTile(
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelection(index);
                            }
                          },
                          onLongPress: () {
                            setState(() {
                              _isSelectionMode = true;
                            });
                          },
                          leading: _isSelectionMode
                              ? Checkbox(
                                  value: _isSelected[index],
                                  onChanged: (value) {
                                    _toggleSelection(index);
                                  },
                                )
                              : null,
                          title: Text(
                            ' $timestampString',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Container(
                            height: 110,
                            child: Card(
                              shadowColor: Colors.deepOrangeAccent,
                              color: Colors.white54,
                              child: Column(
                                // crossAxisAlignment:
                                //     CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Restaurant: $shopName',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Image.network(
                                      productImage,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(productName),
                                        Row(
                                          children: [
                                            Text('Rs.$price'),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              'Rs.$comparedPrice',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No favorites found'));
            }
          },
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> getOrderDocuments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('favourites')
        .where('customerId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs;
  }
}

class FirestoreService {
  final CollectionReference favoritesCollection =
      FirebaseFirestore.instance.collection('favourites');

  Stream<List<Map<String, dynamic>>> getFavoritesStream(String userId) {
    return favoritesCollection
        .where('customerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'favoriteId': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList());
  }

  Future<void> deleteFavorite(String favoriteId) {
    return favoritesCollection.doc(favoriteId).delete();
  }
}
