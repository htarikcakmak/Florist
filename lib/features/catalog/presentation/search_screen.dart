import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'marketplace_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final allVendors = ref.watch(marketplaceProvider);
    
    final filteredVendors = _searchQuery.isEmpty 
        ? [] 
        : allVendors.where((v) => v.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text('Keşfet', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Çiçek veya mağaza ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            if (_searchQuery.isEmpty) ...[
              Text('Popüler Kategoriler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primary)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildCategoryChip('🌹 Güller', primary),
                  _buildCategoryChip('🌸 Orkideler', primary),
                  _buildCategoryChip('🎂 Doğum Günü', primary),
                  _buildCategoryChip('🌻 Papatyalar', primary),
                ],
              ),
            ] else ...[
              Text('Sonuçlar (${filteredVendors.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primary)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredVendors.length,
                  itemBuilder: (context, index) {
                    final vendor = filteredVendors[index];
                    return ListTile(
                      onTap: () => context.push('/vendor', extra: vendor.name),
                      leading: const CircleAvatar(child: Icon(Icons.storefront_rounded)),
                      title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(vendor.deliveryTime),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color primary) {
    return GestureDetector(
      onTap: () => setState(() => _searchQuery = label.split(' ')[1]), // Emoji sonrası kelimeyi ara
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: primary)),
      ),
    );
  }
}
