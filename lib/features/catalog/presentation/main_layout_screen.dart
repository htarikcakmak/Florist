import 'dart:ui';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});
  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: _pages,
          ),

          // Floating Glassmorphism Navbar
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1E1E1E) : Colors.white).withOpacity(isDark ? 0.85 : 0.75),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(index: 0, current: _currentIndex, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Ana Sayfa', primary: primary, onTap: _onTabTapped),
                      _NavItem(index: 1, current: _currentIndex, icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Keşfet', primary: primary, onTap: _onTabTapped),
                      _NavItem(index: 2, current: _currentIndex, icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Sepet', primary: primary, onTap: _onTabTapped),
                      _NavItem(index: 3, current: _currentIndex, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil', primary: primary, onTap: _onTabTapped),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index, current;
  final IconData icon, activeIcon;
  final String label;
  final Color primary;
  final ValueChanged<int> onTap;

  const _NavItem({required this.index, required this.current, required this.icon, required this.activeIcon, required this.label, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 14 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? primary : Colors.grey.shade500, size: 22),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
