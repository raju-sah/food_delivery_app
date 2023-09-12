import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_bar/toggle_bar.dart';


class CodToggleSwitch extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    var _cart = Provider.of<CartProvider>(context);
    return Container(
      color: Colors.white,
      child: ToggleBar(
        backgroundColor: Colors.grey[300],
          textColor: Colors.grey[600],
          selectedTabColor: Theme.of(context).primaryColor,
          labels: ["Pay Online", "Cash on Delivery",],
          onSelectionUpdated: (index) {
           _cart.getPaymentMethod(index);
          }
      ),

    );
  }
}
