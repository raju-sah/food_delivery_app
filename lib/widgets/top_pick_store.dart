import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/store_provider.dart';
import 'package:food_delivery_app/screens/vendor_home_screen.dart';
import 'package:food_delivery_app/services/store_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TopPickStore extends StatefulWidget {
  @override
  _TopPickStoreState createState() => _TopPickStoreState();
}

class _TopPickStoreState extends State<TopPickStore> {
  @override
  Widget build(BuildContext context) {
    StoreServices _storeServices = StoreServices();

    final _storeData = Provider.of<StoreProvider>(context);
    _storeData.getUserLocationData(context);

    String getDistance(location) {
      var distance = Geolocator.distanceBetween(_storeData.userLatitude,
          _storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance / 1000;
      return distanceInKm.toStringAsFixed(2);
    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeServices.getTopPickedStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
          if (!snapShot.hasData)
            return Center(child: CircularProgressIndicator());
          //need to confirm even no restaurant/hotel near by or not
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
          if (shopDistance[0] > 20) {
            return Padding(
              padding: const EdgeInsets.only(
                  bottom: 30, top: 30, left: 20, right: 20),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    'Currently we are not servicing in your area, Please try later or try another location',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.black54, fontSize: 20),
                  ),
                ),
              ),
            );
          }
          return Container(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 20),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 30,
                          child: Image.asset('images/like.gif'),
                        ),
                        Text(
                          'Top Picked Restaurants For You',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Flexible(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children:
                            snapShot.data.docs.map((DocumentSnapshot document) {
                          if (double.parse(getDistance(document['location'])) <=
                              20) {
                            //show the restaurant/Hotel only with in 20km
                            return InkWell(
                              onTap: () {
                                _storeData.getSelectedStore(document,
                                    getDistance(document['location']));
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings:
                                      RouteSettings(name: VendorHomeScreen.id),
                                  screen: VendorHomeScreen(),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  width: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Card(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.network(
                                                document['imageUrl'],
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                      ),
                                      Container(
                                        height: 35,
                                        child: Text(
                                          document['shopName'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${getDistance(document['location'])}Km',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // if no restaurnats/hotel
                            return Container();
                          }
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
