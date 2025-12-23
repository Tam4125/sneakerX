import 'package:flutter/material.dart';
import 'package:sneakerx/src/models/cart.dart';
import 'package:sneakerx/src/models/product.dart';
import 'package:sneakerx/src/modules/cart/models/cart_model.dart';
import 'package:sneakerx/src/services/cart_service.dart';
import '../../checkout/view/checkout_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartService _cartService = CartService();

  // State variables
  List<CartItemModel> _items = [];
  bool _isLoading = true; // Use this to show loading instead of FutureBuilder
  double shippingFee = 30000;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Fetch data ONCE when screen loads
  Future<void> _loadCartData() async {
    try {
      final cart = await _cartService.getCurrentUserCart();
      if (cart != null && cart.cartItems.isNotEmpty) {
        setState(() {
          _items = cart.cartItems
              .map((cartItem) => CartItemModel.fromCartItem(cartItem))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _items = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> _deleteCartItem(int itemId) async {
    try {
      await _cartService.deleteCartItem(itemId);
      return true;
    } catch (e) {
      _showMessage("Error delete cart item: $e");
      return false;
    }
  }

  // Calculate totals based on LOCAL state (_items)
  double get _subTotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _finalTotal => _subTotal + shippingFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Giỏ hàng",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // Use _isLoading flag instead of FutureBuilder
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text("Error: $_errorMessage"))
          : Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text("Giỏ hàng đang trống"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildCartItem(_items[index], index);
              },
            ),
          ),
          if (_items.isNotEmpty) _buildBottomCheckout(),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(item.imageUrl.isNotEmpty
                    ? item.imageUrl
                    : "https://via.placeholder.com/80"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          _items.removeAt(index);
                        });
                        await _deleteCartItem(item.itemId);
                      },
                      child: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                    )
                  ],
                ),
                Text("${item.size} | ${item.colorName}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(Product.formatCurrency(item.price),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: [
                        _btnQty(Icons.remove, () {
                          if (item.quantity > 1) {
                            setState(() {
                              item.quantity--;
                              // Note: Call API update quantity here if needed
                            });
                          }
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("${item.quantity}",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        _btnQty(Icons.add, () {
                          setState(() {
                            item.quantity++;
                            // Note: Call API update quantity here if needed
                          });
                        }),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _btnQty(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildBottomCheckout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _rowSummary("Tạm tính", Product.formatCurrency(_subTotal)),
          const SizedBox(height: 10),
          _rowSummary("Phí vận chuyển", Product.formatCurrency(shippingFee)),
          const Divider(height: 30),
          _rowSummary("Tổng thanh toán", Product.formatCurrency(_finalTotal),
              isBold: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (_items.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutView(checkoutItems: _items),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Giỏ hàng đang trống!")),
                  );
                }
              },
              child: const Text("Thanh toán ngay",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _rowSummary(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 18 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}