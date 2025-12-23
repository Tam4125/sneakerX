import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Infofield extends StatelessWidget {
  final String label;
  final String text;
  final int maxLines;
  final bool isMultiline;
  final double size;
  final IconData? labelIcons;

  const Infofield({
    super.key,
    required this.label,
    required this.text,
    this.size = 16,
    this.maxLines = 1,
    this.isMultiline = false,
    this.labelIcons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.6,
                ),
              ),
              if (labelIcons != null) ...[
                const SizedBox(width: 6),
                Icon(
                  labelIcons,
                  size: 16,
                  color: Colors.black,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
            text,
            style: GoogleFonts.inter(
              fontSize: size,
              letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}
