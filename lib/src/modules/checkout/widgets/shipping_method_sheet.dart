import 'package:flutter/material.dart';
import 'package:sneakerx/src/config/app_config.dart'; // For formatCurrency
import '../models/checkout_models.dart';

class ShippingMethodSheet extends StatelessWidget {
  final ShippingMethod selectedShipping;
  final Function(ShippingMethod) onShippingSelected;

  // Shipping Options (IDs match your Enum)
  final List<ShippingMethod> _shippingOptions = CheckoutData.shippingOptions;

  ShippingMethodSheet({
    super.key,
    required this.selectedShipping,
    required this.onShippingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text("Select Shipping Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: _shippingOptions.length,
              itemBuilder: (context, index) {
                final option = _shippingOptions[index];

                // Compare IDs to see if selected
                final isSelected = option.id == selectedShipping.id;

                return InkWell(
                  onTap: () {
                    onShippingSelected(option);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isSelected ? const Color(0xFF8B5FBF) : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio button visual
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? const Color(0xFF8B5FBF) : Colors.grey,
                        ),
                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("Est. Arrival: ${option.estimateTime}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),

                        // Price
                        Text(
                          AppConfig.formatCurrency(option.price), // Use your AppConfig helper
                          style: const TextStyle(color: Color(0xFF8B5FBF), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}