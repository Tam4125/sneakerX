import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GeneralButtonLoading extends StatelessWidget {

  const GeneralButtonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        child: CircularProgressIndicator(color: Colors.white,)
      ),
    );
  }
}