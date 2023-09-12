import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:food_delivery_app/services/cart_services.dart';



class CounterForCard extends StatefulWidget {

  final DocumentSnapshot document;
  CounterForCard(this.document);

  @override
  _CounterForCardState createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {

  User user = FirebaseAuth.instance.currentUser;
  CartServices _cart = CartServices();
  int _qty=1;
  String _docId;
  bool _exists = false;
  bool _updating = false;

  getCartData(){
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('products').where('productId',isEqualTo: widget.document.data()['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
         if(querySnapshot.docs.isNotEmpty){
           querySnapshot.docs.forEach((doc) {
             if(doc['productId']==widget.document.data()['productId']){
               //means selected product already exists in cart, so no need to add cart again
               setState(() {
                 _qty = doc ['qty'];
                 _docId = doc.id;
                 _exists = true;
               });
             }
           }),
         }else{
        setState(() {
      _exists = false;
    })
         }
    });

  }

  @override
  void initState() {
    getCartData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {


    return _exists ? StreamBuilder(
        stream: getCartData(),
        builder:(BuildContext context,AsyncSnapshot<dynamic>snapshot){
          return Container(
            height: 28,
            decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.deepOrangeAccent
                ),
                borderRadius: BorderRadius.circular(4)
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: (){

                    setState(() {
                      _updating=true;
                    });
                    if(_qty==1){

                      _cart.removeFromCart(_docId).then((value) {
                        setState(() {
                          _updating=false;
                          _exists=false;
                        });
                        _cart.checkData();
                      });
                    }
                    if(_qty>1){
                      setState(() {
                        _qty--;
                      });
                      var total = _qty * widget.document.data()['price'];
                      _cart.updateCartQty(_docId, _qty,total).then((value) {
                        setState(() {
                          _updating=false;
                        });
                      });
                    }
                  },
                  child: Container(
                    child: Icon(_qty == 1 ? Icons.delete_outline:Icons.remove,color: Colors.deepOrangeAccent,),
                  ),
                ),


                Container(
                  height: double.infinity,
                  width: 30,
                  color: Colors.deepOrangeAccent,
                  child: Center(child: FittedBox(child: _updating ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ): Text(_qty.toString(),style: TextStyle(color: Colors.white),))),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _updating=true;
                      _qty++;
                    });
                    var total = _qty * widget.document.data()['price'];
                    _cart.updateCartQty(_docId, _qty,total).then((value) {
                      setState(() {
                        _updating = false;
                      });
                    });
                  },
                  child: Container(
                    child: Icon(Icons.add,color: Colors.deepOrangeAccent,),
                  ),
                ),
              ],
            ),
          );
        }
    ): StreamBuilder(
        stream: getCartData(),
    builder:(BuildContext context,AsyncSnapshot<dynamic>snapshot){
    return  InkWell(
    onTap: (){
    EasyLoading.show(status: 'Adding to Cart');
    _cart.checkSeller().then((shopName) {
      if(shopName==widget.document.data()['seller']['shopName']){
        //product from same seller
        setState(() {
          _exists=true;
        });
        _cart.addToCart(widget.document).then((value) {
          EasyLoading.showSuccess('Added to Cart');
        });
        return;

      }


      if(shopName==null){
        setState(() {
          _exists=true;
        });
        _cart.addToCart(widget.document).then((value) {
          EasyLoading.showSuccess('Added to Cart');
        });
        return;
      }

      if(shopName!=widget.document.data()['seller']['shopName']){
        //product from different seller
        EasyLoading.dismiss();
        showDialog(shopName);
      }

    });
    },
    child: Container(
    height: 28,
    decoration: BoxDecoration(
    color: Colors.deepOrangeAccent,
    borderRadius: BorderRadius.circular(4),
    ),
    child: Center(
    child: Padding(
    padding: const EdgeInsets.only(left: 30,right: 30),
    child: Text('Add',style: TextStyle(color: Colors.white),),
    ),
     ),
    ),
    );
    });

  }

  showDialog(shopName){
    showCupertinoDialog(context: context, builder: (BuildContext context){
      return CupertinoAlertDialog(
        title: Text('Replace cart item?'),
        content: Text('Your cart contains items from $shopName. Do you want to discard the selection and add items from ${widget
            .document.data()['seller']['shopName']}'),
        actions: [
          FlatButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text('No'),
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: (){
              _cart.deleteCart().then((value) {
                _cart.addToCart(widget.document).then((value) {
                  setState(() {
                    _exists=true;
                  });
                  Navigator.pop(context);
                });
              });

            },

          ),
        ],
      );
    });
  }
}
