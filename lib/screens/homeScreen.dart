import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/auth_provider.dart';
import 'package:food_delivery_app/widgets/near_by_store.dart';
import 'package:food_delivery_app/widgets/top_pick_store.dart';
import 'package:food_delivery_app/widgets/image_slider.dart';
import 'package:food_delivery_app/widgets/my_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/location-provider.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _location = '';
  ScrollController _scrollController;
  MyAppBar _myAppBar;

  @override
  void initState() {
    _scrollController = ScrollController();
    _myAppBar = MyAppBar();
    getPrefs();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String location = prefs.getString('location');
    setState(() {
      _location = location;
    });
  }

  Future<void> _refreshHomeScreen() async {
    setState(() {
      _myAppBar = MyAppBar();
    });

    await getPrefs();
    // Add additional refresh logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _refreshHomeScreen,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [_myAppBar];
          },
          body: ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(top: 0.0),
            children: [
              Card(child: ImageSlider()),
              Container(
                color: Colors.white,
                child: TopPickStore(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: NearByStores(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
