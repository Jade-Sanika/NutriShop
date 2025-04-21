import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_provider.dart';
import 'cart_screen.dart'; // Import the CartScreen here

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final Color primaryColor = const Color(0xff4caf50);
  int selectedImageIndex = 0;
  late double price;

  @override
  void initState() {
    super.initState();

    // Extract the price value directly from the product map.
    final dynamic priceStr = widget.product['price'];

    if (priceStr is String) {
      // Attempt to parse the string price value to double
      price =
          double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    } else if (priceStr is num) {
      // If the price is already a number, directly assign it
      price = priceStr.toDouble();
    } else {
      price = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final isFavorite = provider.favorites.contains(widget.product);

    // Dynamically fetching the product images list from the product data
    List<String> productImages =
        List<String>.from(widget.product['images'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // App bar
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: true,
                    backgroundColor: primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Product image
                          Hero(
                            tag: 'product-${widget.product['id']}',
                            child: Image.network(
                              selectedImageIndex == 0
                                  ? productImages.isNotEmpty
                                      ? productImages[0]
                                      : widget.product['image']
                                  : productImages.isNotEmpty
                                      ? productImages[selectedImageIndex]
                                      : widget.product['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      // Favorite button
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            provider.toggleFavorite(widget.product);
                            final message = isFavorite
                                ? 'Removed from favorites'
                                : 'Added to favorites';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Share button
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.black87),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Sharing product...'),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),

                  // Product content
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product title and price section
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product['name'],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Rating
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const Icon(Icons.star_half,
                                            color: Colors.amber, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          '4.5',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '(124 reviews)',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Price tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '₹${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Image gallery
                        SizedBox(
                          height: 90,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                _buildImageThumbnail(
                                    productImages.isNotEmpty
                                        ? productImages[0]
                                        : widget.product['image'],
                                    0),
                                ...List.generate(
                                  productImages.length,
                                  (index) => _buildImageThumbnail(
                                    productImages[index],
                                    index + 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.product['description'] ??
                                    'This premium product offers exceptional quality and value. Made with attention to detail and the finest materials, this item is designed to exceed your expectations and provide long-lasting satisfaction.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Features
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Key Features',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureItem(
                                  'High-quality materials', Icons.check_circle),
                              _buildFeatureItem(
                                  'Sustainable production', Icons.eco),
                              _buildFeatureItem('30-day money-back guarantee',
                                  Icons.access_time),
                              _buildFeatureItem(
                                  'Free shipping', Icons.local_shipping),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom actions - Cart and Buy buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Add to cart button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.addToCart(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Added to cart!'),
                            backgroundColor: primaryColor,
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              textColor: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CartScreen()),
                                );
                                // Navigate to cart
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text("ADD TO CART"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Buy now button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Processing purchase...'),
                            backgroundColor: primaryColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("BUY NOW"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl, int index) {
    final bool isSelected = selectedImageIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedImageIndex = index;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
