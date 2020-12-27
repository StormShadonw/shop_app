import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem({this.id, this.price, this.quantity, this.title, this.productId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("Are you sure?"),
                  content: Text(
                    "Do you want to remove the item from the cart?",
                  ),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text("No")),
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text("Yes")),
                  ],
                ));
      },
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(
          context,
          listen: false,
        ).removeItem(productId);
      },
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            visualDensity: VisualDensity.comfortable,
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(child: Text("\$${price}")),
              ),
            ),
            title: Text("$title"),
            subtitle: Text("Total: \$${price * quantity}"),
            trailing: Text("${quantity} x"),
          ),
        ),
      ),
    );
  }
}
