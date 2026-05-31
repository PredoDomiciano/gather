import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math'; 
import '../viewmodels/organizerViewModel.dart';
import '../viewmodels/authViewModel.dart';
import '../viewmodels/eventViewModel.dart';
import '../models/eventModel.dart'; 
import 'eventView.dart';

class OrganizerView extends StatefulWidget {
  const OrganizerView({super.key});

  @override
  State<OrganizerView> createState() => _OrganizerViewState();
}

class _OrganizerViewState extends State<OrganizerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.currentUser != null) {
        Provider.of<OrganizerViewModel>(context, listen: false)
            .fetchEvents(authVM.currentUser!.uid);
      }
    });
  }

  String _generateRandomCode() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';

    List<String> codeChars = [];
    for (int i = 0; i < 4; i++) codeChars.add(letters[random.nextInt(letters.length)]);
    for (int i = 0; i < 4; i++) codeChars.add(numbers[random.nextInt(numbers.length)]);
    codeChars.shuffle(random);
    return codeChars.join();
  }

  void showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController(text: _generateRandomCode());
    final maxPeopleController = TextEditingController(); 
    
    // Variáveis separadas para Início e Fim
    DateTime selectedStartDate = DateTime.now(); 
    DateTime selectedEndDate = DateTime.now(); 

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Criar Novo Evento', style: TextStyle(color: Color(0xFF161730))),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome do Evento', hintText: 'Ex: Conferência Tech'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Código de Convite (Gerado automaticamente)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF161730)),
                          onPressed: () {
                            setDialogState(() {
                              codeController.text = _generateRandomCode();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // =====================================
                    // SELEÇÃO DUPLA DE DATAS
                    // =====================================
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Início', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF161730))),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedStartDate,
                                    firstDate: DateTime.now(), 
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      selectedStartDate = picked; 
                                      // Trava a data final para não ser menor que a inicial
                                      if (selectedEndDate.isBefore(selectedStartDate)) {
                                        selectedEndDate = selectedStartDate;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat("dd/MM/yyyy").format(selectedStartDate), style: const TextStyle(fontSize: 14)),
                                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF161730)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Término', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF161730))),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedEndDate,
                                    firstDate: selectedStartDate, // A data final não pode ser antes do início
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      selectedEndDate = picked; 
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(DateFormat("dd/MM/yyyy").format(selectedEndDate), style: const TextStyle(fontSize: 14)),
                                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF161730)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: maxPeopleController,
                      keyboardType: TextInputType.number, 
                      decoration: const InputDecoration(labelText: 'Capacidade Máxima de Pessoas', hintText: 'Ex: 100'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D1FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final name = nameController.text;
                    final code = codeController.text;
                    final maxPeopleText = maxPeopleController.text;

                    if (name.isNotEmpty && code.isNotEmpty && maxPeopleText.isNotEmpty) {
                      final authVM = Provider.of<AuthViewModel>(context, listen: false);
                      final organizerId = authVM.currentUser?.uid ?? 'id_desconhecido';
                      final int maxPeople = int.tryParse(maxPeopleText) ?? 0;

                      await Provider.of<EventViewModel>(context, listen: false).createEvent(
                        name,
                        code,
                        selectedStartDate, // Envia Data Inicial
                        selectedEndDate,   // Envia Data Final
                        organizerId,
                        maxPeople,    
                      );

                      if (context.mounted) {
                        Provider.of<OrganizerViewModel>(context, listen: false).fetchEvents(organizerId);
                        Navigator.pop(dialogContext); 
                      }
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Excluir Evento'),
            ],
          ),
          content: Text('Tem certeza que deseja excluir o evento "${event.title}"?\n\nEsta ação não poderá ser desfeita e apagará todos os dados dos convidados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx); 
                await Provider.of<EventViewModel>(context, listen: false).deleteEvent(event.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Evento excluído com sucesso!'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Sim, excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final organizerViewModel = Provider.of<OrganizerViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final String userEmail = authViewModel.currentUser?.email ?? 'Organizador';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('gather', style: TextStyle(color: Color(0xFF161730), fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Olá, $userEmail', style: const TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await authViewModel.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/'); 
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12, width: 2))),
                child: const Text('Todos os Eventos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF161730))),
              ),
              
              Expanded(
                child: organizerViewModel.events.isEmpty
                    ? const Center(child: Text('Nenhum evento criado ainda.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: organizerViewModel.events.length,
                        itemBuilder: (context, index) {
                          final event = organizerViewModel.events[index];
                          
                          // Verifica se Início e Fim são no mesmo dia, ou desenha o intervalo
                          String displayDate;
                          if (event.startDate.difference(event.endDate).inDays == 0 && event.startDate.day == event.endDate.day) {
                            displayDate = DateFormat("dd/MM/yyyy").format(event.startDate);
                          } else {
                            displayDate = "${DateFormat("dd/MM/yyyy").format(event.startDate)} até ${DateFormat("dd/MM/yyyy").format(event.endDate)}";
                          }

                          // =====================================
                          // AGORA O EVENTO SÓ VENCE DEPOIS DA DATA FINAL (endDate)
                          // =====================================
                          final now = DateTime.now();
                          final todayDate = DateTime(now.year, now.month, now.day);
                          final endDateOnly = DateTime(event.endDate.year, event.endDate.month, event.endDate.day);
                          
                          bool isPastEvent = endDateOnly.isBefore(todayDate);

                          Color cardBackgroundColor = isPastEvent ? Colors.red.shade50 : Colors.white;
                          Color cardBorderColor = isPastEvent ? Colors.red.shade200 : Colors.cyan.shade100;
                          Color codeTagColor = isPastEvent ? Colors.red.shade300 : const Color(0xFF00D1FF);

                          return GestureDetector(
                            onTap: () {
                              organizerViewModel.selectEvent(event);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const EventView()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBackgroundColor, 
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cardBorderColor, width: 1.5), 
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: codeTagColor, borderRadius: BorderRadius.circular(20)),
                                        child: Text(event.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF161730))),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                                        onPressed: () => _showDeleteConfirmation(context, event),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(displayDate, style: TextStyle(color: isPastEvent ? Colors.red.shade400 : Colors.grey)),
                                      if (isPastEvent) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                          child: const Text('Encerrado', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                        )
                                      ]
                                    ],
                                  ),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF161730),
        onPressed: () => showAddEventDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}