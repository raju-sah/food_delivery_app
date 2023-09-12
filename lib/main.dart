import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/providers/Profile_provider.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/providers/cart_provider.dart';
import 'package:food_delivery_app/providers/coupon_provider.dart';
import 'package:food_delivery_app/providers/location-provider.dart';
import 'package:food_delivery_app/providers/order_provider.dart';
import 'package:food_delivery_app/providers/rating.provider.dart';
import 'package:food_delivery_app/providers/store_provider.dart';
import 'package:food_delivery_app/screens/cart_screen.dart';
import 'package:food_delivery_app/screens/landing_screen.dart';
import 'package:food_delivery_app/screens/login_screen.dart';
import 'package:food_delivery_app/screens/main_screen.dart';
import 'package:food_delivery_app/screens/map_screen.dart';
import 'package:food_delivery_app/screens/my_orders_screen.dart';
import 'package:food_delivery_app/screens/osmMapscreen.dart';
import 'package:food_delivery_app/screens/payment/create_new_card_screen.dart';
import 'package:food_delivery_app/screens/payment/credit_card_list.dart';
import 'package:food_delivery_app/screens/payment/payment_home.dart';
import 'package:food_delivery_app/screens/payment/stripe/existing-cards.dart';
import 'package:food_delivery_app/screens/product_details_screen.dart';
import 'package:food_delivery_app/screens/product_list_screen.dart';
import 'package:food_delivery_app/screens/profile_home_screen.dart';
import 'package:food_delivery_app/screens/profile_screen.dart';
import 'package:food_delivery_app/screens/profile_update_screen.dart';
import 'package:food_delivery_app/screens/vendor_home_screen.dart';
import 'package:food_delivery_app/screens/vendor_rating.dart';
import 'package:food_delivery_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

import 'screens/homeScreen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CouponProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RatingProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color(0xFFFF6E40), fontFamily: 'Lato'),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        MapScreen.id: (context) => MapScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        LandingScreen.id: (context) => LandingScreen(),
        MainScreen.id: (context) => MainScreen(),
        VendorHomeScreen.id: (context) => VendorHomeScreen(),
        ProductListScreen.id: (context) => ProductListScreen(),
        ProductDetailsScreen.id: (context) => ProductDetailsScreen(),
        CartScreen.id: (context) => CartScreen(),
        UpdateProfile.id: (context) => UpdateProfile(),
        ExistingCardsPage.id: (context) => ExistingCardsPage(),
        PaymentHome.id: (context) => PaymentHome(),
        MyOrders.id: (context) => MyOrders(),
        CreditCardList.id: (context) => CreditCardList(),
        CreateNewCreditCard.id: (context) => CreateNewCreditCard(),
        OpenStreetMapIntegration.id: (context) => OpenStreetMapIntegration(),
        ProfileHomeScreen.id: (context) => ProfileHomeScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        RatingVendorScreen.id: (context) => RatingVendorScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}
