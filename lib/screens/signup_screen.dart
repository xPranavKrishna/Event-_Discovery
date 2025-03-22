import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/widgets/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showCustomSnackBar(
        context,
        'Passwords do not match',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print("User created with ID: ${userCredential.user?.uid}");

      // Update display name
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Force reload user to ensure we have latest data
      await userCredential.user?.reload();

      // Send verification email - use the current user instance
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.sendEmailVerification();
          print("Verification email sent successfully to: ${user.email}");
        } catch (e) {
          print("Error sending verification email: $e");
          throw Exception("Failed to send verification email: $e");
        }

        // Sign out the user to force them to verify email before logging in
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          // Show verification message
          showCustomSnackBar(
            context,
            'Account created successfully! Please check your email to verify your account before logging in.',
            isError: false,
          );

          // Navigate to login screen after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        }
      } else {
        throw Exception('User is null after creation');
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Exception: ${e.code} - ${e.message}");
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'An error occurred. Please try again.';

      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Email/password accounts are not enabled.';
      }

      if (mounted) {
        showCustomSnackBar(context, errorMessage, isError: true);
      }
    } catch (e) {
      print("Unexpected error during signup: $e");
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showCustomSnackBar(
          context,
          'An unexpected error occurred: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            color: Color(0xFF5E43C3), // Purple color
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App Bar with Back Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        'Create Account',
                        style: GoogleFonts.londrinaSolid(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance the layout
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Logo Space
                Container(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    'assets/images/gatherup-logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                // White form container - Now using Expanded to fill remaining space
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),

                              // Name Field
                              TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: GoogleFonts.arOneSans(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.arOneSans(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: GoogleFonts.arOneSans(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.arOneSans(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.arOneSans(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Color(0xFF5E43C3),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.arOneSans(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: GoogleFonts.arOneSans(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF5E43C3), width: 2),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Color(0xFF5E43C3),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                style: GoogleFonts.arOneSans(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5E43C3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'SIGN UP',
                                          style: GoogleFonts.londrinaSolid(
                                            textStyle: const TextStyle(
                                              fontSize: 22,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Login Option
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: GoogleFonts.akatab(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Log in',
                                      style: GoogleFonts.akatab(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF5E43C3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
