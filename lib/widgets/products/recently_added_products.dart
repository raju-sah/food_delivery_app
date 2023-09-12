import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/providers/store_provider.dart';
import 'package:food_delivery_app/services/product_services.dart';
import 'package:food_delivery_app/widgets/products/product_card_widget.dart';
import 'package:provider/provider.dart';



class RecentlyAddedProducts extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    ProductServices _services = ProductServices();
    var _store = Provider.of<StoreProvider>(context);

    return FutureBuilder<QuerySnapshot>(
      future:_services.products.where('published',isEqualTo: true)
          .where('collection',isEqualTo: 'Recently Added')
          .where('seller.sellerUid',isEqualTo: _store.storedetails['uid'])
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData){
          return Container();
        }

        if(snapshot.data.docs.isEmpty){
          return Center(child: CircularProgressIndicator(),);  // if no data
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.deepOrangeAccent,
                    borderRadius: BorderRadius.circular(4),

                  ),
                  child: Center(
                    child: Text('Recently Added',style: TextStyle(
                        shadows: <Shadow>[
                          Shadow(
                              offset: Offset(2.0,2.0),
                              blurRadius: 3.0,
                              color: Colors.black
                          )
                        ],
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                    ),
                  ),
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                return ProductCard(document);
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
