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

  final categoryIcons = <String, IconData>{
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.dark.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) {
                      context.read<ProductProvider>().setSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search furniture...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.grey,
                      ),
                      suffixIcon:
                          _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  context.read<ProductProvider>().setSearch('');
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              
              // Featured or Search Results Vertical Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Consumer<ProductProvider>(
                  builder: (_, pp, __) {
                    final isSearching = pp.searchQuery.isNotEmpty;
                    final displayList = isSearching ? pp.products : pp.featured;

                    if (isSearching && pp.isLoading && pp.products.isEmpty) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (displayList.isEmpty) {
                      if (!isSearching && pp.featured.isEmpty) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (isSearching) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              'No products found',
                              style: TextStyle(color: AppTheme.grey),
                            ),
                          ),
                        );
                      }
                    }

                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(), // For using inside SingleChildScrollView
                      shrinkWrap: true,
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final p = displayList[i];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/product-detail',
                            arguments: p.id,
                          ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: Colors.black26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: p.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: p.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              height: 180,
                              color: AppTheme.border,
                            ),
                          )
                        : Container(
                            height: 180,
                            color: AppTheme.border,
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: AppTheme.grey,
                            ),
                          ),
                  ),
                  // Product Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rs.${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
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
      );
    },
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}