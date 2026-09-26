import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'marketplace_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedCategory;
  final _focusNode = FocusNode();
  late AnimationController _animController;

  final _categories = [
    _Cat('🌹', 'Güller', Colors.red),
    _Cat('🌸', 'Orkide', Colors.purple),
    _Cat('🌻', 'Papatya', Colors.amber),
    _Cat('💐', 'Buket', Colors.green),
    _Cat('🪴', 'Saksı', Colors.teal),
    _Cat('👰', 'Gelin', Colors.pink),
    _Cat('🎂', 'Doğum Günü', Colors.orange),
    _Cat('💝', 'Sevgiliye', Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }
  @override
  void dispose() { _animController.dispose(); _focusNode.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final allVendors = ref.watch(marketplaceProvider);

    final filteredVendors = _searchQuery.isEmpty
        ? allVendors
        : allVendors.where((v) => v.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: bgColor,
            title: Text('Keşfet', style: TextStyle(fontWeight: FontWeight.w900, color: primary)),
            centerTitle: false,
          ),

          // Arama kutusu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  focusNode: _focusNode,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Çiçek, mağaza veya kategori ara...',
                    prefixIcon: Icon(Icons.search_rounded, color: primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear_rounded, size: 20), onPressed: () => setState(() { _searchQuery = ''; _selectedCategory = null; }))
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // Kategoriler
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text('Kategoriler', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primary)),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat.label;
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (isSelected) { _selectedCategory = null; _searchQuery = ''; }
                          else { _selectedCategory = cat.label; _searchQuery = cat.label; }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected ? cat.color.withOpacity(0.15) : cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: isSelected ? cat.color : Colors.grey.shade200, width: isSelected ? 2 : 1),
                            boxShadow: isSelected ? [BoxShadow(color: cat.color.withOpacity(0.2), blurRadius: 8)] : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 6),
                              Text(cat.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? cat.color : Colors.grey.shade600), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Sonuçlar başlığı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Text(
                    _searchQuery.isEmpty ? 'Tüm Mağazalar' : 'Sonuçlar',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('${filteredVendors.length}', style: TextStyle(fontSize: 13, color: primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // Mağaza sonuçları
          filteredVendors.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Sonuç bulunamadı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final vendor = filteredVendors[index];
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200 + index * 50),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            onTap: () => context.push('/vendor', extra: vendor.name),
                            leading: Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.storefront_rounded, color: primary, size: 24),
                            ),
                            title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Text(vendor.deliveryTime, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                const SizedBox(width: 10),
                                if (vendor.shippingCost == 0) ...[
                                  const Icon(Icons.local_shipping_rounded, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  const Text('Ücretsiz', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primary),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredVendors.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _Cat {
  final String emoji, label;
  final Color color;
  _Cat(this.emoji, this.label, this.color);
}
