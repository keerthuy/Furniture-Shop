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
  bool _didFetch = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    // Delay fetch to next frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (!_didFetch && mounted) {
      _didFetch = true;
      final pp = context.read<ProductProvider>();
      final cp = context.read<CartProvider>();

      pp.fetchFeatured();
      pp.fetchCategories();
      cp.fetchCart();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  final _categoryIcons = <String, IconData>{
    'Living Room': Icons.weekend,
    'Bedroom': Icons.bed,
    'Dining': Icons.dining,
    'Office': Icons.desk,
    'Outdoor': Icons.deck,
    'Kitchen': Icons.kitchen,
    'Bathroom': Icons.bathtub,
    'Kids': Icons.child_care,
    'Storage': Icons.inventory_2,
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
              // ...header, search, categories...

              // Featured
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.dark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ProductProvider>().clearFilters();
                        Navigator.pushNamed(context, '/products');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              Consumer<ProductProvider>(
                builder: (_, pp, __) {
                  print('Featured: ${pp.featured.length}'); // Debug
                  if (pp.featured.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pp.featured.length,
                      itemBuilder: (_, i) {
                        final p = pp.featured[i];
                        return GestureDetector(
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/product-detail',
                                arguments: p.id,
                              ),
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.dark.withOpacity(0.06),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child:
                                      p.imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                            imageUrl: p.imageUrl,
                                            height: 140,
                                            width: 180,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (_, __) => Container(
                                                  height: 140,
                                                  color: AppTheme.border,
                                                ),
                                          )
                                          : Container(
                                            height: 140,
                                            color: AppTheme.border,
                                            child: const Icon(
                                              Icons.image,
                                              size: 40,
                                              color: AppTheme.grey,
                                            ),
                                          ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.dark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₹${p.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
