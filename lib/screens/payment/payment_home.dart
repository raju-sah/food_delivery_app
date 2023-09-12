import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/providers/order_provider.dart';
import 'package:food_delivery_app/screens/payment/create_new_card_screen.dart';
import 'package:food_delivery_app/screens/payment/stripe/existing-cards.dart';
import 'package:food_delivery_app/services/payment/stripe_payment_service.dart';
import 'package:provider/provider.dart';

class PaymentHome extends StatefulWidget {
  static const String id = 'stripe-home';

  @override
  PaymentHomeState createState() => PaymentHomeState();
}

class PaymentHomeState extends State<PaymentHome> {
  onItemPress(BuildContext context, int index, amount, orderProvider) async {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, CreateNewCreditCard.id);
        break;
      case 1:
        payViaNewCard(context, amount, orderProvider);
        break;
      case 2:
        Navigator.pushNamed(context, ExistingCardsPage.id);
        break;
    }
  }

  payViaNewCard(
      BuildContext context, amount, OrderProvider orderProvider) async {
    await EasyLoading.show(status: 'Please Wait....');
    var response = await StripeService.payWithNewCard(
        amount: '${amount}00', currency: 'INR');

    if (response.success == true) {
      orderProvider.success = true;
    }
    await EasyLoading.dismiss();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          content: Text(response.message),
          duration: new Duration(
              milliseconds: response.success == true ? 1200 : 3000),
        ))
        .closed
        .then((_) {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          Material(
            elevation: 4,
            child: SizedBox(
              height: 65,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 10),
                child: InkWell(
                  onTap: () {},
                  child: ClipRRect(
                    child: Image.network(
                      'https://cdn.esewa.com.np/ui/images/esewa_og.png?111',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          Material(
            elevation: 4,
            child: SizedBox(
              height: 65,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 10),
                child: Image.network(
                  'https://dao578ztqooau.cloudfront.net/static/img/logo1.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          Material(
            elevation: 4,
            child: SizedBox(
              height: 56,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, top: 10),
                child: Image.network(
                  'https://latamlist.com/wp-content/uploads/2019/11/social-1.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Icon icon;
                  Text text;

                  switch (index) {
                    case 0:
                      icon = Icon(Icons.add_circle, color: theme.primaryColor);
                      text = Text('Add cards');
                      break;
                    case 1:
                      icon = Icon(Icons.payment_outlined,
                          color: theme.primaryColor);
                      text = Text('Pay via new card');
                      break;
                    case 2:
                      icon = Icon(Icons.credit_card, color: theme.primaryColor);
                      text = Text('Pay via existing card');
                      break;
                  }

                  return InkWell(
                    onTap: () {
                      onItemPress(
                          context, index, orderProvider.amount, orderProvider);
                    },
                    child: ListTile(
                      title: text,
                      leading: icon,
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      color: theme.primaryColor,
                    ),
                itemCount: 3),
          ),
        ],
      ),
    );
  }
}
