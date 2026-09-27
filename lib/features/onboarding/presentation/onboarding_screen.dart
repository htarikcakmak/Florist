import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      icon: Icons.local_florist_rounded,
      title: 'Güzel Çiçekler Keşfet',
      subtitle: 'Yüzlerce çiçek ve buket arasından seçim yapın.\nHer bütçeye uygun seçenekler.',
      color: Color(0xFF2C5E3B),
      emoji: '🌸',
    ),
    _OnboardingData(
      icon: Icons.delivery_dining_rounded,
      title: 'Hızlı Teslimat',
      subtitle: 'Siparişiniz en kısa sürede kapınıza gelsin.\n₺150 üzeri ücretsiz kargo.',
      color: Color(0xFF1976D2),
      emoji: '🚚',
    ),
    _OnboardingData(
      icon: Icons.storefront_rounded,
      title: 'Satıcı Ol',
      subtitle: 'Kendi mağazanı aç, çiçeklerini sat.\nProfesyonel satıcı paneli ile yönet.',
      color: Color(0xFFE65100),
      emoji: '🏪',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sayfa içerikleri
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [page.color, page.color.withOpacity(0.7)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // İkon
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: Icon(page.icon, size: 56, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(page.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 32),
                      Text(page.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(page.subtitle, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85), height: 1.5), textAlign: TextAlign.center),
                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              );
            },
          ),

          // Alt kısım: dots + butonlar
          Positioned(
            bottom: 50, left: 24, right: 24,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 32),

                // Butonlar
                Row(
                  children: [
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text('Atla', style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].color,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Başlayalım!' : 'Devam',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title, subtitle, emoji;
  final Color color;
  const _OnboardingData({required this.icon, required this.title, required this.subtitle, required this.color, required this.emoji});
}
