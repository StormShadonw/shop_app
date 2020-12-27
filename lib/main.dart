import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
            create: (_) => Products(null, null, []),
            update: (ctx, auth, previousItems) => Products(
                  auth.token,
                  auth.userId,
                  previousItems.items == null ? [] : previousItems.items,
                )),
        ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(null, null, []),
            update: (ctx, auth, previousItems) => Orders(
                  auth.token,
                  auth.userId,
                  previousItems.orders == null ? [] : previousItems.orders,
                )),
        ChangeNotifierProxyProvider<Auth, Cart>(
            create: (_) => Cart(null, {}),
            update: (ctx, auth, previousItems) => Cart(
                  auth.token,
                  previousItems.items == null ? [] : previousItems.items,
                )),
      ],
      child: Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
                title: 'MYSHOP',
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.deepOrange,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  fontFamily: "Lato",
                ),
                home: auth.isAuth
                    ? ProductsOverview()
                    : FutureBuilder(
                        future: auth.tryAutoLogIn(),
                        builder: (ctx, snapshot) =>
                            snapshot.connectionState == ConnectionState.waiting
                                ? SplashScreen()
                                : AuthScreen(),
                      ),
                routes: {
                  ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  OrdersScreen.routeName: (ctx) => OrdersScreen(),
                  UserScreenProducts.routeName: (ctx) => UserScreenProducts(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                },
              )),
    );
  }
}
