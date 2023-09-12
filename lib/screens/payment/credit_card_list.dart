import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/screens/payment/create_new_card_screen.dart';
import 'package:food_delivery_app/services/payment/stripe_payment_service.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CreditCardList extends StatelessWidget {
  static const String id = 'manage-orders';
  @override
  Widget build(BuildContext context) {
    StripeService _service = StripeService();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(
                Icons.add_circle_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                pushNewScreenWithRouteSettings(
                  context,
                  screen: CreateNewCreditCard(),
                  settings: RouteSettings(name: CreateNewCreditCard.id),
                  withNavBar: true,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              }),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Manage Cards',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.cards.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.size == 0) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No Credit Cards added in your account'),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'Add Card',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      pushNewScreenWithRouteSettings(
                        context,
                        screen: CreateNewCreditCard(),
                        settings: RouteSettings(name: CreateNewCreditCard.id),
                        withNavBar: true,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  )
                ],
              ),
            );
          }

          return Container(
            padding: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
            child: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                var card = snapshot.data.docs[index];
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Container(
                    color: Colors.white,
                    child: CreditCardWidget(
                      cardNumber: card['cardNumber'],
                      expiryDate: card['expiryDate'],
                      cardHolderName: card['cardHolderName'],
                      cvvCode: card['cvvCode'],
                      showBackView: false,
                    ),
                  ),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        EasyLoading.show(status: 'Please Wait....');
                        _service.deleteCreditcard(card.id).whenComplete(() {
                          EasyLoading.dismiss();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
