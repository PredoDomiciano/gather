import 'package:flutter_test/flutter_test.dart';
// Ajuste o caminho do import conforme a estrutura das suas pastas
import 'package:gather/models/guestModel.dart'; 

void main() {
  group('Testes de Caixa Branca / Unitários - GuestModel', () {
    
    test('Deve ler o campo notes corretamente do banco novo', () {
      // 1. Preparação (O JSON simulando o Firebase)
      final jsonNovo = {
        'eventId': 'BOLO24',
        'name': 'João',
        'notes': 'Sou alérgico a amendoim',
        'status': 'Confirmado',
      };

      // 2. Execução (Transformando em Objeto Dart)
      final guest = GuestModel.fromJson(jsonNovo, 'doc_123');

      // 3. Verificação (O teste em si)
      expect(guest.notes, 'Sou alérgico a amendoim');
      expect(guest.id, 'doc_123');
    });

    test('Deve usar o truque de compatibilidade para ler additionalNotes do banco antigo', () {
      // 1. Preparação (JSON antigo, sem 'notes', apenas 'additionalNotes')
      final jsonAntigo = {
        'eventId': 'BOLO24',
        'name': 'Maria',
        'additionalNotes': 'Levo minha própria bebida',
        'status': 'Confirmado',
      };

      // 2. Execução
      final guest = GuestModel.fromJson(jsonAntigo, 'doc_456');

      // 3. Verificação (O sistema tem que salvar no campo 'notes')
      expect(guest.notes, 'Levo minha própria bebida');
    });
  });
}