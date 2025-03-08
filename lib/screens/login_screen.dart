import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/theme/app_theme.dart';
import 'package:event_lister/screens/signup_screen.dart';
import 'package:event_lister/screens/forgot_password_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if email is verified
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        // Email not verified, send verification email again
        await user.sendEmailVerification();

        // Sign out the user since we don't want unverified users to be logged in
        await FirebaseAuth.instance.signOut();

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          showCustomSnackBar(
            context,
            'Please verify your email before logging in. A new verification email has been sent.',
            isError: true,
          );
        }
        return;
      }

      // If we get here, the email is verified
      // Navigation will be handled by the AuthWrapper in main.dart
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'An error occurred. Please try again.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user has been disabled.';
      }

      if (mounted) {
        showCustomSnackBar(context, errorMessage, isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showCustomSnackBar(
          context,
          'An unexpected error occurred. Please try again.',
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
            color: Color(0xFF5E43C3), // Updated to purple color from image
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Background Image with Logo Space
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background City Image - placeholder for actual image with opacity
                      Opacity(
                        opacity: 0.8,
                        child: Container(
                          height: 300,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/city-bg.jpg'), // You'll need to add this asset
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Logo Space
                      Container(
                        height: 120,
                        width: 120,
                        child: Image.asset(
                          'assets/images/gatherup-logo.png', // You'll need to add this asset
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  // Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      '"Where Moments Become Memories —\nExplore, Share, and Be Part of Unforgettable Events!"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.londrinaSolid(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  // White bottom container
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Email Field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: GoogleFonts.arOneSans(
                                  // Changed to AR One Sans
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              style: GoogleFonts.arOneSans(
                                // Changed to AR One Sans
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: GoogleFonts.arOneSans(
                                  // Changed to AR One Sans
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
                                // Changed to AR One Sans
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF5E43C3), // Purple color
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
                                        'LOG IN',
                                        style: GoogleFonts.londrinaSolid(
                                          // Kept Londrina Solid for button
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
                            const SizedBox(height: 10),

                            // Forgot Password Link
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Forget Password?',
                                style: GoogleFonts.aBeeZee(
                                  // Changed to ABeeZee
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5E43C3),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Sign Up Option
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Do you not have an account?',
                                  style: GoogleFonts.akatab(
                                    // Changed to Akatab
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign up',
                                    style: GoogleFonts.akatab(
                                      // Changed to Akatab
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

                            // Email verification help text
                            const SizedBox(height: 20),
                            Text(
                              'Please verify your email after signup to enable login.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.akatab(
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom SnackBar Function
void showCustomSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.errorColor : const Color(0xFF5E43C3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    ),
  );
}
