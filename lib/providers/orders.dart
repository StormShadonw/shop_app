import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String tokenId;
  String userId;

  Orders(this.tokenId, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        "https://flutter-master-d18cc-default-rtdb.firebaseio.com/orders/$userId.json?auth=$tokenId";
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((key, value) {
      loadedOrders.add(OrderItem(
        id: key,
        amount: value["amount"],
        dateTime: DateTime.parse(value["dateTime"]),
        products: (value["products"] as List<dynamic>)
            .map((e) => CartItem(
                id: e["id"],
                title: e["title"],
                price: e["price"],
                quantity: e["quantity"]))
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    print(_orders);
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        "https://flutter-master-d18cc-default-rtdb.firebaseio.com/orders/$userId.json?auth=$tokenId";
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "dateTime": timestamp.toIso8601String(),
          "products": cartProducts
              .map((cp) => {
                    "id": cp.id,
                    "title": cp.title,
                    "quantity": cp.quantity,
                    "price": cp.price,
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["name"],
          amount: total,
          dateTime: DateTime.now(),
          products: cartProducts,
        ));
  }
}
