import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/screens/Reward/reward_point_screen.dart';
import 'package:food_delivery_app/screens/homeScreen.dart';
import 'package:food_delivery_app/screens/my_orders_screen.dart';
import 'package:food_delivery_app/screens/osmMapscreen.dart';
import 'package:food_delivery_app/screens/payment/credit_card_list.dart';
import 'package:food_delivery_app/screens/profile_update_screen.dart';
import 'package:food_delivery_app/screens/welcome_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const String id = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int rewardPoints = 0;
  User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    _getUserRewardPoints();
    super.initState();
  }

  void _getUserRewardPoints() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          rewardPoints = snapshot.data()['rewardPoints'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    var locationData = Provider.of<LocationProvider>(context);
    User user = FirebaseAuth.instance.currentUser;
    userDetails.getUserDetails();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'FoodiesHub',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          SizedBox(
            width: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => RewardPointsPage()),
                // );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    color: Colors.black,
                    size: 33,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Reward Points: $rewardPoints',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      body: userDetails.snapshot == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'MY ACCOUNT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        color: Colors.deepOrangeAccent,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 42,
                                  backgroundColor: Colors.grey,
                                  child: CircleAvatar(
                                    radius: 41,
                                    backgroundImage: userDetails.snapshot
                                                .data()['profileImage'] !=
                                            null
                                        ? NetworkImage(userDetails.snapshot
                                            .data()['profileImage'])
                                        : AssetImage('images/profil.png'),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 70,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        userDetails.snapshot
                                                    .data()['firstName'] !=
                                                null
                                            ? '${userDetails.snapshot.data()['firstName']} ${userDetails.snapshot.data()['lastName']}'
                                            : 'Save Your Name',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (userDetails.snapshot
                                              .data()['email'] !=
                                          null)
                                        Text(
                                          '${userDetails.snapshot.data()['email']}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      Text(
                                        user.phoneNumber,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (userDetails.snapshot != null)
                              ListTile(
                                tileColor: Colors.white,
                                leading: Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                subtitle: Text(
                                  userDetails.snapshot.data()['address'],
                                  maxLines: 5,
                                ),
                                trailing: SizedBox(
                                  width: 80,
                                  child: OutlineButton(
                                    borderSide:
                                        BorderSide(color: Colors.redAccent),
                                    child: Text(
                                      'Change',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                    onPressed: () {
                                      EasyLoading.show(
                                          status: 'Please Wait...');
                                      locationData
                                          .getCurrentPosition()
                                          .then((value) {
                                        if (value != null) {
                                          EasyLoading.dismiss();
                                          pushNewScreenWithRouteSettings(
                                            context,
                                            settings: RouteSettings(
                                                name: OpenStreetMapIntegration
                                                    .id),
                                            screen: OpenStreetMapIntegration(),
                                            withNavBar: false,
                                            pageTransitionAnimation:
                                                PageTransitionAnimation
                                                    .cupertino,
                                          );
                                        } else {
                                          EasyLoading.dismiss();
                                          print('Permission not allowed');
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 10.0,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(name: UpdateProfile.id),
                              screen: UpdateProfile(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    onTap: () {
                      pushNewScreenWithRouteSettings(
                        context,
                        screen: MyOrders(),
                        settings: RouteSettings(name: MyOrders.id),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    leading: Icon(Icons.history),
                    title: Text('My Orders'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      pushNewScreenWithRouteSettings(
                        context,
                        screen: RewardPointsPage(),
                        settings: RouteSettings(name: RewardPointsPage.id),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    leading: Icon(Icons.card_giftcard_outlined),
                    title: Text('Reward Points'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      pushNewScreenWithRouteSettings(
                        context,
                        screen: CreditCardList(),
                        settings: RouteSettings(name: CreditCardList.id),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    leading: Icon(Icons.credit_card),
                    title: Text('Manage Credit Cards'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.comment_outlined),
                    title: Text('My Ratings & Reviews'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications_none),
                    title: Text('My Notifications'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.power_settings_new),
                    title: Text('Logout'),
                    horizontalTitleGap: 2,
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      pushNewScreenWithRouteSettings(
                        context,
                        settings: RouteSettings(name: WelcomeScreen.id),
                        screen: WelcomeScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
