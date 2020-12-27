import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 5,
      child: Column(
        children: [
          AppBar(
            title: Text("Navigation Panel"),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text("Shop"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Orders"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Manage Products"),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserScreenProducts.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Log Out"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/");
              Provider.of<Auth>(context, listen: false).logOut();
            },
          ),
        ],
      ),
    );
  }
}
