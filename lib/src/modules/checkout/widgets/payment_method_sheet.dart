import 'package:flutter/material.dart';
import '../models/checkout_models.dart';

class PaymentMethodSheet extends StatefulWidget {
  final Function(PaymentMethodModel, BankModel?) onMethodSelected;

  const PaymentMethodSheet({super.key, required this.onMethodSelected});

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  // 1. Payment Methods (IDs match your Enum)
  final List<PaymentMethodModel> methods = CheckoutData.paymentMethods;

  // 2. Bank List (Sample data for Bank Transfer flow)
  final List<BankModel> banks = CheckoutData.banks;

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
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => isSelectingBank = false)
                ),
              Expanded(
                child: Text(
                  isSelectingBank ? "Select Bank" : "Payment Method",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: isSelectingBank ? TextAlign.left : TextAlign.center,
                ),
              ),
              if (isSelectingBank) const SizedBox(width: 48) // Balance layout
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

  Widget _buildMethodList() {
    return ListView.builder(
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        return ListTile(
          leading: Icon(method.iconData, color: const Color(0xFF8B5FBF)),
          title: Text(method.name),
          subtitle: method.id == 'STRIPE' ? const Text("Visa / Mastercard") : null,
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            if (method.isBankTransfer) {
              setState(() => isSelectingBank = true);
            } else {
              // For COD, STRIPE, etc.
              widget.onMethodSelected(method, null);
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  Widget _buildBankList() {
    return ListView.builder(
      itemCount: banks.length,
      itemBuilder: (context, index) {
        final bank = banks[index];
        return ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.network(bank.logoUrl, errorBuilder: (c,e,s) => const Icon(Icons.account_balance)),
          ),
          title: Text(bank.shortName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(bank.name),
          onTap: () {
            // Return BANKING method + Selected Bank
            final bankMethod = methods.firstWhere((m) => m.id == 'BANKING');
            widget.onMethodSelected(bankMethod, bank);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}