// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syfpark/views/home/constants.dart';
import 'package:syfpark/services/firebase_options.dart';
import 'package:syfpark/services/providers.dart';
import 'package:syfpark/views/landing/landing_page.dart';
import 'package:syfpark/views/home/home_page.dart';
//import 'package:syfpark/views/user/signup_page.dart';
//import 'package:syfpark/views/user/signin_page.dart';
import 'package:syfpark/views/user/auth_page.dart';
import 'package:syfpark/views/Mall/mall_view.dart';
import 'package:syfpark/views/user/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SyfPark',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.buttonSelected,
          foregroundColor: AppColors.textOverlay,
          elevation: 2,
          centerTitle: true,
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          labelMedium: TextStyle(
            color: AppColors.textUnselected,
            fontSize: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonUnselected,
            foregroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.textSecondary),
            ),
            elevation: 2,
            shadowColor: AppColors.accent.withOpacity(0.3),
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textUnselected),
        dividerColor: AppColors.textSecondary,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer(
              builder: (context, ref, child) {
                final effectiveMallAsync = ref.watch(effectiveMallProvider);
                final locationAsync = ref.watch(locationOnceProvider);
                final hasRedirected = ref.watch(hasRedirectedProvider);

                return locationAsync.when(
                  data: (result) {
                    if (result.error != null) {
                      return const LandingPage();
                    }
                    if (!hasRedirected && effectiveMallAsync != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(hasRedirectedProvider.notifier).state = true;
                        print('Initial redirect to MallView for ${effectiveMallAsync.name} (location-based)');
                        Navigator.pushReplacementNamed(context, '/mall');
                      });
                      return const LandingPage(); // Temporary placeholder
                    }
                    return const LandingPage();
                  },
                  loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
                  error: (e, _) => const LandingPage(),
                );
              },
            ),
        '/home': (context) => const HomePage(),
        //'/signup': (context) => const SignUpPage(),
        //'/signin': (context) => const SignInPage(),
        '/auth': (context) => const AuthPage(),
        '/mall': (context) => const MallView(),
        '/profile': (context) => const ProfilePage()
      },
    );
  }
}