import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralButton extends StatelessWidget {
  final String description;
  final int color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GeneralButton({
    Key? key,
    required this.description,
    required this.color,
    required this.onPressed,
    this.isLoading = false
  }) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        child: Text(description, style: GoogleFonts.inter(
          color: Color(0xFF262626),
          fontWeight: FontWeight.bold,
          fontSize: 20
        ),),
      ),
    );
  }
}