import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_register_request.dart';
import 'package:sneakerx/src/modules/auth_features/views/general_button_loading.dart';
import 'package:sneakerx/src/modules/auth_features/views/sign_in.dart';
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/modules/auth_features/views/general_button.dart';
import 'package:sneakerx/src/modules/auth_features/views/introduction_part.dart';
import 'package:sneakerx/src/modules/auth_features/views/text_field.dart';


// CLASS 1: The Configuration (Public)
// This part is immutable (variables cannot change).
// It effectively just holds the data passed in from the parent.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// CLASS 2: The Logic (Private)
// This part persists in memory. Variables here CAN change.
class _SignUpScreenState extends State<SignUpScreen> {
  // 1. State Variables: This data changes over time.
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // bool _agreeToTerms = false;

  // New state variables for password visibility
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _authService = AuthService();

  //This is a cleanup method. When the user leaves this screen, this function runs to destroy the controllers and free up memory
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // 1. Validate inputs locally
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 2. Create Request Object
    final request = UserRegisterRequest(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    // 3. Call Backend
    final result = await _authService.registerUser(request);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // 4. Show Result
    if (result.success) {
      GlobalSnackbar.show(
        context,
        success: true,
        message: "Account created successfully! Please check your email to verify account"
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen())
      );
    } else {
      GlobalSnackbar.show(
          context,
          success: false,
          message: result.message
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
              IntroductionPart(description: "Create Account", onPress: (){Navigator.pop(context);},),

              // Form section
              Padding(
                  padding: EdgeInsets.all(50),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          children: [
                            // Username Field
                            CustomTextField(
                              textController: _usernameController,
                              labelText: "Username",
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

                            // Email Field
                            CustomTextField(
                              textController: _emailController,
                              labelText: "Email",
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A3A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.email, color: Colors.white, size: 20),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if(!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Phone Number Field
                            CustomTextField(
                              textController: _phoneController,
                              labelText: "Phone Number",
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A3A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.phone, color: Colors.white, size: 20),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
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
                            const SizedBox(height: 24),

                            // Confirm Password Field
                            CustomTextField(
                              textController: _confirmPasswordController,
                              labelText: "Confirm Password",
                              obscureText: !_isConfirmPasswordVisible,
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
                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            _isLoading ? GeneralButtonLoading() : GeneralButton(
                              description: "Sign Up",
                              color: 0xFFFFFFFF,
                              onPressed: _handleSignUp,
                            ),
                            const SizedBox(height: 20),

                            // Sign up with google or facebook part
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
                                  "Sign up with",
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

                            // Link to Sign in
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    'Already have an account?',
                                    style: GoogleFonts.montserrat(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 14,
                                    )
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          // Pass the current 'productId' object to the next screen
                                            builder: (context) => SignInScreen()
                                        )
                                    );
                                  },
                                  child: const Text(
                                    'Sign in',
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