import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pp = context.read<ProductProvider>();
      if (pp.products.isEmpty) pp.fetchProducts();
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().fetchProducts(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilters),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (_, pp, __) {
          if (pp.isLoading && pp.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (pp.products.isEmpty) {
            return const Center(child: Text('No products found', style: TextStyle(color: AppTheme.grey)));
          }
          return GridView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.68,
              crossAxisSpacing: 14, mainAxisSpacing: 14,
            ),
            itemCount: pp.products.length + (pp.isLoading ? 2 : 0),
            itemBuilder: (_, i) {
              if (i >= pp.products.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
              }
              final p = pp.products[i];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: p.id),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppTheme.dark.withOpacity(0.06), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: p.imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: p.imageUrl, width: double.infinity, fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: AppTheme.border),
                                )
                              : Container(color: AppTheme.border,
                                  child: const Center(child: Icon(Icons.image, size: 40, color: AppTheme.grey))),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.name, style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.dark),
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                                  if (p.stock > 0)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                                    )
                                  else
                                    const Text('Out of stock', style: TextStyle(fontSize: 10, color: AppTheme.error)),
                                ],
                              ),
                            ],
                          ),
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
    );
  }

  void _showFilters() {
    final pp = context.read<ProductProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _filterChip('Newest', 'newest', pp),
                _filterChip('Price ↑', 'price_asc', pp),
                _filterChip('Price ↓', 'price_desc', pp),
                _filterChip('Popular', 'popular', pp),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _catChip('All', '', pp),
                ...pp.categories.map((c) => _catChip(c, c, pp)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { pp.clearFilters(); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                child: const Text('Clear Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, ProductProvider pp) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (_) { pp.setSort(value); Navigator.pop(context); },
      backgroundColor: AppTheme.background,
      selectedColor: AppTheme.primary,
    );
  }

  Widget _catChip(String label, String value, ProductProvider pp) {
    final isSelected = pp.selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) { pp.setCategory(value); Navigator.pop(context); },
      backgroundColor: AppTheme.background,
      selectedColor: AppTheme.primary.withOpacity(0.2),
    );
  }
}
