import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'cart_provider.dart';
import '../../auth/presentation/auth_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  List<String> _formErrors = [];

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final cartState = ref.watch(cartProvider);
    final totalAmount = cartState.items.fold(0.0, (sum, item) => sum + (item.flower.price * item.quantity));

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Ödeme', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Teslimat Adresi', style: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Açık adresinizi girin...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text('Ödeme Bilgileri', style: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Kart Numarası',
                  prefixIcon: Icon(Icons.credit_card_rounded),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(hintText: 'AA/YY'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'CVV'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (_formErrors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _formErrors.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(e, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13)))]),
                    )).toList(),
                  ),
                ),

              ElevatedButton(
                onPressed: () async {
                  List<String> errors = [];
                  if (_addressController.text.trim().isEmpty) errors.add('Lütfen teslimat adresini girin.');
                  if (_cardNumberController.text.trim().isEmpty) errors.add('Kart numarasını girin.');
                  
                  setState(() => _formErrors = errors);

                  if (errors.isEmpty) {
                    final authState = ref.read(authProvider);
                    if (authState.userId == null) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Lütfen önce giriş yapın.')),
                       );
                       return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse('https://your-api-url.com/api/orders'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode({
                          'userId': authState.userId,
                          'address': _addressController.text,
                          'items': cartState.items.map((i) => {'id': i.flower.id, 'quantity': i.quantity}).toList(),
                          'total': totalAmount,
                        }),
                      );

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        ref.read(cartProvider.notifier).clearCart();
                        context.go('/home');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Siparişiniz başarıyla alındı! 🌸'),
                              backgroundColor: primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sipariş gönderilirken bir hata oluştu.')),
                        );
                      }
                    }
                  }
                },
                child: Text('₺${totalAmount.toStringAsFixed(2)} - Siparişi Onayla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}