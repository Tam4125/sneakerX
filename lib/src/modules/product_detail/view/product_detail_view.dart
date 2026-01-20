import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/attribute_value.dart';
import 'package:sneakerx/src/models/category.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/models/product_attribute.dart';
import 'package:sneakerx/src/models/product_image.dart';
import 'package:sneakerx/src/models/product_review.dart';
import 'package:sneakerx/src/models/product_sku.dart';
import 'package:sneakerx/src/models/shops.dart';
import 'package:sneakerx/src/modules/cart/dtos/save_to_cart_request.dart';
import 'package:sneakerx/src/modules/product_detail/dtos/product_detail_response.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/cart_service.dart';
import 'package:sneakerx/src/services/product_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  late TabController _tabController;
  late PageController _pageController;

  // Future to hold the API call
  late Future<ApiResponse<ProductDetailResponse>> _productFuture;

  int _currentImageIndex = 0;
  final Map<int, int> _selectedAttributes = {}; // attributeId -> valueId
  ProductSku? _selectedSku;
  int _quantity = 1;
  bool _isActionLoading = false;
  int _selectedStarFilter = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _productFuture = _productService.getProductById(widget.productId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- LOGIC: Find Matching SKU ---
  void _updateSelectedSku(ProductDetailResponse productDetail) {
    if (_selectedAttributes.isEmpty) {
      setState(() => _selectedSku = null);
      return;
    }

    try {
      final match = productDetail.skus.firstWhere((sku) {
        for (var entry in _selectedAttributes.entries) {
          bool hasAttr = sku.values.any((val) =>
          val.attributeId == entry.key && val.valueId == entry.value
          );
          if (!hasAttr) return false;
        }
        return true;
      });

      setState(() {
        _selectedSku = match;
        // Reset quantity if it exceeds new stock
        if (_quantity > match.stock) {
          _quantity = 1;
        }
      });
    } catch (e) {
      setState(() => _selectedSku = null);
    }
  }

  void _selectAttribute(ProductDetailResponse data, int attributeId, int valueId) {
    setState(() {
      _selectedAttributes[attributeId] = valueId;
    });
    _updateSelectedSku(data);
  }

  // Helper to get price (Base price if no SKU selected)
  double _getCurrentPrice(ProductDetailResponse data) {
    return _selectedSku?.price ?? data.product.basePrice;
  }

  // --- LOGIC: Quantity ---
  void _incrementQuantity() {
    int maxStock = _selectedSku?.stock ?? 0;
    if (_quantity < maxStock) {
      setState(() {
        _quantity++;
      });
    } else {
      GlobalSnackbar.show(context, success: false, message: "Max stock reached");
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  String _formatSoldCount(int soldCount) {
    if (soldCount >= 1000000) {
      return '${(soldCount / 1000000).toStringAsFixed(1)}M';
    } else if (soldCount >= 1000) {
      final k = soldCount / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return soldCount.toString();
  }

  Future<void> _handleAction(bool isBuyNow) async {

    if (_selectedSku == null) {
      GlobalSnackbar.show(context, success: false, message: "Please select all options");
      return;
    }

    setState(() => _isActionLoading = true);

    SaveToCartRequest request = SaveToCartRequest(
      quantity: _quantity,
      skuId: _selectedSku!.skuId
    );

    try {
      final response = await _cartService.saveToCart(request);
      if (response.success) {
        if (isBuyNow) {
          GlobalSnackbar.show(context, success: true, message: "Redirecting to checkout...");
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 2,)));
        } else {
          GlobalSnackbar.show(context, success: true, message: "Added to cart successfully");
        }
      } else {
        GlobalSnackbar.show(context, success: false, message: response.message ?? "Failed to add to cart");
      }
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Service Error: $e");
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 2,))
              );
            },
          )
        ],
      ),
      body: FutureBuilder<ApiResponse<ProductDetailResponse>>(
        future: _productFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. No Data / API Failure
          else if (!snapshot.hasData || snapshot.data!.data == null) {
            return const Center(child: Text("Product not found"));
          }

          // 4. Success State -> Render UI
          final productDetail = snapshot.data!.data!;
          final product = productDetail.product;
          final images = product.images;
          final attributes = productDetail.attributes;
          final shop = productDetail.shop;
          final category = productDetail.category;

          // --- AUTO SELECT DEFAULT SKU ---
          // Run this only once when data is loaded and no selection is made
          if (_selectedAttributes.isEmpty && productDetail.skus.isNotEmpty) {
            // Find first SKU with stock > 0, otherwise just take the first one
            final defaultSku = productDetail.skus.firstWhere(
                    (s) => s.stock > 0,
                orElse: () => productDetail.skus.first
            );

            // Populate the selection map
            for (var val in defaultSku.values) {
              _selectedAttributes[val.attributeId] = val.valueId;
            }
            _selectedSku = defaultSku;
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(images, product.name, shop.shopName, category),

                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductHeader(product, shop, _getCurrentPrice(productDetail)),
                              const SizedBox(height: 24),

                              if (attributes.isNotEmpty)
                                ...attributes.map((attr) => _buildAttributeSelector(productDetail, attr)),

                              const SizedBox(height: 24),
                              _buildTabs(productDetail),
                              const SizedBox(height: 16),
                              _buildTabContent(productDetail),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomActions(productDetail),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProductHeader(Product product, Shop shop, double price) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // LEFT SIDE: Name & Rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('${product.rating}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(width: 8),
                  Text('${_formatSoldCount(product.soldCount)} sold', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),

        // RIGHT SIDE: Price & Quantity
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppConfig.formatCurrency(price),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            // Quantity Selector
            _buildQuantitySelector(),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    bool canIncrease = _selectedSku != null && _quantity < _selectedSku!.stock;
    bool canDecrease = _quantity > 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCircleIconBtn(
              icon: Icons.remove,
              onTap: canDecrease ? _decrementQuantity : null,
              isActive: canDecrease
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$_quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildCircleIconBtn(
              icon: Icons.add,
              onTap: canIncrease ? _incrementQuantity : null,
              isActive: canIncrease
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconBtn({required IconData icon, VoidCallback? onTap, required bool isActive}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: isActive ? [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))] : null
        ),
        child: Icon(icon, size: 16, color: isActive ? Colors.black : Colors.grey),
      ),
    );
  }


  Widget _buildHeroSection(List<ProductImage> images, String productName, String shopName, ProductCategory category) {
    return Container(
      height: 450,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppConfig.primary300, AppConfig.primary100],
              ),
            ),
          ),
          Positioned(
            top: 0, bottom: 0, left: 0, right: 0,
            child: Center(
              child: Text(
                  shopName.toUpperCase(),
                  style: GoogleFonts.anton(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.15),
                  )
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemCount: images.isEmpty ? 1 : images.length,
            itemBuilder: (context, index) {
              if (images.isEmpty) {
                return const Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.white54));
              }
              return Center(
                child: Transform.rotate(
                  angle: -0.2,
                  child: Image.network(
                    images[index].imageUrl,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.white54),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 30, left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(category.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // (Include Attribute Selectors logic from previous response here)
  Widget _buildAttributeSelector(ProductDetailResponse data, ProductAttribute attribute) {
    final selectedValueId = _selectedAttributes[attribute.attributeId];
    bool isVisualAttribute = attribute.values.isNotEmpty &&
        attribute.values.first.imageUrl != null &&
        attribute.values.first.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            attribute.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          isVisualAttribute
              ? _buildImageAttributeSelector(data, attribute.values, selectedValueId, attribute.attributeId)
              : _buildTextAttributeSelector(data, attribute.values, selectedValueId, attribute.attributeId),
        ],
      ),
    );
  }

  Widget _buildImageAttributeSelector(ProductDetailResponse data, List<AttributeValue> values, int? selectedId, int attributeId) {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: values.map((value) {
        final isSelected = selectedId == value.valueId;
        return GestureDetector(
          onTap: () => _selectAttribute(data, attributeId, value.valueId),
          child: Column(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isSelected ? Colors.black87 : Colors.grey[200]!, width: isSelected ? 2 : 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: value.imageUrl != null ? DecorationImage(image: NetworkImage(value.imageUrl!), fit: BoxFit.cover) : null,
                      color: Colors.grey[100],
                    ),
                    child: value.imageUrl == null ? Center(child: Text(value.value[0], style: const TextStyle(fontSize: 12))) : null,
                  ),
                ),
              ),
              if (isSelected) Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(value.value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)))
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAttributeSelector(ProductDetailResponse data, List<AttributeValue> values, int? selectedId, int attributeId) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: values.map((value) {
        final isSelected = selectedId == value.valueId;
        return GestureDetector(
          onTap: () => _selectAttribute(data, attributeId, value.valueId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.white,
              border: Border.all(color: isSelected ? Colors.black87 : Colors.grey[300]!, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value.value, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabs(ProductDetailResponse data) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.grey[500],
      labelStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
      indicatorColor: Colors.black87,
      indicatorWeight: 3,
      tabs: [
        const Tab(text: 'Description'),
        const Tab(text: 'Shop',),
        Tab(text: 'Reviews (${data.reviews.length})'),
      ],
    );
  }

  Widget _buildTabContent(ProductDetailResponse data) {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDescriptionTab(data),
          _buildShopTab(data),
          _buildReviewsTab(data.reviews, data.product.rating)
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(ProductDetailResponse data) {
    final product = data.product;
    final category = data.category;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Description Section
          Text("Description", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            product.description.isEmpty ? "No description available." : product.description,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),

          const SizedBox(height: 24),

          // 2. Product Details Table
          Text("Category", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            category.name,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], height: 1.5),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildShopTab(ProductDetailResponse data) {
    final shop = data.shop;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. Seller Info Card
          Text("Sold By", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ]
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: shop.shopLogo.isNotEmpty ? NetworkImage(shop.shopLogo) : null,
                  child: shop.shopLogo.isEmpty ? const Icon(Icons.store, color: Colors.grey) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.shopName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text("${shop.rating}  •  ${shop.followersCount} Followers",
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                        ],
                      )
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: Text("Visit", style: GoogleFonts.inter(color: Colors.black, fontSize: 12)),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(List<ProductReview> reviews, double productRating) {
    final allReviews = reviews;

    if (allReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("No reviews yet", style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      );
    }

    // 1. Logic to filter reviews based on selection
    List<ProductReview> filteredReviews = _selectedStarFilter == 0
        ? allReviews
        : allReviews.where((r) => r.rating.round() == _selectedStarFilter).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 2. Header Stats
        Row(
          children: [
            Text(
              "$productRating",
              style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.bold, height: 1),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStarBar(5),
                Text("${allReviews.length} Ratings", style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
              ],
            )
          ],
        ),

        const SizedBox(height: 20),

        // 3. Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip("All", 0),
              _buildFilterChip("5 Star", 5, icon: Icons.star),
              _buildFilterChip("4 Star", 4, icon: Icons.star),
              _buildFilterChip("3 Star", 3, icon: Icons.star),
              _buildFilterChip("2 Star", 2, icon: Icons.star),
              _buildFilterChip("1 Star", 1, icon: Icons.star),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 4. Render the FILTERED list
        if (filteredReviews.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(child: Text("No reviews found for this filter", style: GoogleFonts.inter(color: Colors.grey))),
          )
        else
          ...filteredReviews.map((review) => _buildReviewItem(review)),
      ],
    );
  }

// Corrected Filter Chip Widget
  Widget _buildFilterChip(String label, int starValue, {IconData? icon}) {
    bool isSelected = _selectedStarFilter == starValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStarFilter = starValue;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.amber),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(ProductReview review) {
    String dateStr = DateFormat('dd MMM yyyy').format(review.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("User ${review.userId}", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(dateStr, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: GoogleFonts.inter(color: Colors.grey[600], height: 1.4, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStarBar(int count) {
    return Row(
      children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 16)),
    );
  }

  Widget _buildBottomActions(ProductDetailResponse data) {
    // Logic: Enable button only if SKU is selected and stock is sufficient
    bool hasAttributes = data.attributes.isNotEmpty;
    bool canAction = false;

    if (!hasAttributes) {
      canAction = true;
    } else {
      canAction = _selectedSku != null && _selectedSku!.stock > 0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canAction && !_isActionLoading ? () => _handleAction(true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primary200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: _isActionLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Buy Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: canAction && !_isActionLoading ? () => _handleAction(false) : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: _isActionLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add To Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }



}