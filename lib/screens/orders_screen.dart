import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/ordersScreen";

  @override
  Widget build(BuildContext context) {
    print("building Orders!");
    // final orders = Provider.of<Orders>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      body: FutureBuilder(
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (dataSnapshot.error != null) {
            return Center(
              child: Text("An error ocurred!"),
            );
          } else {
            return Consumer<Orders>(
              builder: (ctx, orderData, child) => ListView.builder(
                itemBuilder: (ctx, index) => OrderItem(orderData.orders[index]),
                itemCount: orderData.orders.length,
              ),
            );
          }
        },
        future: Provider.of<Orders>(
          context,
          listen: false,
        ).fetchAndSetOrders(),
      ),
    );
  }
}
