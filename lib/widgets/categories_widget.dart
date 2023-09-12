import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/store_provider.dart';
import 'package:food_delivery_app/screens/product_list_screen.dart';
import 'package:food_delivery_app/services/product_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class VendorCategories extends StatefulWidget {
  @override
  State<VendorCategories> createState() => _VendorCategoriesState();
}

class _VendorCategoriesState extends State<VendorCategories> {
  ProductServices _services = ProductServices();

  List _catList = [];

  @override
  void didChangeDependencies() {
    var _store = Provider.of<StoreProvider>(context);

    FirebaseFirestore.instance
        .collection('products')
        .where('seller.sellerUid', isEqualTo: _store.storedetails['uid'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _catList.add(doc['category']['mainCategory']);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);

    return FutureBuilder(
        future: _services.category.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong..'),
            );
          }
          if (_catList.length == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Container();
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                      ),
                      child: Center(
                        child: Text(
                          'Order By Category',
                          style: TextStyle(
                              shadows: <Shadow>[
                                Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 3.0,
                                    color: Colors.black)
                              ],
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                        ),
                      ),
                    ),
                  ),
                ),
                Wrap(
                  direction: Axis.horizontal,
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    return _catList.contains(document.data()['name'])
                        ? InkWell(
                            onTap: () {
                              _storeProvider
                                  .selectedCategory(document.data()['name']);
                              _storeProvider.selectedCategorySub(null);
                              pushNewScreenWithRouteSettings(
                                context,
                                settings:
                                    RouteSettings(name: ProductListScreen.id),
                                screen: ProductListScreen(),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  child: Card(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors.grey, width: .5)),
                                      child: Image.network(
                                        document.data()['image'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    document.data()['name'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text('');
                  }).toList(),
                ),
              ],
            ),
          );
        });
  }
}
