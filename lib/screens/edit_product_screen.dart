import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();

  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var _editedProduct = Product(
      id: DateTime.now().toString(),
      title: "",
      price: 0,
      imageUrl: "",
      description: "");

  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          "imageUrl": ""
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (_initValues["title"] != "") {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error ocurred!"),
            content: Text("Something went wrong."),
            actions: [
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Okay"))
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please provide a value.";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: value,
                          description: _editedProduct.description,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a value";
                        }
                        if (double.tryParse(value) == null) {
                          return "please enter a valid number";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number higher than 0";
                        }
                        return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          imageUrl: _editedProduct.imageUrl,
                          price: double.parse(value),
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],

                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please provide a value.";
                        }
                        if (value.length <= 0) {
                          return "Please provide a value with more of 10 characters.";
                        }
                        return null;
                      },
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          description: value,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          imageUrl: _editedProduct.imageUrl,
                          price: _editedProduct.price,
                        );
                      },
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      // textInputAction: TextInputAction.next,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter an url")
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please provide a value.";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "please enter a valid URL.";
                              }
                              if (!value.endsWith(".png") &&
                                  !value.endsWith(".jpg") &&
                                  !value.endsWith(".jpeg")) {
                                return "Provide a png, jpg or jpeg valid image.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(labelText: "Image Url"),
                            keyboardType: TextInputType.url,
                            // textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageFocusNode,
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                imageUrl: value,
                                price: _editedProduct.price,
                              );
                            },
                            onFieldSubmitted: (_) => _saveForm(),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
