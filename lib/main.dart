import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:event_lister/screens/login_screen.dart';
import 'package:event_lister/screens/home_screen.dart';
import 'package:event_lister/screens/splash_screen.dart';
import 'package:event_lister/theme/app_theme.dart';

// Global navigator key for accessing navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GatherUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      navigatorKey: navigatorKey,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Check if we have a user
        if (snapshot.hasData && snapshot.data != null) {
          // Get the current user
          User user = snapshot.data!;
          print("Auth state changed: User logged in with ID: ${user.uid}");
          print("Email verified status: ${user.emailVerified}");

          // Check if email is verified
          if (user.emailVerified) {
            // User is authenticated and verified, show home page
            return HomeScreen();
          } else {
            // User is authenticated but NOT verified
            // Show login screen with a message about verification
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Sign them out first
              FirebaseAuth.instance.signOut();
              print("Signed out non-verified user");

              // This ensures the scaffold is built before showing the snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Please check your email and click the verification link before logging in',
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'RESEND',
                    textColor: Colors.white,
                    onPressed: () async {
                      try {
                        // Try to reload the user first to get fresh state
                        await user.reload();
                        User? refreshedUser = FirebaseAuth.instance.currentUser;

                        // Check if user is still available after reload
                        if (refreshedUser != null) {
                          await refreshedUser.sendEmailVerification();
                          print(
                              "Verification email resent to: ${refreshedUser.email}");

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Verification email resent. Please check your inbox.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          // User is no longer available (likely signed out)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please sign in again to resend verification'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        print("Error resending verification email: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to resend: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            });

            return const LoginScreen();
          }
        }

        // User is not logged in
        print("Auth state: No user logged in");
        return const LoginScreen();
      },
    );
  }
}
