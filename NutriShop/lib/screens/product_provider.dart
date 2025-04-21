import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];
  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);
  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);

  void toggleFavorite(Map<String, dynamic> product) {
    if (_favorites.contains(product)) {
      _favorites.remove(product);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void addToCart(Map<String, dynamic> product) {
    if (!_cart.contains(product)) {
      _cart.add(product);
      notifyListeners();
    }
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cart.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear(); // fix: was using `cart.clear()` instead of `_cart.clear()`
    notifyListeners();
  }
}
