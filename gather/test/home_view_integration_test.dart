import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gather/views/homeView.dart';
import 'package:gather/viewmodels/authViewModel.dart';

//Dublê (Mock) ViewModel que não conecta no Firebase
class MockAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  User? get currentUser => null;

  @override
  Future<bool> loginOrganizer(String email, String password) async => true;

  @override
  Future<bool> registerOrganizer(String email, String password) async => true;

  @override
  Future<bool> loginGuest() async => true;

  @override
  Future<void> logout() async {}

  @override
  void clearError() {}
}

void main() {
  group('Testes de Integração - Interface e Estado', () {
    testWidgets(
      'Deve integrar o clique do botão e alternar entre Login e Cadastro na HomeView',
      (WidgetTester tester) async {
        // 2. Injetamos o nosso "Dublê" no lugar do original
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthViewModel>(
                create: (_) => MockAuthViewModel(),
              ),
            ],
            child: const MaterialApp(home: HomeView()),
          ),
        );

        // 3. Verificação Inicial: No modo de Login, o texto 'Confirmar Senha' NÃO deve existir na tela
        expect(find.text('Confirmar Senha'), findsNothing);
        expect(find.text('Entrar'), findsOneWidget);

        // 4. Execução: O robô simula o toque no botão de trocar para Cadastro
        await tester.tap(find.text('Não tem uma conta? Cadastre-se'));

        // Espera a animação da tela terminar e o estado atualizar
        await tester.pumpAndSettle();

        // 5. Verificação Final: Agora o texto 'Confirmar Senha' DEVE aparecer na tela
        expect(find.text('Confirmar Senha'), findsOneWidget);
        expect(find.text('Cadastrar'), findsOneWidget);
      },
    );
  });
}
