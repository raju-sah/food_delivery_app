import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/store_provider.dart';
import 'package:food_delivery_app/widgets/categories_widget.dart';
import 'package:food_delivery_app/widgets/my_appbar.dart';
import 'package:food_delivery_app/widgets/products/best_selling_products.dart';
import 'package:food_delivery_app/widgets/products/featured_products.dart';
import 'package:food_delivery_app/widgets/products/recently_added_products.dart';
import 'package:food_delivery_app/widgets/vendor_appbar.dart';
import 'package:food_delivery_app/widgets/vendor_banner.dart';
import 'package:provider/provider.dart';

class VendorHomeScreen extends StatelessWidget {
  static const String id = 'vendor-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              VendorAppBar(),
            ];
          },
          body: ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Divider(
                thickness: 5,
                color: Colors.deepOrangeAccent,
              ),
              Container(
                  height: 210, width: 290, child: Card(child: VendorBanner())),
              Divider(
                thickness: 5,
                color: Colors.deepOrangeAccent,
              ),
              VendorCategories(),
              RecentlyAddedProducts(),
              FeaturedProducts(),
              BestSellingProduct(),
              SizedBox(
                height: 200,
              ),
            ],
          )),
    );
  }
}
