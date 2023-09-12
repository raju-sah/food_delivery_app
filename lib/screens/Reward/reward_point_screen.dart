import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/screens/Reward/rewardpoints_rules.dart';
import 'package:food_delivery_app/screens/Reward/statement.dart';
import 'package:food_delivery_app/screens/homeScreen.dart';
import 'package:food_delivery_app/screens/onboard_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class RewardPointsPage extends StatefulWidget {
  static const String id = 'reward-screen';
  @override
  _RewardPointsPageState createState() => _RewardPointsPageState();
}

class _RewardPointsPageState extends State<RewardPointsPage> {
  @override
  Widget build(BuildContext context) {
    PersistentTabController _controller;
    _controller = PersistentTabController(initialIndex: 0);

    List<Widget> _buildScreens() {
      return [StatementScreen(), RewardPointRulesPage()];
    }

    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.doc_plaintext),
          title: ("Statemnt"),
          activeColorPrimary: Theme.of(context).primaryColor,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(CupertinoIcons.gift),
          title: ("Reward Schemes"),
          activeColorPrimary: Theme.of(context).primaryColor,
          inactiveColorPrimary: CupertinoColors.systemGrey,
        ),
      ];
    }

    return Scaffold(
      body: PersistentTabView(
        context,
        navBarHeight: 56,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        // This needs to be true if you want to move up the screen when keyboard appears.
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
        decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(0.0),
            colorBehindNavBar: Colors.white,
            border: Border.all(color: Colors.black45)),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style9, // Choose the nav bar style with this property.
      ),
    );
  }
}
