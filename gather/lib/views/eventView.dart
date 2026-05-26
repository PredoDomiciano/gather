import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/organizerViewModel.dart';

class EventView extends StatelessWidget {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrganizerViewModel>();
    final event = viewModel.selectedEvent;
    final stats = viewModel.stats;
    
    // [RESPONSIVO] Captura a largura atual da tela
    final screenWidth = MediaQuery.of(context).size.width;

    if (event == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    String formattedDate = DateFormat("dd 'de' MMMM, yyyy", "pt_BR").format(event.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF161730)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.nightlight_round, color: Colors.grey),
          )
        ],
      ),
      body: Center( // [RESPONSIVO]
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000), // [RESPONSIVO] Limite para PC
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do Evento
                Text(event.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF161730))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF00D1FF), borderRadius: BorderRadius.circular(20)),
                      child: Text(event.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Text(formattedDate, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 32),

                // 1. Cards Superiores - Passamos a largura da tela
                _buildSummaryCards(stats, screenWidth),
                const SizedBox(height: 32),

                // 2. Gráfico de Pizza (AGORA SÓ COM AS PORCENTAGENS CORRETAS)
                _buildChartCard(
                  title: 'Distribuição de Restrições Alimentares',
                  child: _buildPieChart(stats.restrictionDistribution),
                ),
                const SizedBox(height: 32),

                // 3. Gráfico de Barras Vertical
                _buildChartCard(
                  title: 'Registros por Dia',
                  child: _buildBarChart(stats.registrationsPerDay),
                ),
                const SizedBox(height: 32),

                // 4. Gráfico de Barras Horizontal
                _buildChartCard(
                  title: 'Status de Confirmações',
                  child: _buildHorizontalBars(stats.confirmed, stats.pending, stats.totalExpected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================
  // COMPONENTES DA INTERFACE
  // =====================================

  Widget _buildSummaryCards(var stats, double screenWidth) {
    bool isMobile = screenWidth < 600;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMiniCard('Confirmados', stats.confirmed.toString(), Icons.people, const Color(0xFF00D1FF), const Color(0xFFE0F7FA)),
          const SizedBox(height: 12),
          _buildMiniCard('Com Restrições', stats.withRestrictions.toString(), Icons.restaurant, const Color(0xFF161730), const Color(0xFFE8EAF6)),
          const SizedBox(height: 12),
          _buildMiniCard('Pendentes', stats.pending.toString(), Icons.error_outline, Colors.grey, Colors.grey.shade200),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildMiniCard('Confirmados', stats.confirmed.toString(), Icons.people, const Color(0xFF00D1FF), const Color(0xFFE0F7FA))),
          const SizedBox(width: 12),
          Expanded(child: _buildMiniCard('Com Restrições', stats.withRestrictions.toString(), Icons.restaurant, const Color(0xFF161730), const Color(0xFFE8EAF6))),
          const SizedBox(width: 12),
          Expanded(child: _buildMiniCard('Pendentes', stats.pending.toString(), Icons.error_outline, Colors.grey, Colors.grey.shade200)),
        ],
      );
    }
  }

  Widget _buildMiniCard(String title, String value, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: bgColor, radius: 14, child: Icon(icon, size: 16, color: iconColor)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF161730))),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF161730))),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  // ==========================================
  // GRÁFICO DE PIZZA CORRIGIDO
  // ==========================================
  Widget _buildPieChart(Map<String, double> data) {
    if (data.isEmpty) return const SizedBox(height: 200, child: Center(child: Text("Sem restrições relatadas ainda.")));

    List<PieChartSectionData> sections = [];
    List<Widget> legendItems = [];

    List<Color> colors = [
      const Color(0xFF00D1FF), 
      const Color(0xFF161730), 
      Colors.teal,
      Colors.orange,
      Colors.cyan.shade200, 
      Colors.indigo,
      Colors.pink,
      Colors.blueGrey,
    ];
    int colorIndex = 0;

    data.forEach((key, value) {
      Color sliceColor = colors[colorIndex % colors.length];

      // Como o dado 'value' já é a porcentagem (ex: 20.0), usamos direto no FL Chart
      sections.add(
        PieChartSectionData(
          color: sliceColor,
          value: value,
          title: '${value.toInt()}%',
          radius: 70,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

      // Legenda mostra o nome da restrição e a porcentagem formatada
      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: sliceColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$key: ${value.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF161730)),
                ),
              ),
            ],
          ),
        ),
      );

      colorIndex++;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 500) {
          return Column(
            children: [
              SizedBox(height: 200, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 0, sections: sections))),
              const SizedBox(height: 32),
              ...legendItems,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(height: 200, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 0, sections: sections))),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: legendItems,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Gráfico de Barras Vertical
  Widget _buildBarChart(Map<String, int> data) {
    if (data.isEmpty) return const SizedBox(height: 200, child: Center(child: Text("Sem registros de convidados.")));

    List<BarChartGroupData> barGroups = [];
    int xIndex = 0;
    List<String> labels = [];

    data.forEach((key, value) {
      labels.add(key);
      barGroups.add(
        BarChartGroupData(
          x: xIndex,
          barRods: [BarChartRodData(toY: value.toDouble(), color: const Color(0xFF00D1FF), width: 30, borderRadius: BorderRadius.circular(4))],
        ),
      );
      xIndex++;
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: barGroups,
        ),
      ),
    );
  }

  // Gráfico de Barras Horizontal
  Widget _buildHorizontalBars(int confirmados, int pendentes, int total) {
    if (total == 0) total = 1; 

    return Column(
      children: [
        _buildSingleHorizontalBar('Confirmados', confirmados, total),
        const SizedBox(height: 16),
        _buildSingleHorizontalBar('Pendentes', pendentes, total),
        const SizedBox(height: 16),
        _buildSingleHorizontalBar('Total Esperado', total, total),
      ],
    );
  }

  Widget _buildSingleHorizontalBar(String label, int value, int total) {
    double fillPercentage = value / total;
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14))),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(height: 24, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: fillPercentage > 1.0 ? 1.0 : fillPercentage,
                child: Container(height: 24, decoration: BoxDecoration(color: const Color(0xFF161730), borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 30, child: Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}