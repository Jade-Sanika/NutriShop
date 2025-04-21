import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_provider.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 2;
  final primaryColor = const Color(0xff4caf50); // New primary color

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const FavoritesScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  double getTotalPrice(List<Map<String, dynamic>> cart) {
    return cart.fold(0.0, (sum, product) {
      String priceStr =
          product['price'].toString().replaceAll(RegExp(r'[^\d.]'), '');
      try {
        double price = double.parse(priceStr);
        int qty = product['quantity'] ?? 1;
        return sum + (price * qty);
      } catch (_) {
        return sum;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final cart = provider.cart;

    // Ensure each cart item has a 'quantity' field
    for (var item in cart) {
      item['quantity'] ??= 1;
    }

    double totalPrice = getTotalPrice(cart);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.white, // White text
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
        backgroundColor: primaryColor, // Updated color
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // White icons
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep,
                  color: Colors.white), // White icon
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                        'Are you sure you want to remove all items?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      TextButton(
                        child: const Text('Clear'),
                        onPressed: () {
                          provider.clearCart();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor, // Updated color
                      )),
                  const SizedBox(height: 8),
                  const Text('Add items to get started',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => HomeScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Updated button color
                    ),
                    child: const Text('Start Shopping',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final product = cart[index];
                      final quantity = product['quantity'] ?? 1;

                      return Dismissible(
                        key: Key(product['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          provider.removeFromCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product['name']} removed'),
                              backgroundColor: primaryColor, // Updated color
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: Colors.white,
                                onPressed: () => provider.addToCart(product),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(product: product),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product['image'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(product['price'],
                                            style: TextStyle(
                                                color:
                                                    primaryColor, // Updated color
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          icon: const Icon(
                                              Icons.favorite_border,
                                              size: 16),
                                          label: const Text('Save'),
                                          onPressed: () {
                                            provider.toggleFavorite(product);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${product['name']} saved to favorites'),
                                                backgroundColor:
                                                    primaryColor, // Updated color
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: quantity > 1
                                              ? () {
                                                  setState(() {
                                                    product['quantity']--;
                                                  });
                                                }
                                              : null,
                                          iconSize: 16,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              minWidth: 32, minHeight: 32),
                                        ),
                                        Text(
                                          quantity.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              product['quantity']++;
                                            });
                                          },
                                          iconSize: 16,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                              minWidth: 32, minHeight: 32),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₹${getTotalPrice(cart).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)), // Updated color
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                primaryColor, // Updated button color
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Proceeding to checkout...'),
                                backgroundColor: primaryColor,
                                duration: const Duration(seconds: 3),
                              ),
                            );

                            Future.delayed(const Duration(seconds: 1), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderConfirmationScreen(
                                    cart: List.from(
                                        cart), // Pass a copy of the cart
                                    totalPrice: totalPrice,
                                  ),
                                ),
                              );

                              provider
                                  .clearCart(); // Optional: clear cart after order placed
                            });
                          },
                          child: const Text('CHECKOUT',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        elevation: 8,
        backgroundColor: Colors.white, // Set white background for bottom nav
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => FavoritesScreen()));
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ProfileScreen()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
