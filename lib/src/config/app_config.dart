import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConfig {
  // --- 1. CONFIGURATION ---
  // Base backend URL (Android Emulator uses 10.0.2.2 to access localhost)
  static const baseUrl = "http://10.0.2.2:8080";
  static const baseAvatartUrl = "https://res.cloudinary.com/dprivf9nt/image/upload/v1766715383/Profile_avatar_placeholder_large_qrfeir.png";
  static const baseImageUrl = "https://res.cloudinary.com/dprivf9nt/image/upload/v1766715440/Image-not-found_oploqz.png";

  // --- 2. COLOR PALETTE (From Design System) ---

  // Primary (Green/Mint Theme)
  static const primary100 = Color(0xFFAAF2C9);
  static const primary200 = Color(0xFF86F4B5); // Base
  static const primary300 = Color(0xFF67D696);

  // Secondary (Purple Theme)
  static const secondary100 = Color(0xFFCA92E4);
  static const secondary200 = Color(0xFF9052AD); // Base
  static const secondary300 = Color(0xFF593C66);

  // Dark (Text & UI Elements)
  static const dark100 = Color(0xFF464646);
  static const dark200 = Color(0xFF363636);
  static const dark300 = Color(0xFF262626); // Base (Main Text)
  static const dark400 = Color(0xFF161616);

  // Light (Backgrounds)
  static const light100 = Color(0xFFFFFFFF); // Pure White
  static const light200 = Color(0xFFF4FFFF); // Base Background
  static const light300 = Color(0xFFDAF0F0);
  static const light400 = Color(0xFFB8D4D4);
  static const light500 = Color(0xFFF5F5F5);

  // Accent (Teal/Dark Green)
  static const accent100 = Color(0xFF2A6E60);
  static const accent200 = Color(0xFF165347); // Base
  static const accent300 = Color(0xFF09362D);

  // --- Functional Aliases (Use these in your Widgets) ---
  static const error = Color(0xFFE74C3C);     // Added for form validation
  static const success = Color(0xFF4CAF50);

  // --- 3. PRODUCT OPTIONS ---

  // Size Options (Expanded for half sizes which are common in sneakers)
  static const List<String> sizeOptions = [
    "36", "36.5", "37", "38", "38.5", "39", "40", "40.5",
    "41", "42", "42.5", "43", "44", "44.5", "45", "46"
  ];

  // Color Options for Sellers (Map: Hex String -> Display Name)
  // Format: 0xFF + RRGGBB
  static const Map<String, String> colorOptions = {
    // Neutrals (Most Popular)
    "0xFFFFFFFF": "White",
    "0xFF000000": "Black",
    "0xFF808080": "Grey",
    "0xFFF5F5DC": "Cream", // or Beige
    "0xFF8B4513": "Brown",

    // Vibrant
    "0xFFFF0000": "Red",
    "0xFF0000FF": "Blue",
    "0xFF000080": "Navy",
    "0xFF008000": "Green",
    "0xFFFFFF00": "Yellow",
    "0xFFFFA500": "Orange",
    "0xFF8E44AD": "Purple",
    "0xFFFFC0CB": "Pink",

    // Special
    "0xFFFFD700": "Gold",
    "0xFFC0C0C0": "Silver",
    "0xFF00FFFF": "Cyan",
  };

  // --- 4. HELPER METHODS ---

  // Helper to get color object from your Hex Strings
  static Color hexToColor(String hexString) {
    try {
      return Color(int.parse(hexString));
    } catch (e) {
      return Colors.grey; // Fallback
    }
  }

  static String getColorName(String hexCode) {
    return colorOptions[hexCode] ?? "Màu khác";
  }

  static String formatCurrency(double amount) {
    final currencyFormater = NumberFormat.currency(
        locale: 'en_US',
        name: 'USD',
        symbol: r'$',
        decimalDigits: 2
    );
    return currencyFormater.format(amount);
  }
}