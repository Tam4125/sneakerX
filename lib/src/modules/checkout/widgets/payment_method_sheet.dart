import 'package:flutter/material.dart';
import '../models/checkout_models.dart';

class PaymentMethodSheet extends StatefulWidget {
  final Function(PaymentMethod, BankModel?) onMethodSelected;

  const PaymentMethodSheet({super.key, required this.onMethodSelected});

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  // Danh sách phương thức thanh toán
  final List<PaymentMethod> methods = [
    PaymentMethod(id: 'COD', name: "Thanh toán khi nhận hàng (COD)", iconData: Icons.money),
    PaymentMethod(id: 'MOMO', name: "Ví MoMo", iconData: Icons.account_balance_wallet),
    PaymentMethod(id: 'BANK', name: "Chuyển khoản Ngân hàng", iconData: Icons.account_balance, isBankTransfer: true),
  ];

  // Danh sách ngân hàng (Giả lập)
  final List<BankModel> banks = [
    BankModel(id: 'VCB', name: "Vietcombank", shortName: "VCB", logoUrl: "https://img.mservice.io/momo_app_v2/img/Vietcombank.png"),
    BankModel(id: 'MB', name: "MB Bank", shortName: "MB", logoUrl: "https://img.mservice.io/momo_app_v2/img/MBBank.png"),
    BankModel(id: 'TCB', name: "Techcombank", shortName: "TCB", logoUrl: "https://img.mservice.io/momo_app_v2/img/Techcombank.png"),
    BankModel(id: 'ACB', name: "Ngân hàng Á Châu", shortName: "ACB", logoUrl: "https://img.mservice.io/momo_app_v2/img/ACB.png"),
  ];

  // Trạng thái: đang xem danh sách ngân hàng hay danh sách phương thức chính
  bool isSelectingBank = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              if (isSelectingBank)
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => isSelectingBank = false)),
              Expanded(
                child: Text(
                  isSelectingBank ? "Chọn Ngân hàng" : "Phương thức thanh toán",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: isSelectingBank ? TextAlign.left : TextAlign.center,
                ),
              ),
              if (isSelectingBank) const SizedBox(width: 48) // Cân bằng layout
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isSelectingBank ? _buildBankList() : _buildMethodList(),
          )
        ],
      ),
    );
  }

  // Màn hình 1: Danh sách phương thức chính
  Widget _buildMethodList() {
    return ListView.builder(
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        return ListTile(
          leading: Icon(method.iconData, color: const Color(0xFF8B5FBF)),
          title: Text(method.name),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            if (method.isBankTransfer) {
              setState(() => isSelectingBank = true); // Chuyển sang chọn Bank
            } else {
              widget.onMethodSelected(method, null); // Chọn xong
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  // Màn hình 2: Danh sách Ngân hàng
  Widget _buildBankList() {
    return ListView.builder(
      itemCount: banks.length,
      itemBuilder: (context, index) {
        final bank = banks[index];
        return ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            // Dùng icon nếu ảnh lỗi
            child: Image.network(bank.logoUrl, errorBuilder: (c,e,s) => const Icon(Icons.account_balance)),
          ),
          title: Text(bank.shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(bank.name),
          onTap: () {
            // Tìm lại method BANK để trả về cùng với Bank đã chọn
            final bankMethod = methods.firstWhere((m) => m.isBankTransfer);
            widget.onMethodSelected(bankMethod, bank);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}