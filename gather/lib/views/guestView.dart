import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/guestViewModel.dart';

class GuestView extends StatefulWidget {
  const GuestView({super.key});

  @override
  State<GuestView> createState() => _GuestViewState();
}

class _GuestViewState extends State<GuestView> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  List<String> _selectedRestrictions = [];

  final List<Map<String, dynamic>> _restrictionOptions = [
    {'label': 'Vegano', 'icon': Icons.eco_outlined},
    {'label': 'Vegetariano', 'icon': Icons.energy_savings_leaf_outlined},
    {'label': 'Sem Glúten', 'icon': Icons.grass_outlined},
    {'label': 'Sem Lactose', 'icon': Icons.water_drop_outlined},
    {'label': 'Sem Ovos', 'icon': Icons.egg_outlined},
    {'label': 'Sem Peixes', 'icon': Icons.set_meal_outlined},
    {'label': 'Sem Frutos do Mar', 'icon': Icons.waves},
    {'label': 'Sem Amendoim', 'icon': Icons.grain},
    {'label': 'Sem Castanhas', 'icon': Icons.nature},
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleRestriction(String label) {
    setState(() {
      if (_selectedRestrictions.contains(label)) {
        _selectedRestrictions.remove(label);
      } else {
        _selectedRestrictions.add(label);
      }
    });
  }

  // Método reaproveitável para bordas dos campos do convidado também
  InputDecoration _buildInputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF161730), width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestViewModel = Provider.of<GuestViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Padronizando o fundo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF161730)),
          onPressed: () {
            guestViewModel.clearEvent();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'gather',
          style: TextStyle(color: Color(0xFF161730), fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: guestViewModel.currentEvent == null 
          ? _buildCodeStep(guestViewModel) 
          : _buildFormStep(guestViewModel),
    );
  }

  Widget _buildCodeStep(GuestViewModel viewModel) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Código de Convite',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              
              const Text('Código do Evento', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: _buildInputDecoration('DIGITE O CÓDIGO (EX: BOLO24)', icon: Icons.confirmation_num_outlined),
              ),
              const SizedBox(height: 24),

              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        viewModel.validateEventCode(_codeController.text.trim());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161730),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Continuar', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  viewModel.clearEvent();
                  Navigator.pop(context);
                },
                child: const Text('Voltar ao Login', style: TextStyle(color: Color(0xFF161730))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormStep(GuestViewModel viewModel) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      viewModel.currentEvent!.code,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      viewModel.currentEvent!.title,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Seu Nome', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _buildInputDecoration('Digite seu nome completo'),
              ),
              const SizedBox(height: 24),

              const Text('Restrições Alimentares', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, 
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _restrictionOptions.length,
                itemBuilder: (context, index) {
                  final option = _restrictionOptions[index];
                  final isSelected = _selectedRestrictions.contains(option['label']);
                  
                  return GestureDetector(
                    onTap: () => _toggleRestriction(option['label']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00D1FF) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            option['icon'], 
                            color: isSelected ? const Color(0xFF00D1FF) : const Color(0xFF161730),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option['label'],
                              style: TextStyle(
                                color: const Color(0xFF161730),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text('Observações Adicionais', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: _buildInputDecoration('Outras alergias ou preferências que devemos saber?'),
              ),
              const SizedBox(height: 24),

              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        bool success = await viewModel.submitPreferences(
                          name: _nameController.text,
                          restrictions: _selectedRestrictions,
                          notes: _notesController.text,
                        );
                        
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preferências enviadas com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          viewModel.clearEvent();
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF161730),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Enviar Preferências', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}