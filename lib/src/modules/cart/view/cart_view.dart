import 'package:flutter/material.dart';

// --- 1. Import trang Checkout ---
import '../../checkout/view/checkout_view.dart';

// Import model sản phẩm gốc
import '../../product_detail/models/product_detail.dart';

// --- MODEL RIÊNG CHO CART ---
// (Mình đưa lên đầu hoặc để cuối đều được, nhưng phải public để các file khác gọi được)
class CartItemModel {
  final String name;
  final double price;
  final String imageUrl;
  final String size;
  final String colorName;
  int quantity;

  CartItemModel({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.size,
    required this.colorName,
    this.quantity = 1,
  });
}

class CartView extends StatefulWidget {
  final List<CartItemModel> cartItems;

  const CartView({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  // Biến local để xử lý hiển thị và xóa
  late List<CartItemModel> _items;
  double shippingFee = 30000;

  @override
  void initState() {
    super.initState();
    // 2. Nạp dữ liệu từ bên ngoài vào biến local để thao tác
    _items = widget.cartItems;
  }

  // Tính tổng tiền dựa trên danh sách _items hiện tại
  double get subTotal {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get finalTotal => subTotal + shippingFee;

  String formatCurrency(double amount) {
    return "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";
  }

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
      body: Column(
        children: [
          Expanded(
            // Dùng _items thay vì widget.cartItems
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
          // Chỉ hiện khung thanh toán nếu có hàng
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
          // Ảnh sản phẩm
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                // Xử lý ảnh phòng trường hợp url rỗng
                image: NetworkImage(item.imageUrl.isNotEmpty ? item.imageUrl : "https://via.placeholder.com/80"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Thông tin
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Xóa item khỏi danh sách _items
                        setState(() {
                          _items.removeAt(index);
                        });
                      },
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    )
                  ],
                ),
                Text("${item.size} | ${item.colorName}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatCurrency(item.price),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: [
                        _btnQty(Icons.remove, () {
                          if (item.quantity > 1) setState(() => item.quantity--);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        _btnQty(Icons.add, () => setState(() => item.quantity++)),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _rowSummary("Tạm tính", formatCurrency(subTotal)),
          const SizedBox(height: 10),
          _rowSummary("Phí vận chuyển", formatCurrency(shippingFee)),
          const Divider(height: 30),
          _rowSummary("Tổng thanh toán", formatCurrency(finalTotal), isBold: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              // --- 3. LOGIC CHUYỂN TRANG THANH TOÁN ---
              onPressed: () {
                if (_items.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Truyền danh sách _items sang CheckoutView
                      builder: (context) => CheckoutView(checkoutItems: _items),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Giỏ hàng đang trống!")),
                  );
                }
              },
              child: const Text("Thanh toán ngay", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
        Text(title, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}