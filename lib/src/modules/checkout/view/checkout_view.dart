import 'package:flutter/material.dart';
import 'package:sneakerx/src/modules/cart/models/cart_model.dart';

// 1. IMPORT CÁC FILE TRONG FOLDER CỦA BẠN
import '../models/checkout_models.dart';
import '../widgets/voucher_bottom_sheet.dart';
import '../widgets/payment_method_sheet.dart';
import '../widgets/shipping_method_sheet.dart';

class CheckoutView extends StatefulWidget {
  final List<CartItemModel> checkoutItems;
  const CheckoutView({Key? key, required this.checkoutItems}) : super(key: key);

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // --- STATE DỮ LIỆU ---
  String _customerName = "Nguyễn Văn A";
  String _phoneNumber = "0987.654.321";
  String _address = "Số 123, Đường ABC, Quận XYZ, TP.HCM";
  final TextEditingController _noteController = TextEditingController();

  // Các biến lựa chọn
  late ShippingMethod _selectedShipping;
  late PaymentMethod _selectedPayment;
  BankModel? _selectedBank;
  VoucherModel? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    // Mặc định chọn Giao hàng nhanh (30k)
    _selectedShipping = ShippingMethod(id: 'GHN', name: "Giao Hàng Nhanh", estimateTime: "1-3 ngày", price: 30000);
    // Mặc định chọn COD
    _selectedPayment = PaymentMethod(id: 'COD', name: "Thanh toán khi nhận hàng (COD)", iconData: Icons.money);
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
                  _buildAddressSection(), // <--- Đã sửa để bấm được
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

  // --- CÁC WIDGET CON ---

  // 1. ĐỊA CHỈ (ĐÃ SỬA: Thêm onTap và hàm _showEditAddressDialog)
  Widget _buildAddressSection() => Container(
      color: Colors.white, margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: _showEditAddressDialog, // <--- BẮT SỰ KIỆN TẠI ĐÂY
        leading: const Icon(Icons.location_on_outlined, color: Colors.green,),
        title: const Text("Địa chỉ nhận hàng", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text("$_customerName | $_phoneNumber\n$_address"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      )
  );

  // Hàm hiển thị Popup sửa địa chỉ
  void _showEditAddressDialog() {
    final nameCtrl = TextEditingController(text: _customerName);
    final phoneCtrl = TextEditingController(text: _phoneNumber);
    final addressCtrl = TextEditingController(text: _address);

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Địa chỉ nhận hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "SĐT", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Địa chỉ", border: OutlineInputBorder())),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5FBF)),
                        onPressed: (){
                          setState(() {
                            _customerName = nameCtrl.text;
                            _phoneNumber = phoneCtrl.text;
                            _address = addressCtrl.text;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Xác nhận", style: TextStyle(color: Colors.white))
                    )
                ),
                const SizedBox(height: 20),
              ]),
        )
    );
  }

  // 2. SHIPPING
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
              onShippingSelected: (newMethod) {
                setState(() => _selectedShipping = newMethod);
              },
            ),
          );
        },
        leading: const Icon(Icons.local_shipping_outlined, color: Colors.green),
        title: const Text("Phương thức vận chuyển", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_selectedShipping.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            Text(_selectedShipping.estimateTime, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatCurrency(_selectedShipping.price), style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 3. VOUCHER & PAYMENT
  Widget _buildVoucherAndPayment() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // VOUCHER
          ListTile(
            leading: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF8B5FBF)),
            title: const Text("NeakerX Voucher"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedVoucher != null ? "-${formatCurrency(discountAmount)}" : "Chọn mã",
                    style: TextStyle(color: _selectedVoucher != null ? Colors.orange : Colors.grey)),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
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

          // PAYMENT
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

  // CÁC WIDGET CÒN LẠI (SẢN PHẨM, TIN NHẮN, BILL, BOTTOM BAR)
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đặt hàng thành công! (${_selectedPayment.name})")));
          },
          child: const Text("Đặt hàng", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    ),
  );
}