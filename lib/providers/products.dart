import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl: 'assets/images/red_shirt.jpg',
    // ),
    // Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl: 'assets/images/trousers.jpg'),
    // Product(
    //   id: 'p3',
    //   title: 'Headphones',
    //   description: 'A nice headphones.',
    //   price: 32.49,
    //   imageUrl: 'assets/images/headphones_gamers.jpg',
    // ),
    // Product(
    //     id: 'p4',
    //     title: 'Keyboard Gamer',
    //     description: 'Keyboard to be a pro in any game.',
    //     price: 72.35,
    //     imageUrl: 'assets/images/gaming_keyboard.jpg'),
  ];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return [..._items].where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  String tokenId;
  String userId;

  Products(this.tokenId, this.userId, this._items);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filteringString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    String url =
        'https://flutter-master-d18cc-default-rtdb.firebaseio.com/products.json?auth=$tokenId&$filteringString';
    try {
      final response = await http.get(url);
      final extratecdData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      print("Here!");
      print(extratecdData);
      if (extratecdData == null) {
        return;
      }
      url =
          "https://flutter-master-d18cc-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$tokenId";

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extratecdData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData["title"],
          description: prodData["description"],
          price: prodData["price"],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData["imageUrl"],
        ));
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      print("------------------------ERROR HERE!-------------------------");
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        "https://flutter-master-d18cc-default-rtdb.firebaseio.com/products.json?auth=$tokenId";
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "creatorId": userId,
          // "isFavorite": product.isFavorite,
        }),
      );

      print(json.decode(response.body));
      var productToPost = new Product(
        id: json.decode(response.body)["name"],
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
        // isFavorite: product.isFavorite,
      );
      _items.add(productToPost);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get favoritesItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url =
          "https://flutter-master-d18cc-default-rtdb.firebaseio.com/products/$id.json?auth=$tokenId";
      await http.patch(
        url,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://flutter-master-d18cc-default-rtdb.firebaseio.com/products/$id.json?auth=$tokenId";
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    final response = await http.delete(url);

    _items.removeAt(existingProductIndex);

    notifyListeners();
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete the product.");
    }
    existingProduct = null;
  }
}
