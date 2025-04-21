import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  String selectedCategory = 'All';
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<String> categories = [
    'All',
    'Fruits',
    'Nuts',
    'Vegetables',
    'Spices',
    'Grains',
    'Beverages',
  ];

  final List<Map<String, dynamic>> products = [
    {
      "name": "Organic Apples",
      "price": "₹120/kg",
      "image": "https://images.unsplash.com/photo-1567306226416-28f0efdc88ce",
      "category": "Fruits",
      "description":
          "Fresh and juicy organic apples sourced from Himachal orchards."
    },
    {
      "name": "Almonds",
      "price": "₹500/kg",
      "image": "https://images.indianexpress.com/2023/05/almonds.jpg",
      "category": "Nuts",
      "description":
          "High-quality, protein-rich almonds perfect for a healthy snack."
    },
    {
      "name": "Spinach",
      "price": "₹40/bundle",
      "image":
          "data:image/jpeg;base64,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",
      "category": "Vegetables",
      "description": "Fresh spinach bundles loaded with iron and nutrients."
    },
    {
      "name": "Bananas",
      "price": "₹60/dozen",
      "image":
          "data:image/jpeg;base64,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",
      "category": "Fruits",
      "description": "Ripe and sweet bananas, a perfect energy booster."
    },
    {
      "name": "Cashews",
      "price": "₹700/kg",
      "image":
          "https://www.bigbasket.com/media/uploads/p/l/40210967_2-super-saver-cashews.jpg",
      "category": "Nuts",
      "description": "Creamy, delicious cashews for cooking or snacking."
    },
    {
      "name": "Carrots",
      "price": "₹45/kg",
      "image":
          "https://images.apollo247.in/pd-cms/cms/2023-09/Shutterstock_440493100.jpg?tr=q-80,f-webp,w-450,dpr-3,c-at_max%201350w",
      "category": "Vegetables",
      "description": "Crunchy and sweet carrots, great for juicing and salads."
    },
    {
      "name": "Brown Rice",
      "price": "₹80/kg",
      "image":
          "https://cdn.dotpe.in/longtail/store-items/1087846/9V1G4gMm.jpeg",
      "category": "Grains",
      "description": "High-fiber brown rice, ideal for a nutritious diet."
    },
    {
      "name": "Green Tea",
      "price": "₹150/box",
      "image":
          "https://marveltea.com/cdn/shop/files/OrganicGreenTea-min_grande.webp?v=1724847412",
      "category": "Beverages",
      "description": "Soothing and detoxifying green tea with antioxidants."
    },
    {
      "name": "Red Chilli Powder",
      "price": "₹60/100g",
      "image":
          "https://www.kpgmasale.com/cdn/shop/files/FreshItemBanner-18_cbb29d20-227e-4427-bfae-8d8cd77a6091.jpg?v=1721717979",
      "category": "Spices",
      "description": "Pure, aromatic and spicy red chilli powder for curries."
    },
    {
      "name": "Turmeric Root",
      "price": "₹120/kg",
      "image":
          "https://www.aalamroots.com/wp-content/uploads/2021/12/blog_wild_turmeric-2-600x326.jpg",
      "category": "Spices",
      "description":
          "Organic turmeric roots, perfect for immunity-boosting tea or cooking."
    },
    {
      "name": "Mangoes",
      "price": "₹100/kg",
      "image":
          "https://farmerscraft.in/cdn/shop/files/alphonso-mango-stock-image-1-1024x686-2_c387efd4-6055-46c8-81ca-9f41d54fd1fc.jpg?v=1739248444",
      "category": "Fruits",
      "description": "Sweet Alphonso mangoes, king of fruits!"
    },
    {
      "name": "Walnuts",
      "price": "₹650/kg",
      "image":
          "https://static.toiimg.com/thumb/resizemode-4,width-1280,height-720,msid-112395279/112395279.jpg",
      "category": "Nuts",
      "description": "Brain-boosting walnuts rich in Omega-3s."
    },
    {
      "name": "Tomatoes",
      "price": "₹30/kg",
      "image":
          "https://images.healthshots.com/healthshots/en/uploads/2024/01/25225611/tomatoes-1.jpg",
      "category": "Vegetables",
      "description": "Juicy red tomatoes, farm fresh and pesticide-free."
    },
    {
      "name": "Black Pepper",
      "price": "₹90/100g",
      "image":
          "https://assets.clevelandclinic.org/transform/65ddb397-7835-4b21-b30b-d123be3cb5c8/blackPepper-185067429-770x533-1_jpg",
      "category": "Spices",
      "description": "Whole black peppercorns with rich aroma and flavor."
    },
    {
      "name": "Wheat Flour",
      "price": "₹40/kg",
      "image":
          "https://rukminim2.flixcart.com/image/850/1000/xif0q/flour/u/w/h/-original-imagu7fnx5dzgpdh.jpeg?q=90&crop=false",
      "category": "Grains",
      "description":
          "Stone-ground whole wheat flour for soft and nutritious rotis."
    },
    {
      "name": "Orange Juice",
      "price": "₹70/bottle",
      "image":
          "https://rukminim2.flixcart.com/image/850/1000/xif0q/drinks-juice/e/z/r/-original-imahb3fcqcghbagu.jpeg?q=90&crop=false",
      "category": "Beverages",
      "description": "Refreshing orange juice packed with Vitamin C."
    },
  ];

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> favoriteItems = [];

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      if (!cartItems.contains(product)) {
        cartItems.add(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name']} added to cart'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void addToFavorites(Map<String, dynamic> product) {
    setState(() {
      if (favoriteItems.contains(product)) {
        favoriteItems.remove(product);
      } else {
        favoriteItems.add(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name']} added to favorites'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.pink,
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Apply filter to products
    List<Map<String, dynamic>> filteredProducts = products.where((product) {
      final matchesCategory =
          selectedCategory == 'All' || product['category'] == selectedCategory;
      final matchesSearch =
          product['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sliver App Bar with search
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.green,
              iconTheme:
                  IconThemeData(color: Colors.white), // Make all icons white
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade700,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, bottom: 16, top: 60),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for healthy products...',
                        hintStyle: TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.search, color: Colors.green),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                "NutriShop",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NotificationScreen()), // replace with your notification screen
                        );
                      },
                      icon: Icon(Icons.notifications_none),
                    ),
                    if (cartItems.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cartItems.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () => logout(context),
                  icon: Icon(Icons.logout),
                ),
              ],
            ),

            // Categories
            SliverToBoxAdapter(
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: FadeTransition(
                  opacity: _animation,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: Material(
                            color:
                                isSelected ? Color(0xff4caf50) : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            elevation: isSelected ? 4 : 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedCategory = cat;
                                });
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.8, // Increased from 0.7 to 0.8 for more vertical space
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Ensure index is within bounds of filteredProducts
                    if (index >= filteredProducts.length)
                      return SizedBox.shrink(); // Prevent rendering extra items

                    final product = filteredProducts[index];
                    final isFavorite = favoriteItems.contains(product);

                    return Hero(
                      tag: 'product-${product['name']}',
                      child: Material(
                        borderRadius: BorderRadius.circular(16),
                        elevation: 4,
                        shadowColor: Colors.black26,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ProductDetailScreen(product: product),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                      opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Product Image with Favorite Button
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: CachedNetworkImage(
                                        imageUrl: product["image"],
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            color: Colors.white,
                                            height: 110,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          height: 110,
                                          color: Colors.grey[100],
                                          child: Icon(Icons.broken_image,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          constraints: BoxConstraints(
                                            minHeight: 30,
                                            minWidth: 30,
                                          ),
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.grey[600],
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () =>
                                              addToFavorites(product),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Product Name and Price Only (No Description)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          product["name"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product["price"],
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                constraints: BoxConstraints(
                                                  minWidth: 30,
                                                  minHeight: 30,
                                                ),
                                                icon: Icon(
                                                  Icons.add_shopping_cart,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    addToCart(product),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  // Only render as many items as filteredProducts.length
                  childCount: filteredProducts.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/chatbot');
        },
        backgroundColor: Color(0xff4caf50),
        elevation: 6,
        child: Icon(Icons.chat, color: Colors.white),
        tooltip: 'Chat with Nutrition Assistant',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            currentIndex: 0,
            elevation: 0,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: TextStyle(fontSize: 10),
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritesScreen()),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
