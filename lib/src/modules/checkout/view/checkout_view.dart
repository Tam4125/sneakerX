import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/config/app_config.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart'; // Unified Snackbar
import 'package:sneakerx/src/models/enums/payment_method.dart';
import 'package:sneakerx/src/models/enums/payment_status.dart';
import 'package:sneakerx/src/models/user_address.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_response.dart';
import 'package:sneakerx/src/modules/cart/dtos/cart_item_response.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_order_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/create_stripe_intent_request.dart';
import 'package:sneakerx/src/modules/checkout/dtos/update_payment_status.dart';
import 'package:sneakerx/src/modules/profile/view/address_management_view.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/order_service.dart';
import 'package:sneakerx/src/services/payment_service.dart';
import 'package:sneakerx/src/services/user_service.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';
import '../models/checkout_models.dart';
import '../widgets/voucher_bottom_sheet.dart';
import '../widgets/shipping_method_sheet.dart';
import '../widgets/payment_method_sheet.dart';

class CheckoutView extends StatefulWidget {
  final List<CartItemResponse> checkoutItems;
  const CheckoutView({super.key, required this.checkoutItems});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();
  final PaymentService _paymentService = PaymentService();

  late UserSignInResponse _user;
  bool _isLoading = false;

  // Address State
  UserAddress? _userAddress;

  // Logic: Map<ShopID, ShippingMethod>
  final Map<int, ShippingMethod> _shippingMap = {};

  // Logic: Group items by ShopID for UI rendering
  final Map<int, List<CartItemResponse>> _itemsByShop = {};

  final Map<int, TextEditingController> _noteMap = {};

  late PaymentMethodModel _selectedPayment;
  VoucherModel? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _user = auth.currentUser!;

    // 1. Group Items by Shop
    for (var item in widget.checkoutItems) {
      if (!_itemsByShop.containsKey(item.shopId)) {
        _itemsByShop[item.shopId] = [];
        // Set Default Shipping for this shop
        _shippingMap[item.shopId] = CheckoutData.shippingOptions.first;
      }
      _itemsByShop[item.shopId]!.add(item);
    }

    // 2. Set Default Payment
    _selectedPayment = CheckoutData.paymentMethods.where((ele) => ele.id == 'COD').first;

    // 3. Load Address
    setState(() => _isLoading = true);
    try {
      final addressResponse = await _userService.getAddresses();

      if (addressResponse.success && addressResponse.data != null) {
        final addresses = addressResponse.data!;
        try {
          _userAddress = addresses.firstWhere((ele) => ele.isDefault);
        } catch (e) {
          _userAddress = addresses.first;
        }
      }
    } catch (e) {
      print("Error loading address: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _noteMap.values) {
      controller.dispose();
    }
  }

  // --- CALCULATION LOGIC ---
  double get totalSubTotal => widget.checkoutItems.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));

  double get totalShippingFee {
    double total = 0;
    _shippingMap.forEach((key, value) {
      total += value.price;
    });
    return total;
  }

  double get discountAmount {
    if (_selectedVoucher == null) return 0;
    if (_selectedVoucher!.isFreeShip) {
      return totalShippingFee < _selectedVoucher!.discountValue
          ? totalShippingFee
          : _selectedVoucher!.discountValue;
    }
    return _selectedVoucher!.discountValue;
  }

  double get finalTotal {
    double total = totalSubTotal + totalShippingFee - discountAmount;
    return total > 0 ? total : 0;
  }

  // --- ORDER PLACEMENT LOGIC ---
  Future<void> _handlePlaceOrder() async {
    if (_userAddress == null) {
      GlobalSnackbar.show(context, success: false, message: "Please select a delivery address");
      return;
    }

    setState(() => _isLoading = true);

    String finalTransactionId = "COD_NO_ID";
    String? stripeClientSecret;
    PaymentStatus paymentStatus = PaymentStatus.AWAITING_PAYMENT;

    try {
      // A. PREPARE STRIPE (If selected)
      if (_selectedPayment.id == 'STRIPE') {
        // Note: Check if your User model structure is _user.user.userId or _user.userId
        final stripeRequest = CreateStripeIntentRequest(
            userId: _user.user.userId,
            amount: finalTotal,
            currency: "usd",
            userEmail: _user.user.email
        );

        final intentResponse = await _paymentService.createStripeIntent(stripeRequest);

        if(!intentResponse.success || intentResponse.data == null) {
          GlobalSnackbar.show(context, success: false, message: intentResponse.message);
          return;
        }

        if (intentResponse.success && intentResponse.data != null) {
          final intent = intentResponse.data!;
          finalTransactionId = intent.transactionId;
          stripeClientSecret = intent.clientSecret;
        }
      }

      // B. PREPARE DATA FOR BACKEND
      Map<int, List<int>> itemMap = {};
      Map<int, double> subTotalMap = {};
      Map<int, double> shippingFeeMap = {};
      Map<int, String> noteMap = {};

      _itemsByShop.forEach((shopId, items) {
        itemMap[shopId] = items.map((e) => e.itemId).toList();

        double shopSub = items.fold(0, (sum, i) => sum + (i.unitPrice * i.quantity));
        subTotalMap[shopId] = shopSub;

        shippingFeeMap[shopId] = _shippingMap[shopId]?.price ?? 0;

        noteMap[shopId] = _noteMap[shopId] != null ? _noteMap[shopId]!.text : "";
      });


      // C. CALL CREATE ORDER API
      CreateOrderRequest orderRequest = CreateOrderRequest(
        addressId: _userAddress!.addressId,
        noteMap: noteMap,
        itemMap: itemMap,
        shippingFeeMap: shippingFeeMap,
        subTotalMap: subTotalMap,
        totalAmount: finalTotal,
        paymentMethod: SneakerXPaymentMethod.values.where((val) => val.name == _selectedPayment.id).first,
        transactionId: finalTransactionId,
        paymentStatus: paymentStatus,
      );

      final orderResponse = await _orderService.createOrder(orderRequest);

      if (!orderResponse.success || orderResponse.data == null) {
        GlobalSnackbar.show(context, success: false, message: orderResponse.message);
        return;
      }

      // D. HANDLE STRIPE UI FLOW
      if (_selectedPayment.id == 'STRIPE' && stripeClientSecret != null) {
        try {
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: stripeClientSecret,
              merchantDisplayName: 'SneakerX Store',
              style: ThemeMode.light,
            ),
          );

          setState(() => _isLoading = false); // Hide loader to show sheet
          await Stripe.instance.presentPaymentSheet();

          try {
            UpdatePaymentStatusRequest updatePaymentStatusRequest = UpdatePaymentStatusRequest(
              paymentId: orderResponse.data!.paymentId,
              paymentStatus: PaymentStatus.PAID
            );

            final paymentResponse = await _paymentService.updatePaymentStatus(updatePaymentStatusRequest);

            if(!paymentResponse.success || paymentResponse.data == null) {
              GlobalSnackbar.show(context, success: false, message: "Update payment status failed!");
            }
            GlobalSnackbar.show(context, success: true, message: "Place Order Successfully!");
          } catch(e) {
            GlobalSnackbar.show(context, success: false, message: "Update payment status failed");
          }

        } on StripeException catch (e) {
          if (e.error.code == FailureCode.Canceled) {
            GlobalSnackbar.show(context, success: true, message: "Payment canceled. Order saved.");
          } else {
            GlobalSnackbar.show(context, success: false, message: "Payment failed: ${e.error.localizedMessage}");
          }
        }
      } else {
        GlobalSnackbar.show(context, success: true, message: "Order placed successfully!");
      }

      // E. NAVIGATE HOME
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 2)), // Tab 2 = Orders
              (route) => false,
        );
      }

    } catch (e) {
      GlobalSnackbar.show(context, success: false, message: "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                  // Render List of Shops
                  ..._itemsByShop.keys.map((shopId) => _buildShopSection(shopId)).toList(),

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

  // 1. ADDRESS SECTION
  Widget _buildAddressSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () async {
          // Navigate to Address Management, wait for result
          final selectedAddress = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressManagementView(isFromCheckOut: true))
          );

          if (selectedAddress != null && selectedAddress is UserAddress) {
            setState(() {
              _userAddress = selectedAddress;
            });
          }
        },
        leading: const Icon(Icons.location_on_outlined, color: AppConfig.primary200),
        title: const Text("Delivery Address", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: _userAddress == null
            ? const Text("Please select an address")
            : Text("${_userAddress!.recipientName} | ${_userAddress!.phone}\n${_userAddress!.addressLine}, ${_userAddress!.ward}, ${_userAddress!.district}, ${_userAddress!.provinceOrCity}"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  // 2. SHOP SECTION (Items + Shipping for ONE shop)
  Widget _buildShopSection(int shopId) {
    final items = _itemsByShop[shopId]!;
    final shopName = items.first.shopName;
    final currentShipping = _shippingMap[shopId]!;
    _noteMap[shopId] = TextEditingController();

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.store, size: 18),
                const SizedBox(width: 8),
                Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items
          ...items.map((item) => _buildItemRow(item)).toList(),

          const Divider(height: 1),

          // Shipping Selection for THIS shop
          ListTile(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => ShippingMethodSheet(
                  selectedShipping: currentShipping,
                  onShippingSelected: (newMethod) => setState(() {
                    _shippingMap[shopId] = newMethod; // Update specific shop
                  }),
                ),
              );
            },
            title: const Text("Shipping Option", style: TextStyle(fontSize: 13, color: Colors.green)),
            subtitle: Text("${currentShipping.name} - ${AppConfig.formatCurrency(currentShipping.price)}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            trailing: const Icon(Icons.chevron_right, size: 18),
          ),

          // Message Input (Optional: Per shop)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _noteMap[shopId],
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Note to Seller...",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemRow(CartItemResponse item) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFAFAFA),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  image: NetworkImage(item.productImageUrl),
                  fit: BoxFit.cover,
                )
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item.variantDescription, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppConfig.formatCurrency(item.unitPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("x${item.quantity}", style: const TextStyle(fontSize: 13)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // 3. VOUCHER & PAYMENT (Global)
  Widget _buildVoucherAndPayment() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.confirmation_number_outlined, color: AppConfig.primary200),
            title: const Text("SneakerX Voucher"),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_selectedVoucher != null ? "-${AppConfig.formatCurrency(discountAmount)}" : "Select Code",
                  style: TextStyle(color: _selectedVoucher != null ? Colors.orange : Colors.grey)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]),
            onTap: () {
              showModalBottomSheet(
                context: context, backgroundColor: Colors.transparent,
                builder: (context) => VoucherBottomSheet(
                  currentSubTotal: totalSubTotal,
                  onVoucherSelected: (voucher) => setState(() => _selectedVoucher = voucher),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.payment, color: AppConfig.primary200),
            title: const Text("Payment Method"),
            subtitle: Text(_selectedPayment.name, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              showModalBottomSheet(
                context: context, backgroundColor: Colors.transparent,
                builder: (context) => PaymentMethodSheet(
                  onMethodSelected: (method, bank) {
                    setState(() {
                      _selectedPayment = method;
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

  // 4. BILL DETAIL
  Widget _buildBillDetail() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _row("Subtotal", AppConfig.formatCurrency(totalSubTotal)),
          _row("Shipping Fee", AppConfig.formatCurrency(totalShippingFee)),
          if(discountAmount > 0)
            _row("Discount", "-${AppConfig.formatCurrency(discountAmount)}", color: Colors.orange),
          const Divider(height: 20),
          _row("Total Payment", AppConfig.formatCurrency(finalTotal), isBold: true, size: 18, color: AppConfig.primary200),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, double size = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text(value, style: TextStyle(fontSize: size, fontWeight: isBold?FontWeight.bold:FontWeight.normal, color: color ?? Colors.black))
          ]
      ),
    );
  }

  // 5. BOTTOM BAR
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,-2))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Total Payment", style: TextStyle(fontSize: 12)),
                Text(AppConfig.formatCurrency(finalTotal), style: const TextStyle(color: AppConfig.primary200, fontSize: 18, fontWeight: FontWeight.bold)),
              ]
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primary200,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                elevation: 0
            ),
            onPressed: _isLoading ? null : _handlePlaceOrder,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Place Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}