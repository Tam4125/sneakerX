import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroductionPart extends StatelessWidget {

  // 1. Fields: All variables in a StatelessWidget must be 'final'.
  final String description;
  final String? message;
  // final VoidCallback onPress;

  // 2. Constructor: Use 'const' for performance.
  // We use 'required' for mandatory data and set defaults for optional ones.
  const IntroductionPart({
    super.key,
    required this.description,
    this.message
    // required this.onPress
  });

  // 3. Build Method: Describes the UI
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFAAF2C9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Padding(
        padding: EdgeInsets.only(left: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                print("He he");
              },
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    description,
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    )
                ),
                const SizedBox(height: 10),

                if(message != null)
                  Text(
                    message!,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.2,
                    )
                  )
              ],
            )
          ],
        ),
      )
    );
  }
}