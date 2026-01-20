import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/models/order_item.dart';
import 'package:sneakerx/src/modules/profile/dtos/create_review_request.dart';
import 'package:sneakerx/src/services/product_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class RateProductSheet extends StatefulWidget {
  final List<OrderItem> items;
  const RateProductSheet({super.key, required this.items});

  @override
  State<RateProductSheet> createState() => _RateProductSheetState();
}

class _RateProductSheetState extends State<RateProductSheet> {
  final ProductService _productService = ProductService();

  // State maps keyed by Product ID
  final Map<int, double> _ratingMap = {};
  final Map<int, TextEditingController> _commentControllerMap = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and default ratings for ALL items
    for (var item in widget.items) {
      final pid = item.product.productId;
      _ratingMap[pid] = 5.0; // Default to 5 stars
      _commentControllerMap[pid] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    for (var controller in _commentControllerMap.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validate: Ensure user didn't somehow clear a rating (though default is 5)
    if (_ratingMap.length < widget.items.length) {
      GlobalSnackbar.show(context, success: false, message: "Please rate all items.");
      return;
    }

    List<int> productIds = [];
    Map<int, String> commentMap = {};

    for (var item in widget.items) {
      final pid = item.product.productId;
      productIds.add(pid);
      commentMap[pid] = _commentControllerMap[pid]?.text.trim() ?? "";
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser!.user;

    CreateReviewRequest request = CreateReviewRequest(
      userId: user.userId,
      productIds: productIds,
      ratingMap: _ratingMap,
      commentMap: commentMap,
    );

    setState(() => _isLoading = true);

    try {
      final response = await _productService.createReviews(request);
      if (response.success) {
        GlobalSnackbar.show(context, success: true, message: response.message);
        Navigator.pop(context, true); // Return true to trigger refresh if needed
      } else {
        GlobalSnackbar.show(context, success: false, message: response.message);
      }
    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate keyboard height to pad the bottom
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Constrain height so it doesn't take full screen if few items,
      // but expands if many (up to 85% screen height)
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0), // remove bottom padding here
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),

          // 2. Title
          Text("Leave a Review", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // 3. Scrollable List of Items
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const Divider(height: 40, thickness: 1),
              itemBuilder: (context, index) {
                return _buildProductCard(widget.items[index]);
              },
            ),
          ),

          const SizedBox(height: 16),

          // 4. Action Buttons (Pinned to bottom of sheet)
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding + 24),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text("Skip", style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Rate", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(OrderItem item) {
    final pid = item.product.productId;
    // Get state for this specific item
    double currentRating = _ratingMap[pid] ?? 0;
    TextEditingController controller = _commentControllerMap[pid]!;

    return Column(
      children: [
        // A. Product Info Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Image
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  image: item.product.images.isNotEmpty
                      ? DecorationImage(
                      image: NetworkImage(item.product.images.first.imageUrl),
                      fit: BoxFit.cover)
                      : null,
                ),
                child: item.product.images.isEmpty ? const Icon(Icons.image) : null,
              ),
              const SizedBox(width: 16),
              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productNameSnapshot, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("Variant: ${item.skuNameSnapshot}  Qty: ${item.quantity}",
                        style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    // Price & Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Text("Completed", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        Text(AppConfig.formatCurrency(item.priceAtPurchase), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 20),

        // B. Star Rating
        Text("How is this product?", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  _ratingMap[pid] = (index + 1).toDouble();
                });
              },
              icon: Icon(
                index < currentRating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 36,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), // Removes default padding
            );
          }).expand((widget) => [widget, const SizedBox(width: 8)]).toList()..removeLast(), // Add spacing
        ),

        const SizedBox(height: 16),

        // C. Review Input
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Type review...",
            hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          maxLines: 3,
          minLines: 1,
        ),
      ],
    );
  }
}