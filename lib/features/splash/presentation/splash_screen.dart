import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    Future.delayed(const Duration(milliseconds: 500), () => _textController.forward());
    Future.delayed(const Duration(milliseconds: 2200), () => _fadeController.forward());
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() { _logoController.dispose(); _textController.dispose(); _fadeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2C5E3B);
    const softGreen = Color(0xFF90C2A0);

    return Scaffold(
      body: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [primary, Color(0xFF1A3D25)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animasyonu
              ScaleTransition(
                scale: CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: softGreen.withOpacity(0.3), blurRadius: 30)],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.local_florist_rounded, size: 56, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // App adı
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic)),
                child: FadeTransition(
                  opacity: _textController,
                  child: const Column(
                    children: [
                      Text('Flowerist', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                      SizedBox(height: 8),
                      Text('Çiçekler kapınıza gelsin 🌸', style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              FadeTransition(
                opacity: CurvedAnimation(parent: _textController, curve: Curves.easeIn),
                child: SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
