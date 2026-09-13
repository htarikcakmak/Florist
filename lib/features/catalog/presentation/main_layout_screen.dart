import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // 1. Ana İçerik (Sayfalar — Smooth swipe)
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: _pages,
          ),
          
          // 2. Yüzen Buzlu Cam Navbar (Floating Glass Navbar)
          Positioned(
            left: 24,
            right: 24,
            bottom: 32, // Ekranın altından biraz yukarıda (Yüzen efekt)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30), // Tam yuvarlak hatlar
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6), // Daha şeffaf beyaz (Gerçek cam hissi)
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5), // Cam kenarındaki yansıma çizgisi
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabTapped,
                    backgroundColor: Colors.transparent, // Arka plan tamamen saydam (Cam arkadan görünecek)
                    selectedItemColor: primary,
                    unselectedItemColor: Colors.grey.shade600,
                    showSelectedLabels: true,
                    showUnselectedLabels: false, // Seçili olmayanın yazısını gizle, daha temiz dursun
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home_rounded),
                        label: 'Ana Sayfa',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search_rounded),
                        activeIcon: Icon(Icons.search_rounded, size: 26),
                        label: 'Arama',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_bag_outlined),
                        activeIcon: Icon(Icons.shopping_bag_rounded),
                        label: 'Sepet',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_rounded),
                        activeIcon: Icon(Icons.person_rounded),
                        label: 'Profil',
                      ),
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
