import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      context.read<ProductProvider>().fetchProductById(productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<ProductProvider>(
        builder: (_, pp, __) {
          if (pp.isLoading || pp.selectedProduct == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = pp.selectedProduct!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: AppTheme.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: p.images.isNotEmpty
                      ? PageView.builder(
                          itemCount: p.images.length,
                          onPageChanged: (i) => setState(() => _currentImage = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: p.images[i].url,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppTheme.border),
                          ),
                        )
                      : Container(color: AppTheme.border,
                          child: const Center(child: Icon(Icons.image, size: 60, color: AppTheme.grey))),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image indicators
                      if (p.images.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(p.images.length, (i) => Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImage == i ? AppTheme.primary : AppTheme.border,
                            ),
                          )),
                        ),
                      const SizedBox(height: 16),

                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p.category, style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ),
                      const SizedBox(height: 12),

                      // Name & Price
                      Text(p.name, style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.dark)),
                      const SizedBox(height: 8),
                      Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      const SizedBox(height: 4),
                      Text(
                        p.stock > 0 ? '${p.stock} in stock' : 'Out of stock',
                        style: TextStyle(
                          fontSize: 14,
                          color: p.stock > 0 ? AppTheme.success : AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (p.sellerName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Sold by: ${p.sellerName}', style: const TextStyle(
                          fontSize: 13, color: AppTheme.grey)),
                      ],

                      const Divider(height: 32),

                      // Description
                      const Text('Description', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.dark)),
                      const SizedBox(height: 8),
                      Text(p.description, style: const TextStyle(
                        fontSize: 15, color: AppTheme.grey, height: 1.6)),

                      const SizedBox(height: 24),

                      // Quantity selector
                      Row(
                        children: [
                          const Text('Quantity', style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.dark)),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                ),
                                Text('$_quantity', style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: _quantity < p.stock ? () => setState(() => _quantity++) : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: p.stock > 0 ? () async {
                                final success = await context.read<CartProvider>()
                                    .addToCart(p.id, quantity: _quantity);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(success ? 'Added to cart!' : 'Failed to add'),
                                    backgroundColor: success ? AppTheme.success : AppTheme.error,
                                  ));
                                }
                              } : null,
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: const Text('Add to Cart'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: p.stock > 0 ? () {
                                context.read<CartProvider>().addToCart(p.id, quantity: _quantity);
                                Navigator.pushNamed(context, '/cart');
                              } : null,
                              icon: const Icon(Icons.flash_on),
                              label: const Text('Buy Now'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
