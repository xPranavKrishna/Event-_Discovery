import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_lister/screens/login_screen.dart';
import 'package:event_lister/screens/home_screen.dart';
import 'package:event_lister/screens/splash_screen.dart';
import 'package:event_lister/theme/app_theme.dart';

// Global navigator key for accessing navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

          // Check if email is verified
          if (user.emailVerified) {
            // User is authenticated and verified, show home page
            return HomeScreen();
          } else {
            // User is authenticated but NOT verified
            // Show login screen with a message about verification
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // This ensures the scaffold is built before showing the snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Please verify your email address before logging in.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 5),
                ),
              );

              // Then sign them out
              FirebaseAuth.instance.signOut();
            });

            return const LoginScreen();
          }
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
