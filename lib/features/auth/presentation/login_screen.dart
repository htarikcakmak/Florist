import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget { 
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(authProvider.notifier).login(
          _emailController.text.trim(), 
          _passwordController.text,
          _selectedRole,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); 

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        if (next.role == UserRole.seller) {
          context.go('/seller');
        } else {
          context.go('/home');
        }
      }
    });

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE9F5EC), // Çok açık yeşil-beyaz
              Color(0xFFC0E0C8), // Soft floral yeşil
              Color(0xFF90C2A0), // Daha doygun soft yeşil
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5), // Yarı saydam beyaz cam efekti
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.local_florist_rounded, size: 64, color: primary),
                          const SizedBox(height: 12),
                          Text(
                            'Flowerist',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hoş Geldiniz',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: primary.withOpacity(0.7), fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 32),

                          SegmentedButton<UserRole>(
                            segments: const [
                              ButtonSegment<UserRole>(
                                value: UserRole.customer,
                                label: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Müşteri', style: TextStyle(fontWeight: FontWeight.bold))),
                              ),
                              ButtonSegment<UserRole>(
                                value: UserRole.seller,
                                label: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Mağaza', style: TextStyle(fontWeight: FontWeight.bold))),
                              ),
                            ],
                            selected: {_selectedRole},
                            onSelectionChanged: (Set<UserRole> newSelection) => setState(() => _selectedRole = newSelection.first),
                            style: SegmentedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.6),
                              selectedForegroundColor: Colors.white,
                              selectedBackgroundColor: primary,
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'E-posta adresiniz',
                              prefixIcon: const Icon(Icons.mail_outline),
                              fillColor: Colors.white.withOpacity(0.7),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Lütfen e-posta adresinizi girin';
                              if (!value.contains('@')) return 'Geçerli bir e-posta girin';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Şifreniz',
                              prefixIcon: const Icon(Icons.lock_outline),
                              fillColor: Colors.white.withOpacity(0.7),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: primary.withOpacity(0.7)),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Lütfen şifrenizi girin';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          ElevatedButton(
                            onPressed: authState.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(_selectedRole == UserRole.seller ? 'Mağaza Girişi' : 'Giriş Yap', style: const TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Hesabın yok mu? ", style: TextStyle(color: primary.withOpacity(0.7), fontWeight: FontWeight.w600)),
                              TextButton(
                                onPressed: () => context.go('/register'),
                                style: TextButton.styleFrom(foregroundColor: primary, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: const Text('Kayıt Ol', style: TextStyle(fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}