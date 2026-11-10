import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _saving = false;
  int _selectedAvatar = 0;

  static const _avatarEmojis = ['🌸', '🌹', '🌻', '🌺', '🌷', '🌼', '🍀', '🌿'];

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _nameController = TextEditingController(text: auth.name ?? '');
    _phoneController = TextEditingController(text: auth.phone ?? '');
    // Restore selected avatar
    final url = auth.avatarUrl ?? '';
    final idx = _avatarEmojis.indexOf(url);
    _selectedAvatar = idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success = await ref.read(authProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: _avatarEmojis[_selectedAvatar],
    );
    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Profil güncellendi ✅' : 'Hata oluştu, tekrar dene'),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      if (success) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: primary),
          onPressed: () => context.pop(),
        ),
        title: Text('Profili Düzenle', style: TextStyle(fontWeight: FontWeight.w900, color: primary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar seçici
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Text(_avatarEmojis[_selectedAvatar], style: const TextStyle(fontSize: 44)),
                  ),
                  const SizedBox(height: 16),
                  Text('Avatar Seç', style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: List.generate(_avatarEmojis.length, (i) {
                      final isSelected = _selectedAvatar == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAvatar = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? primary.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? primary : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(_avatarEmojis[i], style: const TextStyle(fontSize: 26)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form alanları
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // Email (read-only)
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_rounded, color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    ),
                    controller: TextEditingController(text: auth.email ?? ''),
                  ),
                  const SizedBox(height: 16),

                  // İsim
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Ad Soyad',
                      prefixIcon: Icon(Icons.person_rounded, color: primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Telefon
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefon',
                      hintText: '05XX XXX XX XX',
                      prefixIcon: Icon(Icons.phone_rounded, color: primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
