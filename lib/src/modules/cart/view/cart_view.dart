import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/modules/cart/dtos/cart_response.dart';
import 'package:sneakerx/src/modules/cart/dtos/cart_item_response.dart';
import 'package:sneakerx/src/modules/cart/dtos/update_cart_request.dart';
import 'package:sneakerx/src/modules/cart/view/empty_cart_view.dart';
import 'package:sneakerx/src/modules/checkout/view/checkout_view.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/cart_service.dart';
import 'package:sneakerx/src/utils/api_response.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  bool _isLoading = false;

  // For managing item quantities locally before updating
  final Map<int, int> _localQuantities = {};

  // For optimistic UI updates
  late Future<ApiResponse<CartResponse>> _cartFuture;

  // Delivery fee (you can make this dynamic)
  final double _deliveryFee = 5.00;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if(!auth.isGuest){
      _cartFuture = _cartService.getCurrentUserCart();
    }
  }

  void _refreshCart() {
    setState(() {
      _cartFuture = _cartService.getCurrentUserCart();
      _localQuantities.clear();
    });
  }

  void _updateQuantity(int itemId, int newQuantity) async {
    if (newQuantity < 1) return;

    // Optimistic update
    setState(() {
      _localQuantities[itemId] = newQuantity;
    });
  }

  // CORE LOGIC: Update DB -> Check Stock -> Navigate
  Future<void> _handleCheckout(List<CartItemResponse> currentItems) async {
    setState(() => _isLoading = true);

    try {
      List<CartItemResponse> items = currentItems;
      // 1. If there are local changes, send them to the server first
      if (_localQuantities.isNotEmpty) {
        final request = UpdateCartRequest(updatedQuantities: _localQuantities);
        final updateResponse = await _cartService.updateCart(request);

        if (!updateResponse.success) {
          throw Exception(updateResponse.message);
        }

        final freshItems = updateResponse.data!.cartItems;
        items = freshItems;
      }

      // 3. Validate Stock
      // Check for unavailable items or items where requested quantity > stock
      final unavailableItems = items.where((item) {
        return !item.available || item.quantity > item.currentStock;
      }).toList();

      if (unavailableItems.isNotEmpty) {
        // Validation Failed
        _refreshCart(); // Refresh UI to show the user which items are out of stock (red labels)

        String errorMsg = unavailableItems.length == 1
            ? "${unavailableItems.first.productName} is currently unavailable."
            : "Some items in your cart are unavailable or out of stock.";

        GlobalSnackbar.show(context, success: false, message: errorMsg);
      } else {
        // 4. Validation Passed - Navigate to Checkout
        // Clear local quantities as they are now saved
        _localQuantities.clear();

        // Navigate
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CheckoutView(checkoutItems: items,)),
        );

        GlobalSnackbar.show(context, success: true, message: "Proceeding to Checkout...");
      }

    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteItem(int itemId) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text('Are you sure you want to remove this item from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _cartService.deleteCartItem(itemId);
        _refreshCart();

        GlobalSnackbar.show(context, success: true, message: "Item removed from cart");
      } catch (e) {
        GlobalSnackbar.show(context, success: false, message: "Failed to remove item");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: auth.isGuest
        ? EmptyCartView()
        : FutureBuilder<ApiResponse<CartResponse>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primary200),
              ),
            );
          }

          // Error state
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.success) {
            return _buildErrorState(snapshot.data?.message);
          }

          final cartResponse = snapshot.data!.data!;
          final cartItems = cartResponse.cartItems;

          // Empty cart state
          if (cartItems.isEmpty) {
            return _buildEmptyCart();
          }

          // Cart content
          return _buildCartContent(cartItems);
        },
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            errorMessage ?? 'Failed to load cart',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primary200,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add some sneakers to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0,))
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primary200,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Start Shopping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(List<CartItemResponse> cartItems) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(cartItems[index]);
            },
          ),
        ),

        // Bottom Section with Summary
        _buildBottomSection(cartItems),
      ],
    );
  }

  Widget _buildCartItem(CartItemResponse item) {
    final displayQuantity = _localQuantities[item.itemId] ?? item.quantity;
    final itemTotal = item.unitPrice * displayQuantity;

    return Dismissible(
      key: Key('cart_item_${item.itemId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteItem(item.itemId),
      background: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: item.productImageUrl.isNotEmpty
                    ? Image.network(
                  item.productImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                )
                    : _buildPlaceholderImage(),
              ),
            ),

            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.variantDescription.isNotEmpty
                        ? item.variantDescription
                        : item.skuCode,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (!item.available)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (item.currentStock < 5)
                    Text(
                      'Only ${item.currentStock} left',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${itemTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: item.available
                                  ? () => _updateQuantity(
                                item.itemId,
                                displayQuantity - 1,
                              )
                                  : null,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                displayQuantity.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: item.available &&
                                  displayQuantity < item.currentStock
                                  ? () => _updateQuantity(
                                item.itemId,
                                displayQuantity + 1,
                              )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteItem(item.itemId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 20,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(List<CartItemResponse> cartItems) {
    final subtotal = cartItems.fold<double>(
      0.0,
          (sum, item) {
        final quantity = _localQuantities[item.itemId] ?? item.quantity;
        return sum + (item.unitPrice * quantity);
      },
    );

    // Removed discount calculation
    final total = subtotal + _deliveryFee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Order Summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                _buildSummaryRow('Sub Total', subtotal),
                SizedBox(height: 12),
                _buildSummaryRow('Delivery fee', _deliveryFee),
                SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey[300]),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Checkout Button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                  ? null
                  : () => _handleCheckout(cartItems),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConfig.primary300,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}