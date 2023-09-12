import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productName, category, image, shopName;
  final num price, comparedPrice;
  final DocumentSnapshot document;

  Product(
      {this.productName,
      this.category,
      this.image,
      this.shopName,
      this.price,
      this.comparedPrice,
      this.document});
}
