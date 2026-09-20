import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SellerReportsPage extends StatelessWidget {
  const SellerReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Haftalık Gelir Grafiği
          _SectionTitle(title: 'Haftalık Gelir', icon: Icons.trending_up_rounded, color: primary),
          const SizedBox(height: 12),
          Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 100, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('₺${v.toInt()}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                    return Text(days[v.toInt() % 7], style: TextStyle(fontSize: 10, color: Colors.grey.shade500));
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 180), FlSpot(1, 320), FlSpot(2, 250), FlSpot(3, 410), FlSpot(4, 380), FlSpot(5, 520), FlSpot(6, 290)],
                    isCurved: true,
                    color: primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: primary.withOpacity(0.1)),
                    dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 4, color: primary, strokeColor: Colors.white, strokeWidth: 2)),
                  ),
                ],
                minY: 0,
                maxY: 600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // En Çok Satan Çiçekler
          _SectionTitle(title: 'En Çok Satan Çiçekler', icon: Icons.local_florist_rounded, color: primary),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final names = ['Gül', 'Orkide', 'Lale', 'Papatya', 'Karanfil'];
                    return Text(v.toInt() < names.length ? names[v.toInt()] : '', style: TextStyle(fontSize: 10, color: Colors.grey.shade500));
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _barGroup(0, 42, primary),
                  _barGroup(1, 35, primary.withOpacity(0.8)),
                  _barGroup(2, 28, primary.withOpacity(0.6)),
                  _barGroup(3, 22, primary.withOpacity(0.5)),
                  _barGroup(4, 15, primary.withOpacity(0.4)),
                ],
                maxY: 50,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Kategori Dağılımı
          _SectionTitle(title: 'Kategori Dağılımı', icon: Icons.pie_chart_rounded, color: primary),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(value: 40, title: '40%', color: primary, radius: 50, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        PieChartSectionData(value: 25, title: '25%', color: Colors.blue, radius: 45, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        PieChartSectionData(value: 20, title: '20%', color: Colors.orange, radius: 45, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        PieChartSectionData(value: 15, title: '15%', color: Colors.purple, radius: 40, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Legend(color: primary, label: 'Buket'),
                    _Legend(color: Colors.blue, label: 'Saksı'),
                    _Legend(color: Colors.orange, label: 'Aranjman'),
                    _Legend(color: Colors.purple, label: 'Gelin'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ziyaretçi kartları
          _SectionTitle(title: 'Ziyaretçi İstatistikleri', icon: Icons.visibility_rounded, color: primary),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MiniStatCard(label: 'Bugün', value: '47', icon: Icons.today_rounded, color: Colors.blue, cardColor: cardColor)),
              const SizedBox(width: 12),
              Expanded(child: _MiniStatCard(label: 'Bu Hafta', value: '312', icon: Icons.date_range_rounded, color: Colors.green, cardColor: cardColor)),
              const SizedBox(width: 12),
              Expanded(child: _MiniStatCard(label: 'Bu Ay', value: '1.2K', icon: Icons.calendar_month_rounded, color: Colors.orange, cardColor: cardColor)),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y, Color color) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: color, width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionTitle({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, cardColor;
  const _MiniStatCard({required this.label, required this.value, required this.icon, required this.color, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
