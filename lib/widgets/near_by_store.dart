import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:food_delivery_app/constants.dart';
import 'package:food_delivery_app/providers/cart_provider.dart';
import 'package:food_delivery_app/providers/store_provider.dart';
import 'package:food_delivery_app/screens/vendor_home_screen.dart';
import 'package:food_delivery_app/services/store_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class NearByStores extends StatefulWidget {
  @override
  _NearByStoresState createState() => _NearByStoresState();
}

class _NearByStoresState extends State<NearByStores> {
  StoreServices _storeServices = StoreServices();
  PaginateRefreshedChangeListener refreshedChangeListener =
      PaginateRefreshedChangeListener();

  @override
  Widget build(BuildContext context) {
    final _storeData = Provider.of<StoreProvider>(context);
    final _cart = Provider.of<CartProvider>(context);
    _storeData.getUserLocationData(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(_storeData.userLatitude,
          _storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeServices.getNearByStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (!snapShot.hasData)
            return Center(child: CircularProgressIndicator());
          List shopDistance = [];
          for (int i = 0; i <= snapShot.data.docs.length - 1; i++) {
            var distance = Geolocator.distanceBetween(
                _storeData.userLatitude,
                _storeData.userLongitude,
                snapShot.data.docs[i]['location'].latitude,
                snapShot.data.docs[i]['location'].longitude);
            var distanceInKm = distance / 1000;
            shopDistance.add(distanceInKm);
          }
          shopDistance
              .sort(); //this will sort with nearest distance.if nearest distance is more than 20, that menas no restro/hotel near by.

          SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                _cart.getDistance(shopDistance[0]);
              }));
          if (shopDistance[0] > 20) {
            return Container(
              color: Colors.red,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '**That\s all folks**',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Image.asset(
                    'images/ct.png',
                    color: Colors.black12,
                  ),
                  Positioned(
                    right: 10.0,
                    top: 80,
                    child: Container(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Made by:',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'COSMODEVS',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Anton',
                                letterSpacing: 2,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RefreshIndicator(
                  child: PaginateFirestore(
                    bottomLoader: SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                    header: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 8, right: 8, top: 20),
                          child: Text(
                            'All Nearby Restaurants/Hotels',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 10),
                          child: Text(
                            'Findout delicious foods near you',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilderType: PaginateBuilderType.listView,
                    itemBuilder: (index, context, document) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: InkWell(
                        onTap: () {
                          _storeData.getSelectedStore(
                              document, getDistance(document['location']));
                          pushNewScreenWithRouteSettings(
                            context,
                            settings: RouteSettings(name: VendorHomeScreen.id),
                            screen: VendorHomeScreen(),
                            withNavBar: true,
                            pageTransitionAnimation:
                                PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 110,
                              child: Card(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    document['imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      document.data()['shopName'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    document.data()['dialog'],
                                    style: kStoreCardStyle,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    child: Text(
                                      document.data()['address'],
                                      style: kStoreCardStyle,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    '${getDistance(document['location'])}Km',
                                    overflow: TextOverflow.ellipsis,
                                    style: kStoreCardStyle,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    //this to show rating ... will work on it later
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        '3.2',
                                        style: kStoreCardStyle,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    query: _storeServices.getNearByStorePagination(),
                    listeners: [refreshedChangeListener],
                    footer: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Container(
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                '**That\s all folks**',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Image.asset(
                              'images/ct.png',
                              color: Colors.black12,
                            ),
                            Positioned(
                              right: 10.0,
                              top: 80,
                              child: Container(
                                width: 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Made by:',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      'COSMODEVS',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Anton',
                                          letterSpacing: 2,
                                          color: Colors.deepOrangeAccent),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  onRefresh: () async {
                    refreshedChangeListener.refreshed = true;
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
