import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerX/src/modules/auth_features//views/general_button.dart';
import 'package:sneakerX/src/modules/auth_features/models/user_sign_in_request.dart';
import 'package:sneakerX/src/modules/auth_features/services/auth_service.dart';
import 'package:sneakerX/src/modules/auth_features/views/introduction_part.dart';
import 'package:sneakerX/src/modules/auth_features/views/text_field.dart';


// CLASS 1: The Configuration (Public)
// This part is immutable (variables cannot change).
// It effectively just holds the data passed in from the parent.
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key:key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

// CLASS 2: The Logic (Private)
// This part persists in memory. Variables here CAN change.
class _SignInScreenState extends State<SignInScreen> {
  // 1. State Variables: This data changes over time.
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  // bool _agreeToTerms = false;

  // New state variables for password visibility
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _authService = AuthService();

  //This is a cleanup method. When the user leaves this screen, this function runs to destroy the controllers and free up memory
  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    // 1. Validate inputs locally
    if (!_formKey.currentState!.validate()) {
      return;
    };

    setState(() {
      _isLoading = true;
    });

    // 2. Create Request Object
    final request = UserSignInRequest(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text
    );

    // 3. Call Backend
    final result = await _authService.signInUser(request);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // 4. Show Result
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Success: ${result.message}"),
          backgroundColor: Colors.green,
        ),
      );
      // Optional: Navigate to Login Screen
      // Navigator.pop(context);
    } else {
      // This will show "Email already exists" or "Username already exists"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header section
              IntroductionPart(
                description: "Welcome Back!",
                message: "Continue your adventure",
              ),

              // Form section
              Padding(
                  padding: EdgeInsets.all(50),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          children: [
                            // Username Field
                            CustomTextField(
                              textController: _identifierController,
                              labelText: "Username/Email/Phone",
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A3A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              validator: (value) {
                                if(value == null || value.isEmpty){
                                  return 'Please enter your username';
                                }
                                return null;
                              },

                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            CustomTextField(
                              textController: _passwordController,
                              labelText: "Password",
                              obscureText: !_isPasswordVisible,
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A3A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.password, color: Colors.white, size: 20),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            GeneralButton(
                              description: "Sign In",
                              color: 0xFFFFFFFF,
                              onPressed: _handleSignIn,
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: Text(
                                    "Forget password?",
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14
                                    ),
                                  ),
                                  onPressed: () {print("hehe");},
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Continue with google
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "OR",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),
                                ),
                                Text(
                                  "Continue with",
                                  style: GoogleFonts.inter(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 14
                                  ),
                                ),
                                SizedBox(height: 10,),

                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.all(10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)
                                      )
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/google_icon.png",
                                        height: 50,
                                        width: 50,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Google Account",
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),

                            // Link to Sign up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    'Have not an account yet?',
                                    style: GoogleFonts.montserrat(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 14,
                                    )
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to sign in screen
                                  },
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                      )
                  )
              )
            ],
          ),
        ),
      ),
    );
  }


}