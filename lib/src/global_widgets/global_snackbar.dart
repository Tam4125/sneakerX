import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalSnackbar {
  // Static method to show the snackbar
  static void show(BuildContext context, {
    required bool success,
    required String message,
  }) {
    // 1. Hide any currently showing snackbars (prevents stacking)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 2. Show the new SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Dynamic Icon based on success/failure
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            // Expanded text to handle long error messages
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Dynamic Color
        backgroundColor: success ? Colors.green.shade600 : Colors.redAccent,

        // Modern Floating Behavior
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}