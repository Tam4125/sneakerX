import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController textController;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.textController,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon
  }): super(key:key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.inter(
          color: const Color(0xFF9E9E9E),
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: const Color(0xFF9E9E9E),
          fontWeight: FontWeight.w600
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.white54, // Dim white for idle state
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFAAF2C9), // Green highlight matching your theme
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),

        // Background
        filled: true,
        fillColor: Colors.transparent, // Keeps the "Outline" look
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}