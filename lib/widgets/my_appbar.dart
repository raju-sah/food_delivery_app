import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/models/product_model.dart';
import 'package:food_delivery_app/screens/osmMapscreen.dart';
import 'package:food_delivery_app/widgets/search_card.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/location-provider.dart';
import '../screens/map_screen.dart';

class MyAppBar extends StatefulWidget {
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  String _location = '';
  String _address = '';

  static List<Product> products = [];
  String offer;

  @override
  void initState() {
    getPrefs();

    FirebaseFirestore.instance
        .collection('products')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          offer = ((doc.data()['comparedPrice'] - doc.data()['price']) /
                  doc.data()['comparedPrice'] *
                  100)
              .toStringAsFixed(0);
          products.add(Product(
              productName: doc['productName'],
              category: doc['category']['mainCategory'],
              price: doc['price'],
              comparedPrice: doc['comparedPrice'],
              image: doc['productImage'],
              shopName: doc['seller']['shopName'],
              document: doc));
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    products.clear();
    super.dispose();
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location');
    String address = prefs.getString('address');
    setState(() {
      _location = location;
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    return SliverAppBar(
      // now appbar is scrollable,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0.0,
      toolbarHeight: 70,
      floating: true,
      snap: true,
      title: FlatButton(
        onPressed: () {
          locationData.getCurrentPosition().then((value) {
            if (value != null) {
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: OpenStreetMapIntegration.id),
                screen: OpenStreetMapIntegration(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            } else {
              print('Permission not allowed');
            }
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                    child: Text(
                  _address == null
                      ? 'Press here to set Delivery location'
                      : _address,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )),
                Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),

      actions: [
        IconButton(
            icon: Icon(CupertinoIcons.search),
            onPressed: () {
              setState(() {});
              showSearch(
                context: context,
                delegate: SearchPage<Product>(
                  onQueryUpdate: (s) => print(s),
                  items: products,
                  searchLabel: 'Search Food Items',
                  suggestion: const Center(
                    child: Text('Filter Food Items by name, Category or Price'),
                  ),
                  failure: const Center(
                    child: Text('No Food Item found :('),
                  ),
                  filter: (product) => [
                    product.productName,
                    product.category,
                    product.price.toString(),
                  ],
                  builder: (product) => SearchCard(
                    offer: offer,
                    product: product,
                    document: product.document,
                  ),
                ),
              );
            })
      ],
    );
  }
}
