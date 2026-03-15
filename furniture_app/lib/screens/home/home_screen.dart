import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  /// Demo images to ensure UI always shows something
  final List<String> bannerImages = [
    "https://images.unsplash.com/photo-1505691938895-1758d7feb511",
    "https://images.unsplash.com/photo-1615874959474-d609969a20ed",
    "https://images.unsplash.com/photo-1616594039964-ae9021a400a0",
  ];

  final List<Map<String, dynamic>> demoProducts = [
    {
      "name": "Modern Sofa",
      "price": 320,
      "image":
          "https://images.unsplash.com/photo-1586023492125-27b2c045efd7"
    },
    {
      "name": "Wood Dining Table",
      "price": 520,
      "image":
          "https://images.unsplash.com/photo-1618220179428-22790b461013"
    },
    {
      "name": "Office Chair",
      "price": 150,
      "image":
          "https://images.unsplash.com/photo-1598300056393-4aac492f4344"
    },
    {
      "name": "Luxury Bed",
      "price": 780,
      "image":
          "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85"
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pp = context.read<ProductProvider>();
      pp.fetchFeatured();
      pp.fetchCategories();
      context.read<CartProvider>().fetchCart();
    });
  }

  final _categoryIcons = <String, IconData>{
    'Living Room': Icons.weekend,
    'Bedroom': Icons.bed,
    'Dining': Icons.dining,
    'Office': Icons.desk,
    'Outdoor': Icons.deck,
    'Kitchen': Icons.kitchen,
    'Decor': Icons.light,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("FurniHub",
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Premium furniture for your home"),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications))
                  ],
                ),
              ),

              /// SEARCH
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search furniture...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),

              /// BANNER
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bannerImages.length,
                  itemBuilder: (_, i) {
                    return Container(
                      width: 320,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: bannerImages[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// CATEGORIES
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Browse Categories",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _categoryIcons.entries.map((e) {
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(16)),
                            child: Icon(e.value,
                                color: Colors.orange, size: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(e.key,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12))
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              /// FEATURED PRODUCTS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Featured Furniture",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: demoProducts.length,
                  itemBuilder: (_, i) {
                    final p = demoProducts[i];

                    return Container(
                      width: 180,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8)
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: CachedNetworkImage(
                              imageUrl: p["image"],
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(p["name"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text("\$${p["price"]}",
                                    style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    Icon(Icons.add_shopping_cart,
                                        color: Colors.orange)
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              /// TRENDING SECTION
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Trending Now",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 16),

              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: demoProducts.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75),
                itemBuilder: (_, i) {
                  final p = demoProducts[i];

                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: CachedNetworkImage(
                              imageUrl: p["image"],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(p["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("\$${p["price"]}",
                                  style: const TextStyle(
                                      color: Colors.orange)),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}