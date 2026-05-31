import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/organizerViewModel.dart';
import '../models/guestModel.dart'; 

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrganizerViewModel>();
    final event = viewModel.selectedEvent;
    final stats = viewModel.stats;
    final guests = viewModel.guests; 
    
    final screenWidth = MediaQuery.of(context).size.width;

    if (event == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    String formattedDate;
    if (event.startDate.difference(event.endDate).inDays == 0 && event.startDate.day == event.endDate.day) {
      formattedDate = DateFormat("dd/MM/yyyy").format(event.startDate);
    } else {
      formattedDate = "${DateFormat("dd/MM/yyyy").format(event.startDate)} até ${DateFormat("dd/MM/yyyy").format(event.endDate)}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF161730)),
      ),
      body: Center( 
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000), 
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                _buildSummaryCards(stats, screenWidth),
                const SizedBox(height: 32),

                _buildChartCard(
                  title: 'Status de Confirmações',
                  child: _buildHorizontalBars(stats.confirmed, stats.pending, stats.totalExpected),
                ),
                const SizedBox(height: 32),

                _buildRestrictionsCountSection(guests),
                const SizedBox(height: 32),

                _buildGuestListSection(guests),
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

  Widget _buildRestrictionsCountSection(List<GuestModel> guests) {
    Map<String, int> restrictionCounts = {};
    for (var guest in guests) {
      for (var restriction in guest.dietaryRestrictions) {
        if (restriction != 'Sem restrições') {
          restrictionCounts[restriction] = (restrictionCounts[restriction] ?? 0) + 1;
        }
      }
    }

    return _buildChartCard(
      title: 'Restrições Alimentares Relatadas',
      child: restrictionCounts.isEmpty
          ? const Text('Nenhuma restrição alimentar registrada.', style: TextStyle(color: Colors.grey))
          : Wrap(
              spacing: 12, 
              runSpacing: 12, 
              children: restrictionCounts.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), 
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00D1FF), width: 1), 
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restaurant_menu, size: 16, color: Color(0xFF161730)),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(color: Color(0xFF161730), fontSize: 14),
                      ),
                      Text(
                        '${entry.value}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF161730), fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildGuestListSection(List<GuestModel> allGuests) {
    final filteredGuests = allGuests.where((guest) {
      final guestName = guest.name.toLowerCase(); 
      return guestName.contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme( 
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            'Lista de Convidados Registrados',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF161730)),
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; 
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar convidado por nome...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF8F9FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (filteredGuests.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhum convidado encontrado.', style: TextStyle(color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: filteredGuests.length,
                itemBuilder: (context, index) {
                  final guest = filteredGuests[index];
                  
                  final actualRestrictions = guest.dietaryRestrictions.where((r) => r != 'Sem restrições').toList();
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4), // Dando um respiro maior entre os itens
                    leading: CircleAvatar(
                      backgroundColor: guest.status == 'Confirmado' ? const Color(0xFFE0F7FA) : Colors.grey.shade200,
                      child: Icon(
                        guest.status == 'Confirmado' ? Icons.check : Icons.person,
                        color: guest.status == 'Confirmado' ? const Color(0xFF00D1FF) : Colors.grey,
                      ),
                    ),
                    title: Text(guest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    
                    // =====================================
                    // AQUI FOI ALTERADO: AGORA MOSTRA AS OBSERVAÇÕES
                    // =====================================
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            actualRestrictions.isNotEmpty 
                                ? 'Restrições: ${actualRestrictions.join(", ")}' 
                                : 'Nenhuma restrição alimentar',
                            style: const TextStyle(fontSize: 12),
                          ),
                          
                          // Verificação inteligente: Só desenha a linha de Observações se o convidado 
                          // preencheu algo e não está vazio!
                          if (guest.notes != null && guest.notes.toString().trim().isNotEmpty) ...[
                            const SizedBox(height: 4), // Dá um espacinho da linha de cima
                            Text(
                              'Observações: ${guest.notes}',
                              style: TextStyle(
                                fontSize: 12, 
                                fontStyle: FontStyle.italic, // Itálico para diferenciar bem
                                color: Colors.grey.shade700 // Um pouco mais escuro que a restrição
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: guest.status == 'Confirmado' ? const Color(0xFFE0F7FA) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        guest.status, 
                        style: TextStyle(
                          color: guest.status == 'Confirmado' ? const Color(0xFF00D1FF) : Colors.grey, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}