import 'package:flutter/material.dart';
import '../services/eventService.dart';
import '../models/eventModel.dart';
import '../models/guestModel.dart';

class GuestViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  
  EventModel? _currentEvent;
  bool _isLoading = false;
  String? _errorMessage;

  EventModel? get currentEvent => _currentEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. Passo: O convidado digita o código (ex: BOLO24)
  Future<bool> validateEventCode(String code) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      EventModel? event = await _eventService.getEventByCode(code);
      if (event != null) {
        _currentEvent = event;
        _setLoading(false);
        return true; // Código válido, vai para a tela de formulário
      } else {
        _errorMessage = "Código de evento inválido.";
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = "Erro ao buscar evento.";
      _setLoading(false);
      return false;
    }
  }

  // 2. Passo: Enviar as restrições
  Future<bool> submitPreferences({
    required String name,
    required List<String> restrictions,
    required String notes,
  }) async {
    // TRAVA DE SEGURANÇA: Exige o nome preenchido
    if (name.trim().isEmpty) {
      _errorMessage = "Por favor, preencha o seu nome.";
      notifyListeners();
      return false; 
    }

    if (_currentEvent == null) {
      _errorMessage = "Nenhum evento selecionado.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      GuestModel newGuest = GuestModel(
        id: '', // O Firestore vai gerar o ID automaticamente
        eventId: _currentEvent!.id,
        name: name.trim(),
        dietaryRestrictions: restrictions,
        additionalNotes: notes,
        status: 'Confirmado', // Podemos assumir que ao responder ele confirmou
        registrationDate: DateTime.now(),
      );

      await _eventService.submitGuestPreferences(newGuest);
      _setLoading(false);
      return true; // Sucesso, pode mostrar a tela de "Obrigado"
    } catch (e) {
      _errorMessage = "Erro ao enviar preferências.";
      _setLoading(false);
      return false;
    }
  }

  // ==========================================
  // FUNÇÃO ADICIONADA PARA LIMPAR O EVENTO
  // ==========================================
  void clearEvent() {
    _currentEvent = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}