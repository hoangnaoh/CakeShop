import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/review_provider.dart';

void main() {
  runApp(const CakeShopApp());
}

class CakeShopApp extends StatelessWidget {
  const CakeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp(
        title: 'CakeShop',
        debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.secondary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        primaryColor: AppColors.primary,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          titleSmall: GoogleFonts.playfairDisplay(color: AppColors.neutral, fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.inter(color: AppColors.neutral),
          bodyMedium: GoogleFonts.inter(color: AppColors.neutral),
          labelLarge: GoogleFonts.inter(color: AppColors.neutral, fontWeight: FontWeight.w600),
        ),
      ),
      home: const LoginScreen(),
    ));
  }
}

