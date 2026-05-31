import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/authViewModel.dart';
import 'guestView.dart';
import 'organizerView.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLogin = true; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Criei esse método para reaproveitar o visual da borda em todos os campos e não poluir o código
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      // Borda padrão suave para destacar do fundo
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      // Borda escura quando o usuário clica no campo
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF161730), width: 1.5),
      ),
      // Borda de segurança
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  // Método extraído para processar o formulário (Login ou Cadastro)
  Future<void> _submitForm(AuthViewModel authViewModel) async {
    if (authViewModel.isLoading) return;

    if (_isLogin) {
      bool success = await authViewModel.loginOrganizer(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrganizerView()),
        );
      }
    } else {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('As senhas não coincidem!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      bool success = await authViewModel.registerOrganizer(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrganizerView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Fundo levemente cinza para destacar os campos brancos
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'gather',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF161730),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    _isLogin ? 'Login do Organizador' : 'Cadastro do Organizador',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next, // Adicionado para pular para a senha
                    decoration: _buildInputDecoration('Digite seu email', Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),

                  const Text('Senha', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next, // Adicionado
                    onSubmitted: (value) {
                      if (_isLogin) {
                        _submitForm(authViewModel); // Executa o login ao dar enter
                      }
                    },
                    decoration: _buildInputDecoration('Digite sua senha', Icons.lock_outline),
                  ),
                  const SizedBox(height: 16),

                  if (!_isLogin) ...[
                    const Text('Confirmar Senha', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done, // Adicionado
                      onSubmitted: (value) {
                        _submitForm(authViewModel); // Executa o cadastro ao dar enter
                      },
                      decoration: _buildInputDecoration('Repita sua senha', Icons.lock_clock_outlined),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (authViewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        authViewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ElevatedButton(
                    onPressed: authViewModel.isLoading
                        ? null
                        : () => _submitForm(authViewModel), // Chama o método extraído
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161730),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authViewModel.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_isLogin ? Icons.login : Icons.person_add_alt_1_outlined, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                _isLogin ? 'Entrar' : 'Cadastrar',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        authViewModel.clearError();
                      });
                    },
                    child: Text(
                      _isLogin ? 'Não tem uma conta? Cadastre-se' : 'Já tem uma conta? Faça Login',
                      style: const TextStyle(color: Color(0xFF161730), fontWeight: FontWeight.bold),
                    ),
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('ou', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    OutlinedButton(
                      onPressed: () async {
                        bool success = await authViewModel.loginGuest();
                        if (success && mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GuestView()),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.confirmation_num_outlined, color: Color(0xFF161730)),
                          SizedBox(width: 8),
                          Text(
                            'Insira o código de convite',
                            style: TextStyle(fontSize: 16, color: Color(0xFF161730), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}