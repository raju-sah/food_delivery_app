import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/providers/cart_provider.dart';
import 'package:food_delivery_app/providers/coupon_provider.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/providers/order_provider.dart';
import 'package:food_delivery_app/screens/osmMapscreen.dart';
import 'package:food_delivery_app/screens/payment/payment_home.dart';
import 'package:food_delivery_app/screens/profile_screen.dart';
import 'package:food_delivery_app/screens/profile_update_screen.dart';
import 'package:food_delivery_app/services/cart_services.dart';
import 'package:food_delivery_app/services/order_services.dart';
import 'package:food_delivery_app/services/store_services.dart';
import 'package:food_delivery_app/services/user_services.dart';
import 'package:food_delivery_app/widgets/cart/cart_list.dart';
import 'package:food_delivery_app/widgets/cart/cod_toggle.dart';
import 'package:food_delivery_app/widgets/cart/coupon_widget.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Reward/reward_point_screen.dart';
import 'map_screen.dart';

class CartScreen extends StatefulWidget {
  static const String id = 'cart-screen';

  final DocumentSnapshot document;

  CartScreen({this.document});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  StoreServices _store = StoreServices();
  UserServices _userService = UserServices();
  OrderServices _orderServices = OrderServices();
  CartServices _cartServices = CartServices();
  User user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot doc;
  var textStyle = TextStyle(color: Colors.grey);
  int serviceCharge = 40;
  int deliveryFee = 90;
  String _location = '';
  String _address = '';
  bool _loading = false;
  bool _checkingUser = false;
  double discount = 0;
  int rewardPoints = 0;
  int pointsToAdd = 0;

  void _updateRewardPoints(double payable) {
    if (payable <= 1000) {
      pointsToAdd = 10;
    } else if (payable > 1000 && payable <= 4000) {
      pointsToAdd = 20;
    } else if (payable > 4000) {
      pointsToAdd = 50;
    }

    // Update reward points in the user's profile
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'rewardPoints': FieldValue.increment(pointsToAdd)});

    setState(() {
      rewardPoints += pointsToAdd;
    });
  }

  @override
  void initState() {
    getPrefs();
    _store.getShopDetails(widget.document.data()['sellerUid']).then((value) {
      setState(() {
        doc = value;
      });
    });
    _getUserRewardPoints();
    super.initState();
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
    final locationData = Provider.of<LocationProvider>(context);
    var _cartProvider = Provider.of<CartProvider>(context);
    var userDetails = Provider.of<AuthProvider>(context);
    var _coupon = Provider.of<CouponProvider>(context);
    userDetails.getUserDetails().then((value) {
      double subTotal = _cartProvider.subTotal;
      double discountRate = _coupon.discountRate / 100;
      setState(() {
        discount = subTotal * discountRate;
      });
    });

    var _payable =
        _cartProvider.subTotal + deliveryFee + serviceCharge - discount;

    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey[200],
      bottomSheet: userDetails.snapshot == null
          ? Container()
          : Container(
              height: 170,
              color: Colors.deepOrangeAccent,
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Deliver to this address:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      _loading = true;
                                    });
                                    locationData
                                        .getCurrentPosition()
                                        .then((value) {
                                      setState(() {
                                        _loading = false;
                                      });
                                      if (value != null) {
                                        pushNewScreenWithRouteSettings(
                                          context,
                                          settings: RouteSettings(
                                            name: OpenStreetMapIntegration.id,
                                          ),
                                          screen: OpenStreetMapIntegration(),
                                          withNavBar: false,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      } else {
                                        setState(() {
                                          _loading = false;
                                        });
                                        print('Permission not allowed');
                                      }
                                    });
                                  },
                                  child: _loading
                                      ? CircularProgressIndicator()
                                      : Icon(
                                          Icons.edit_outlined,
                                          color: Colors.deepOrangeAccent,
                                          size: 25,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          if (userDetails.snapshot.data()['firstName'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_address',
                                  maxLines: 3,
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: 'Name: ',
                                    children: [
                                      TextSpan(
                                        text:
                                            '${userDetails.snapshot.data()['firstName']} ${userDetails.snapshot.data()['lastName']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                            // Apply your desired styles here
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (userDetails.snapshot.data()['firstName'] == null)
                            Text(
                              ' $_address',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\Rs. ${_payable.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '(Including All Taxes)',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          RaisedButton(
                            child: _checkingUser
                                ? CircularProgressIndicator()
                                : Text(
                                    'CHECKOUT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            color: Colors.black,
                            onPressed: () {
                              EasyLoading.show(status: 'Please Wait...');
                              _userService.getUserById(user.uid).then((value) {
                                if (value.data()['firstName'] == null) {
                                  EasyLoading.dismiss();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Complete Your Profile'),
                                        content: Text(
                                            'Please complete your profile to checkout.'),
                                        actions: [
                                          FlatButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              // Navigate to the UpdateProfile screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdateProfile(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  EasyLoading.dismiss();
                                  // Get the current reward points value

                                  if (_cartProvider.cod == false) {
                                    //pay online
                                    orderProvider.totalAmount(_payable);
                                    Navigator.pushNamed(
                                      context,
                                      PaymentHome.id,
                                    ).whenComplete(() {
                                      if (orderProvider.success == true) {
                                        String orderId = FirebaseFirestore
                                            .instance
                                            .collection('orders')
                                            .doc()
                                            .id;
                                        _saveOrder(
                                          _cartProvider,
                                          _payable,
                                          _coupon,
                                          orderProvider,
                                          orderId,
                                        );
                                      }
                                    });
                                  } else {
                                    //cash on delivery
                                    String orderId = FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc()
                                        .id;
                                    _saveOrder(
                                      _cartProvider,
                                      _payable,
                                      _coupon,
                                      orderProvider,
                                      orderId,
                                    );
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.document.data()['shopName'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${_cartProvider.cartQty} ${_cartProvider.cartQty > 1 ? 'Items, ' : 'Item, '}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'To Pay: \Rs. ${_payable.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RewardPointsPage()),
                      );
                    },
                    child: Container(
                      color: Colors.deepOrangeAccent,
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
                                fontSize: 14,
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
                ),
              ],
            ),
          ];
        },
        body: doc == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _cartProvider.cartQty > 0
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  tileColor: Colors.white,
                                  leading: Container(
                                    height: 60,
                                    width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        doc.data()['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(doc.data()['shopName']),
                                  subtitle: Text(
                                    doc.data()['address'],
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                CodToggleSwitch(),
                                Divider(
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                          CartList(
                            document: widget.document,
                          ),
                          //coupon codes
                          CouponWidget(doc.data()['uid']),
                          //bill details card
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              top: 4,
                              bottom: 80,
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bill Details',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Subtotal'),
                                          Text(
                                            '\Rs. ${_cartProvider.subTotal.toStringAsFixed(0)}',
                                            style: textStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Delivery Fee'),
                                          Text(
                                            '\Rs. $deliveryFee',
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Service Charge'),
                                          Text(
                                            '\Rs. $serviceCharge',
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Discount',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '\Rs. $discount',
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      Divider(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Payable Amount',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '\Rs. ${_payable.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
      ),
    );
  }

  void _saveOrder(
    CartProvider cartProvider,
    payable,
    CouponProvider coupon,
    OrderProvider orderProvider,
    String orderId,
  ) {
    _userService.getUserById(user.uid).then((value) {
      var userData = value.data();

      // Access the vendor's data using the sellerUid
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.document.data()['sellerUid'])
          .get()
          .then((vendorDoc) {
        var vendorData = vendorDoc.data();

        // Calculate the new reward points to add
        int newPointsToAdd = 0;
        if (payable <= 1000) {
          newPointsToAdd = 10;
        } else if (payable > 1000 && payable <= 4000) {
          newPointsToAdd = 20;
        } else if (payable > 4000) {
          newPointsToAdd = 50;
        }
        int accumulatedRewardPoints = newPointsToAdd;

        _orderServices.saveOrder({
          'orderId': orderId,
          'products': cartProvider.cartList,
          'userId': user.uid,
          'userphone': userData['number'],
          'userName': userData['firstName'] + ' ' + userData['lastName'],
          'userImage': userData['profileImage'],
          'useremail': userData['email'],
          'useraddress': _address,
          'deliveryFee': deliveryFee,
          'rewardPoints': accumulatedRewardPoints,
          'servicecharge': serviceCharge,
          'total': payable,
          'discount': discount.toStringAsFixed(0),
          'cod': cartProvider.cod,
          'discountCode':
              coupon.document == null ? null : coupon.document.data()['title'],
          'shopName': vendorData['shopName'],
          'sellerId': vendorData['uid'],
          'shopmobile': vendorData['mobile'],
          'shopaddress': vendorData['address'],
          'shop': vendorData['imageUrl'],
          'shopemail': vendorData['email'],
          'timestamp': DateTime.now().toString(),
          'orderStatus': 'Ordered',
          'deliveryBoy': {
            'id': '',
            'name': '',
            'phone': '',
            'address': '',
            'image': '',
          },
        }).then((value) {
          //after submitting, need to clear cart screen
          orderProvider.success == false;
          _cartServices.deleteCart().then((value) {
            _cartServices.checkData().then((value) {
              EasyLoading.showSuccess('Your Order is submitted');
              // Update reward points based on payable amount
              _updateRewardPoints(payable);
              Navigator.pop(context);
            });
          });
        });
      });
    });
  }
}
