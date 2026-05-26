import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatar a data
import '../viewmodels/organizerViewModel.dart';
import '../viewmodels/authViewModel.dart';
import '../viewmodels/eventViewModel.dart'; // <-- 1. Importação Adicionada
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
    // Assim que a tela abre, pedimos para o ViewModel buscar os eventos desse usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.currentUser != null) {
        Provider.of<OrganizerViewModel>(context, listen: false)
            .fetchEvents(authVM.currentUser!.uid);
      }
    });
  }

  // ==============================================================
  // 2. FUNÇÃO DO POP-UP ADICIONADA AQUI (Antes do build)
  // ==============================================================
  void showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Criar Novo Evento', style: TextStyle(color: Color(0xFF161730))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Evento',
                  hintText: 'Ex: Conferência Tech',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de Convite',
                  hintText: 'Ex: TECH2026',
                ),
              ),
            ],
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

                if (name.isNotEmpty && code.isNotEmpty) {
                  // Pega o ID real do usuário logado
                  final authVM = Provider.of<AuthViewModel>(context, listen: false);
                  final organizerId = authVM.currentUser?.uid ?? 'id_desconhecido';

                  // Salva o evento no Firebase
                  await Provider.of<EventViewModel>(context, listen: false).createEvent(
                    name,
                    code,
                    DateTime.now(),
                    organizerId,
                  );

                  // Recarrega a lista para o evento novo aparecer na hora
                  if (context.mounted) {
                    Provider.of<OrganizerViewModel>(context, listen: false).fetchEvents(organizerId);
                    Navigator.pop(dialogContext); // Fecha o pop-up
                  }
                }
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final organizerViewModel = Provider.of<OrganizerViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('gather', style: TextStyle(color: Color(0xFF161730), fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Painel do Organizador', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await authViewModel.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/'); // Volta pro main
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aba "Todos os Eventos"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12, width: 2)),
            ),
            child: const Text(
              'Todos os Eventos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF161730)),
            ),
          ),
          
          Expanded(
            child: organizerViewModel.events.isEmpty
                ? const Center(child: Text('Nenhum evento criado ainda.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: organizerViewModel.events.length,
                    itemBuilder: (context, index) {
                      final event = organizerViewModel.events[index];
                      // Formata a data: "15 de Maio, 2026"
                      String formattedDate = DateFormat("dd 'de' MMMM, yyyy", "pt_BR").format(event.date);

                      return GestureDetector(
                        onTap: () {
                          // Seleciona o evento no ViewModel
                          organizerViewModel.selectEvent(event);
                          // Navega para a tela de Dashboard
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EventView()),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.cyan.shade100, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D1FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      event.code, // <-- Aqui vai puxar o código do evento criado!
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      event.title, // <-- Aqui o título que você digitar no pop-up!
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF161730)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.grey),
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
      // ==============================================================
      // 3. BOTÃO FLUTUANTE ATUALIZADO
      // ==============================================================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF161730),
        onPressed: () => showAddEventDialog(context), // <-- Chama o pop-up aqui!
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}