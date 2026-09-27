import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../order/presentation/order_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  int _selectedAddressIndex = 0;
  String _paymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isProcessing = false;
  bool _isCompleted = false;
  late AnimationController _successAnimController;

  final _addresses = [
    {'title': 'Ev', 'icon': Icons.home_rounded, 'address': 'Ataşehir Bulvarı No:12 D:4, İstanbul'},
    {'title': 'İş', 'icon': Icons.business_rounded, 'address': 'Maslak Meydan Sok. No:5, İstanbul'},
  ];

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _noteController.dispose();
    _successAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final cartState = ref.watch(cartProvider);
    final totalPrice = cartState.items.fold(0.0, (sum, item) => sum + (item.flower.price * item.quantity));
    final shippingCost = totalPrice >= 150 ? 0.0 : 14.90;

    if (_isCompleted) return _SuccessScreen(primary: primary, bgColor: bgColor, controller: _successAnimController);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary), onPressed: () => context.pop()),
        title: Text('Sipariş Tamamla', style: TextStyle(fontWeight: FontWeight.w900, color: primary)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stepper göstergesi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              children: [
                _StepDot(step: 0, current: _currentStep, primary: primary, label: 'Adres'),
                Expanded(child: Container(height: 2, color: _currentStep >= 1 ? primary : Colors.grey.shade300)),
                _StepDot(step: 1, current: _currentStep, primary: primary, label: 'Ödeme'),
                Expanded(child: Container(height: 2, color: _currentStep >= 2 ? primary : Colors.grey.shade300)),
                _StepDot(step: 2, current: _currentStep, primary: primary, label: 'Onay'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // İçerik
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 0
                  ? _AddressStep(key: const ValueKey(0), cardColor: cardColor, primary: primary, isDark: isDark)
                  : _currentStep == 1
                      ? _PaymentStep(key: const ValueKey(1), cardColor: cardColor, primary: primary, isDark: isDark)
                      : _ConfirmStep(key: const ValueKey(2), cardColor: cardColor, primary: primary, isDark: isDark, cartState: cartState, totalPrice: totalPrice, shippingCost: shippingCost),
            ),
          ),

          // Alt butonlar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Geri', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleNext(totalPrice, shippingCost),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            _currentStep == 2 ? '₺${(totalPrice + shippingCost).toStringAsFixed(2)} Öde' : 'Devam',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(double total, double shipping) {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _placeOrder(total, shipping);
    }
  }

  Future<void> _placeOrder(double total, double shipping) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2)); // Simüle ödeme
    ref.read(cartProvider.notifier).clearCart();
    _successAnimController.forward();
    setState(() { _isProcessing = false; _isCompleted = true; });
  }

  // --- ADRES STEP ---
  Widget _AddressStep({Key? key, required Color cardColor, required Color primary, required bool isDark}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teslimat Adresi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
          const SizedBox(height: 16),
          ..._addresses.asMap().entries.map((e) {
            final i = e.key;
            final addr = e.value;
            final isSelected = _selectedAddressIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedAddressIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isSelected ? primary : Colors.grey.shade200, width: isSelected ? 2 : 1),
                  boxShadow: isSelected ? [BoxShadow(color: primary.withOpacity(0.1), blurRadius: 10)] : [],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: primary.withOpacity(isSelected ? 0.15 : 0.05), borderRadius: BorderRadius.circular(12)),
                      child: Icon(addr['icon'] as IconData, color: primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(addr['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(addr['address'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    ])),
                    if (isSelected) Icon(Icons.check_circle_rounded, color: primary, size: 24),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add_rounded, color: primary),
            label: Text('Yeni Adres Ekle', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: primary.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 24),
          Text('Sipariş Notu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Kapıya bırakınız, zili çalınız...',
              filled: true, fillColor: cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  // --- ÖDEME STEP ---
  Widget _PaymentStep({Key? key, required Color cardColor, required Color primary, required bool isDark}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ödeme Yöntemi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
          const SizedBox(height: 16),
          Row(children: [
            _PaymentOption(icon: Icons.credit_card_rounded, label: 'Kredi Kartı', value: 'card', selected: _paymentMethod, primary: primary, cardColor: cardColor, onTap: (v) => setState(() => _paymentMethod = v)),
            const SizedBox(width: 12),
            _PaymentOption(icon: Icons.money_rounded, label: 'Kapıda Ödeme', value: 'cash', selected: _paymentMethod, primary: primary, cardColor: cardColor, onTap: (v) => setState(() => _paymentMethod = v)),
          ]),
          if (_paymentMethod == 'card') ...[
            const SizedBox(height: 24),
            // Kart görseli
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.credit_card_rounded, color: Colors.white, size: 28),
                    const Spacer(),
                    Text('VISA', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 20, fontWeight: FontWeight.w900)),
                  ]),
                  const SizedBox(height: 24),
                  Text(_cardNumberController.text.isEmpty ? '•••• •••• •••• ••••' : _formatCardNumber(_cardNumberController.text), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('SON KULLANMA', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                      Text(_expiryController.text.isEmpty ? 'AA/YY' : _expiryController.text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                    const SizedBox(width: 32),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('CVV', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                      Text(_cvvController.text.isEmpty ? '•••' : '•' * _cvvController.text.length, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: 'Kart Numarası', prefixIcon: const Icon(Icons.credit_card_rounded), filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _expiryController, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'AA/YY', filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _cvvController, onChanged: (_) => setState(() {}), keyboardType: TextInputType.number, obscureText: true, decoration: InputDecoration(hintText: 'CVV', filled: true, fillColor: cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)))),
            ]),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.2))),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: Colors.green),
                SizedBox(width: 12),
                Expanded(child: Text('Siparişiniz kapıda nakit veya kart ile ödenir.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  // --- ONAY STEP ---
  Widget _ConfirmStep({Key? key, required Color cardColor, required Color primary, required bool isDark, required CartState cartState, required double totalPrice, required double shippingCost}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sipariş Özeti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
          const SizedBox(height: 16),

          // Adres
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.location_on_rounded, color: primary, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_addresses[_selectedAddressIndex]['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_addresses[_selectedAddressIndex]['address'] as String, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),

          // Ödeme
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(_paymentMethod == 'card' ? Icons.credit_card_rounded : Icons.money_rounded, color: primary, size: 22),
              const SizedBox(width: 10),
              Text(_paymentMethod == 'card' ? 'Kredi Kartı' : 'Kapıda Ödeme', style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),

          // Ürünler
          Text('Ürünler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
          const SizedBox(height: 10),
          ...cartState.items.map((item) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.local_florist_rounded, color: primary.withOpacity(0.4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('${item.flower.name} x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('₺${(item.flower.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
            ]),
          )),
          const Divider(height: 24),
          _PriceRow(label: 'Ara Toplam', value: '₺${totalPrice.toStringAsFixed(2)}'),
          _PriceRow(label: 'Kargo', value: shippingCost == 0 ? 'Ücretsiz' : '₺${shippingCost.toStringAsFixed(2)}', highlight: shippingCost == 0),
          const Divider(height: 16),
          _PriceRow(label: 'Toplam', value: '₺${(totalPrice + shippingCost).toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  String _formatCardNumber(String num) {
    final clean = num.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }
}

// --- Yardımcılar ---
class _StepDot extends StatelessWidget {
  final int step, current;
  final Color primary;
  final String label;
  const _StepDot({required this.step, required this.current, required this.primary, required this.label});

  @override
  Widget build(BuildContext context) {
    final isActive = current >= step;
    final isCurrent = current == step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isCurrent ? 36 : 28,
          height: isCurrent ? 36 : 28,
          decoration: BoxDecoration(
            color: isActive ? primary : Colors.grey.shade200,
            shape: BoxShape.circle,
            boxShadow: isCurrent ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 8)] : [],
          ),
          child: Center(child: isActive && !isCurrent
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? primary : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label, value, selected;
  final Color primary, cardColor;
  final ValueChanged<String> onTap;
  const _PaymentOption({required this.icon, required this.label, required this.value, required this.selected, required this.primary, required this.cardColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? primary : Colors.grey.shade200, width: isSelected ? 2 : 1),
          ),
          child: Column(children: [
            Icon(icon, color: isSelected ? primary : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isSelected ? primary : Colors.grey), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool highlight, isBold;
  const _PriceRow({required this.label, required this.value, this.highlight = false, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, color: Colors.grey.shade600, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: highlight ? Colors.green : isBold ? Theme.of(context).colorScheme.primary : null)),
      ]),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final Color primary, bgColor;
  final AnimationController controller;
  const _SuccessScreen({required this.primary, required this.bgColor, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 24),
              Text('Siparişiniz Alındı! 🌸', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary)),
              const SizedBox(height: 8),
              Text('Çiçekleriniz yola çıkacak', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Ana Sayfaya Dön', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}