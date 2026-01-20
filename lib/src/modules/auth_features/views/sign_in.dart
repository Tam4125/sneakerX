import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sneakerx/src/global_widgets/global_snackbar.dart';
import 'package:sneakerx/src/modules/auth_features/dtos/user_sign_in_request.dart';
import 'package:sneakerx/src/modules/auth_features/views/general_button_loading.dart';
import 'package:sneakerx/src/modules/auth_features/views/sign_up.dart';
import 'package:sneakerx/src/screens/main_screen.dart';
import 'package:sneakerx/src/services/auth_service.dart';
import 'package:sneakerx/src/modules/auth_features/views/general_button.dart';
import 'package:sneakerx/src/modules/auth_features/views/introduction_part.dart';
import 'package:sneakerx/src/modules/auth_features/views/text_field.dart';
import 'package:sneakerx/src/utils/auth_provider.dart';


// CLASS 1: The Configuration (Public)
// This part is immutable (variables cannot change).
// It effectively just holds the data passed in from the parent.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

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
                onPress: () {Navigator.pop(context);},
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

                            _loginButton(),
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
                                  onPressed: () {
                                    GlobalSnackbar.show(
                                      context,
                                      success: false,
                                      message: "Upcoming Feature"
                                    );
                                  },
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
                                  onPressed: () {
                                    GlobalSnackbar.show(
                                        context,
                                        success: false,
                                        message: "Upcoming Feature"
                                    );
                                  },
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignUpScreen()
                                        )
                                    );
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

  Widget _loginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return _isLoading
            ? GeneralButtonLoading()
            : GeneralButton(
              description: "Sign In",
              color: 0xFFFFFFFF,
              onPressed: auth.isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  final request = UserSignInRequest(
                      identifier: _identifierController.text.trim(),
                      password: _passwordController.text
                  );

                  setState(() {
                    _isLoading = true;
                  });
                  // 2. Call the Login function
                  bool success = await auth.login(request);

                  setState(() {
                    _isLoading = false;
                  });

                  // 3. Handle Success/Failure
                  if (success) {
                    if (mounted) {
                      // Close keyboard
                      FocusScope.of(context).unfocus();

                      // Show success message
                      GlobalSnackbar.show(
                        context,
                        success: true,
                        message: "Welcome back, ${auth.currentUser?.user.username}!"
                      );

                      // Navigate to MainWrapper and remove back stack history
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                            (route) => false,
                      );
                    }
                  } else {
                    // 4. Handle Failure - Show API Error Message
                    if (mounted) {
                      GlobalSnackbar.show(
                          context,
                          success: false,
                          message: auth.errorMessage ?? "Login failed. Please try again."
                      );
                    }
                  }
                }
              },
        );
      },
    );
  }
}