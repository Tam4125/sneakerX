import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // Import Stripe
import 'package:provider/provider.dart';
import 'package:sneakerx/src/models/enums/order_status.dart';
import 'package:sneakerx/src/models/order.dart';
import 'package:sneakerx/src/models/user_address.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/modules/cart/models/cart_model.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_order_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_stripe_intent_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/update_order_request.dart';
import 'package:sneakerx/src/modules/profile/view/edit_profile_view.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/order_service.dart';
import 'package:sneakerx/src/services/payment_service.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import '../models/checkout_models.dart';
import '../widgets/voucher_bottom_sheet.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/shipping_method_sheet.dart';

class CheckoutView extends StatefulWidget {
  final List<CartItemModel> checkoutItems;
  const CheckoutView({super.key, required this.checkoutItems});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {

  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _noteController = TextEditingController();
  late UserSignInResponse _user;
  late int _shopId;

  bool _isLoading = false;

  String _customerName = "Customer name";
  String _phoneNumber = "Phone number";
  String _address = "Address";
  UserAddress? _userAddress;

  late ShippingMethod _selectedShipping;
  late PaymentMethodModel _selectedPayment;
  BankModel? _selectedBank;
  VoucherModel? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    _selectedShipping = ShippingMethod(id: 'GHN', name: "Giao Hàng Nhanh", estimateTime: "1-3 ngày", price: 30000);
    _selectedPayment = PaymentMethodModel(id: 'COD', name: "Thanh toán khi nhận hàng (COD)", iconData: Icons.money);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    _user = auth.currentUser!;

    setState(() => _isLoading = true);

    try {
      final addresses = await _userService.getAddresses();
      if (addresses != null && addresses.isNotEmpty) {
        _userAddress = addresses.first;
        _customerName = _userAddress!.recipientName;
        _phoneNumber = _userAddress!.phone;
        _address = "${_userAddress!.addressLine}, ${_userAddress!.ward}, ${_userAddress!.district}, ${_userAddress!.provinceOrCity}";
      }
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePlaceOrder() async {
    if (_userAddress == null) {
      _showMessage("Vui lòng thêm địa chỉ nhận hàng");
      return;
    }

    setState(() => _isLoading = true);

    String finalTransactionId = "COD_NO_ID";
    String? stripeClientSecret;
    OrderStatus orderStatus = OrderStatus.SHIPPED;

    try {
      // BƯỚC 1: Nếu là Stripe, tạo Intent TRƯỚC để lấy ID
      if (_selectedPayment.id == 'STRIPE') {
        orderStatus = OrderStatus.PENDING;
        final stripeRequest = CreateStripeIntentRequest(
            userId: _user.userId,
            amount: finalTotal,
            currency: "vnd",
            userEmail: _user.email
        );

        // Gọi API tạo Intent (trả về clientSecret và transactionId)
        final intentData = await _paymentService.createStripeIntent(stripeRequest);

        if (intentData != null) {
          finalTransactionId = intentData.transactionId; // ID này dùng để lưu Order
          stripeClientSecret = intentData.clientSecret;  // Secret này dùng để hiện UI
        } else {
          throw Exception("Không thể khởi tạo thanh toán Stripe");
        }
      }

      // BƯỚC 2: Lưu đơn hàng vào Database (Status: PENDING)
      CreateOrderRequest orderRequest = CreateOrderRequest(
        shopId: _shopId,
        addressId: _userAddress!.addressId,
        shippingFee: _selectedShipping.price,
        cartItems: widget.checkoutItems.map((cartItem) => cartItem.itemId).toList(),
        provider: _selectedPayment.id,
        transactionId: finalTransactionId,
        orderStatus: orderStatus.name,
      );

      final order = await _orderService.createOrder(orderRequest);

      if (order == null) throw Exception("Lưu đơn hàng thất bại");

      // BƯỚC 3: Nếu là Stripe, hiển thị màn hình thanh toán
      if (_selectedPayment.id == 'STRIPE' && stripeClientSecret != null) {
        try {
          // Initialize Sheet
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: stripeClientSecret,
              merchantDisplayName: 'SneakerX Store',
              style: ThemeMode.light,
            ),
          );

          setState(() => _isLoading = false); // Tắt loading để hiện Sheet

          // Show Sheet - Người dùng thanh toán tại đây
          await Stripe.instance.presentPaymentSheet();

          _showMessage("Thanh toán thành công!");

          try {
            Order? updatedOrder = await _orderService.updateOrderStatus(
              UpdateOrderStatusRequest(orderStatus: OrderStatus.PAID, orderId: order.orderId)
            );
            if(updatedOrder != null) {
              _showMessage("Lỗi cập nhật trạng thái đơn hàng sau thanh toán thành công!");
            }
          } catch (e) {
            _showMessage("Lỗi cập nhật trạng thái đơn hàng sau thanh toán!");
          }

        } on StripeException catch (e) {
          // Người dùng tắt popup hoặc thẻ lỗi
          // KHÔNG xóa đơn hàng. Đơn hàng vẫn tồn tại (PENDING).
          if (e.error.code == FailureCode.Canceled) {
            _showMessage("Đã lưu đơn hàng. Bạn có thể thanh toán lại trong Lịch sử đơn hàng.");
          } else {
            _showMessage("Lỗi thanh toán: ${e.error.localizedMessage}");
          }
        }
      } else {
        _showMessage("Đặt hàng thành công!");
      }

      // BƯỚC 4: Điều hướng về màn hình chính (Dù thanh toán hay chưa)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 3)),
              (route) => false,
        );
      }

    } catch (e) {
      _showMessage("Lỗi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // --- TÍNH TOÁN TIỀN ---
  double get subTotal => widget.checkoutItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get shippingFee => _selectedShipping.price;
  double get discountAmount {
    if (_selectedVoucher == null) return 0;
    if (_selectedVoucher!.isFreeShip) {
      return shippingFee < _selectedVoucher!.discountValue ? shippingFee : _selectedVoucher!.discountValue;
    }
    return _selectedVoucher!.discountValue;
  }
  double get finalTotal {
    double total = subTotal + shippingFee - discountAmount;
    return total > 0 ? total : 0;
  }
  String formatCurrency(double amount) => "${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ";

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thanh toán", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildAddressSection(),
                  _buildProductList(),
                  _buildShippingSection(),
                  _buildMessageInput(),
                  const SizedBox(height: 10),
                  _buildVoucherAndPayment(),
                  const SizedBox(height: 10),
                  _buildBillDetail(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAddressSection() => Container(
      color: Colors.white, margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfileView(isFromCheckOut: true,))
          );

          if(result) {
            setState(() {
              _initializeData();
            });
          }
        },
        leading: const Icon(Icons.location_on_outlined, color: Colors.green,),
        title: const Text("Địa chỉ nhận hàng", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text("$_customerName | $_phoneNumber\n$_address"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      )
  );


  Widget _buildShippingSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => ShippingMethodSheet(
              selectedShipping: _selectedShipping,
              onShippingSelected: (newMethod) => setState(() => _selectedShipping = newMethod),
            ),
          );
        },
        leading: const Icon(Icons.local_shipping_outlined, color: Colors.green),
        title: const Text("Phương thức vận chuyển", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_selectedShipping.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          Text(_selectedShipping.estimateTime, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(formatCurrency(_selectedShipping.price), style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildVoucherAndPayment() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF8B5FBF)),
            title: const Text("Vouchers"),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_selectedVoucher != null ? "-${formatCurrency(discountAmount)}" : "Chọn mã",
                  style: TextStyle(color: _selectedVoucher != null ? Colors.orange : Colors.grey)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]),
            onTap: () {
              showModalBottomSheet(
                context: context, backgroundColor: Colors.transparent,
                builder: (context) => VoucherBottomSheet(
                  currentSubTotal: subTotal,
                  onVoucherSelected: (voucher) => setState(() => _selectedVoucher = voucher),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 15, endIndent: 15),
          ListTile(
            leading: const Icon(Icons.payment, color: Color(0xFF8B5FBF)),
            title: const Text("Phương thức thanh toán"),
            subtitle: _selectedPayment.isBankTransfer && _selectedBank != null
                ? Text("CK: ${_selectedBank!.shortName}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                : Text(_selectedPayment.name, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              showModalBottomSheet(
                context: context, backgroundColor: Colors.transparent,
                builder: (context) => PaymentMethodSheet(
                  onMethodSelected: (method, bank) {
                    setState(() {
                      _selectedPayment = method;
                      _selectedBank = bank;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() => Container(
      color: Colors.white, padding: const EdgeInsets.all(15), margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: widget.checkoutItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(color:Colors.grey, width: 60, height: 60)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text("x${item.quantity} - ${formatCurrency(item.price)}", style: const TextStyle(fontWeight: FontWeight.bold))
            ]))
          ]),
        )).toList(),
      )
  );

  Widget _buildMessageInput() => Container(
      color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15), margin: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: _noteController, decoration: const InputDecoration(border: InputBorder.none, hintText: "Lưu ý cho người bán...", prefixIcon: Icon(Icons.message, size: 20)))
  );

  Widget _buildBillDetail() => Container(
      color: Colors.white, padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _row("Tổng tiền hàng", formatCurrency(subTotal)),
          _row("Phí vận chuyển", formatCurrency(shippingFee)),
          _row("Giảm giá", "-${formatCurrency(discountAmount)}", color: Colors.green),
          const Divider(),
          _row("Tổng thanh toán", formatCurrency(finalTotal), isBold: true, size: 18, color: const Color(0xFF8B5FBF)),
        ],
      )
  );

  Widget _row(String label, String value, {bool isBold = false, double size = 14, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      Text(value, style: TextStyle(fontSize: size, fontWeight: isBold?FontWeight.bold:FontWeight.normal, color: color ?? Colors.black))
    ]),
  );

  Widget _buildBottomBar() => Container(
    padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
    decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text("Tổng thanh toán", style: TextStyle(fontSize: 12)),
          Text(formatCurrency(finalTotal), style: const TextStyle(color: Color(0xFF8B5FBF), fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(width: 15),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5FBF), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
          // FIX: Call the new handler here
          onPressed: _isLoading ? null : _handlePlaceOrder,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Đặt hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    ),
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: Colors.grey[800]),
    );
  }
}