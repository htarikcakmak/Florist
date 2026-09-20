import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/theme/presentation/theme_provider.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/catalog/presentation/main_layout_screen.dart';
import 'features/store/presentation/seller_dashboard_screen.dart';
import 'features/catalog/presentation/vendor_detail_screen.dart';
import 'features/cart/presentation/checkout_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FloweristApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _smoothPage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _smoothPage(state, const RegisterScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _smoothPage(state, const MainLayoutScreen()),
    ),
    GoRoute(
      path: '/seller',
      pageBuilder: (context, state) => _smoothPage(state, const SellerDashboardScreen()),
    ),
    GoRoute(
      path: '/vendor',
      pageBuilder: (context, state) {
        final vendorName = state.extra as String? ?? 'Mağaza Detayı';
        return _smoothPage(state, VendorDetailScreen(vendorName: vendorName));
      },
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (context, state) => _smoothPage(state, const CheckoutScreen()),
    ),
  ],
);

// Tüm sayfa geçişleri için smooth fade+slide animasyonu
CustomTransitionPage _smoothPage(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class FloweristApp extends ConsumerWidget {
  const FloweristApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State'i watch ediyoruz ki değişince rebuild olsun
    ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    // ÇİÇEK TEMALI (Sadece Soft Yeşil)
    const primaryGreen = Color(0xFF2C5E3B);
    const softGreen = Color(0xFF90C2A0);
    const backgroundCream = Color(0xFFFDFBF7); 
    const inputFill = Color(0xFFFFFFFF); 

    // Dark Mode renkleri
    const darkBackground = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);
    const darkCard = Color(0xFF2A2A2A);

    return MaterialApp.router(
      title: 'Flowerist',
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.themeMode,
      // i18n — Çoklu Dil Desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('es'),
      ],
      locale: const Locale('tr'),

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundCream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: softGreen,
          tertiary: const Color(0xFFEAB875),
          surface: Colors.white,
        ),
        
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 4,
          shadowColor: Colors.black12,
          backgroundColor: backgroundCream,
          foregroundColor: primaryGreen,
          titleTextStyle: TextStyle(color: primaryGreen, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          iconTheme: IconThemeData(color: primaryGreen),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: primaryGreen.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: softGreen, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          labelStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w500),
          prefixIconColor: primaryGreen.withOpacity(0.7),
          suffixIconColor: primaryGreen.withOpacity(0.7),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.zero,
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: softGreen,
          brightness: Brightness.dark,
          primary: softGreen,
          secondary: primaryGreen,
          tertiary: const Color(0xFFEAB875),
          surface: darkSurface,
        ),

        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 4,
          shadowColor: Colors.black26,
          backgroundColor: darkBackground,
          foregroundColor: softGreen,
          titleTextStyle: const TextStyle(color: softGreen, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          iconTheme: const IconThemeData(color: softGreen),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: softGreen,
            foregroundColor: Colors.black,
            elevation: 4,
            shadowColor: softGreen.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade700, width: 1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade700, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: softGreen, width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          labelStyle: const TextStyle(color: softGreen, fontWeight: FontWeight.w500),
          prefixIconColor: softGreen.withOpacity(0.7),
          suffixIconColor: softGreen.withOpacity(0.7),
        ),

        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.zero,
        ),
      ),
      routerConfig: _router,
    );
  }
}