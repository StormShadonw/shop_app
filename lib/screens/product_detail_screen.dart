import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen({this.title, this.price});

  static const routeName = "/product_detail";

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments;
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loadedProduct.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 10,
          ),
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "\$${loadedProduct.price.toStringAsFixed(2)}",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                child: Text(
                  "${loadedProduct.description}",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
