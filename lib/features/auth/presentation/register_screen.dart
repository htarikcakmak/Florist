import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget { 
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.customer;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
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
          name: _nameController.text.trim(),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().contains('zaten kullanılıyor')
                  ? 'Bu e-posta zaten kayıtlı. Giriş yapmayı deneyin.'
                  : 'Kayıt başarısız. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final primary = Theme.of(context).colorScheme.primary;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kayıt başarılı! Hoş geldiniz. 🌸'),
            backgroundColor: primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (next.role == UserRole.seller) {
          context.go('/seller');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE9F5EC),
              Color(0xFFC0E0C8),
              Color(0xFF90C2A0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
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
                              Icon(Icons.person_add_alt_1_rounded, size: 64, color: primary),
                              const SizedBox(height: 12),
                              Text(
                                'Kayıt Ol',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.2, color: primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aramıza katılın',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: primary.withOpacity(0.7), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 24),

                              // ROL SEÇİCİ — Müşteri / Mağaza
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                                ),
                                child: SegmentedButton<UserRole>(
                                  segments: [
                                    ButtonSegment(
                                      value: UserRole.customer,
                                      icon: Icon(Icons.person_outline, size: 18),
                                      label: const Text('Müşteri'),
                                    ),
                                    ButtonSegment(
                                      value: UserRole.seller,
                                      icon: Icon(Icons.storefront_outlined, size: 18),
                                      label: const Text('Mağaza'),
                                    ),
                                  ],
                                  selected: {_selectedRole},
                                  onSelectionChanged: (Set<UserRole> selection) {
                                    setState(() => _selectedRole = selection.first);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                                      return states.contains(WidgetState.selected)
                                          ? primary.withOpacity(0.15)
                                          : Colors.transparent;
                                    }),
                                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                                      return states.contains(WidgetState.selected) ? primary : Colors.grey;
                                    }),
                                    side: WidgetStateProperty.all(BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // İSİM
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: _selectedRole == UserRole.seller ? 'Mağaza Adı' : 'Adınız',
                                  prefixIcon: Icon(_selectedRole == UserRole.seller ? Icons.storefront_outlined : Icons.person_outline),
                                  fillColor: Colors.white.withOpacity(0.7),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'Lütfen bir ad girin';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // E-POSTA
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

                              // ŞİFRE
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
                                  if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),

                              // KAYIT BUTONU
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    elevation: authState.isLoading ? 0 : 4,
                                    shadowColor: primary.withOpacity(0.4),
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text(
                                          _selectedRole == UserRole.seller ? 'Mağaza Oluştur' : 'Hesap Oluştur',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Zaten hesabın var mı? ", style: TextStyle(color: primary.withOpacity(0.7), fontWeight: FontWeight.w600)),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    style: TextButton.styleFrom(foregroundColor: primary, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                    child: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.w900)),
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
        ),
      ),
    );
  }
}