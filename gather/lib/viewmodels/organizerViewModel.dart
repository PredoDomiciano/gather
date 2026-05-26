import 'dart:async';
import 'package:flutter/material.dart';
import '../services/eventService.dart';
import '../models/eventModel.dart';
import '../models/guestModel.dart';
import '../models/eventStatsModel.dart';

class OrganizerViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  List<GuestModel> _guests = [];
  EventStatsModel _stats = EventStatsModel.empty();
  
  StreamSubscription? _eventsSubscription;
  StreamSubscription? _guestsSubscription;

  List<EventModel> get events => _events;
  EventModel? get selectedEvent => _selectedEvent;
  List<GuestModel> get guests => _guests;
  EventStatsModel get stats => _stats;

  // Busca os eventos do Organizador logado
  void fetchEvents(String organizerId) {
    _eventsSubscription?.cancel();
    _eventsSubscription = _eventService.getOrganizerEvents(organizerId).listen((eventData) {
      _events = eventData;
      notifyListeners();
    });
  }

  // Quando o Organizador clica em um evento (ex: BOLO24), carrega os dados dele
  void selectEvent(EventModel event) {
    _selectedEvent = event;
    _guestsSubscription?.cancel();
    
    // Escuta os convidados em tempo real
    _guestsSubscription = _eventService.getEventGuests(event.id).listen((guestList) {
      _guests = guestList;
      _calculateStats(); // Recalcula os gráficos sempre que alguém novo responder!
      notifyListeners();
    });
  }

  // ==========================================
  // LÓGICA DE CÁLCULO LOCAL DAS ESTATÍSTICAS
  // ==========================================
  void _calculateStats() {
    int confirmedCount = 0;
    int pendingCount = 0;
    int withRestrictionsCount = 0;
    Map<String, double> restrictionDist = {};
    Map<String, int> regPerDay = {};

    for (var guest in _guests) {
      // 1. Conta status
      if (guest.status == 'Confirmado') {
        confirmedCount++;
      } else {
        pendingCount++;
      }

      // 2. Conta quem tem restrição (se a lista não for vazia)
      if (guest.dietaryRestrictions.isNotEmpty) {
        withRestrictionsCount++;
        
        // 3. Distribuição de Restrições (para o Gráfico de Pizza)
        for (var restriction in guest.dietaryRestrictions) {
          if (restrictionDist.containsKey(restriction)) {
            restrictionDist[restriction] = restrictionDist[restriction]! + 1;
          } else {
            restrictionDist[restriction] = 1.0; // Inicia a contagem
          }
        }
      }

      // 4. Registros por Dia (para o Gráfico de Barras)
      // Converte a data para um formato simples de dia da semana ou data curta
      String dayKey = _getDayOfWeek(guest.registrationDate.weekday);
      if (regPerDay.containsKey(dayKey)) {
        regPerDay[dayKey] = regPerDay[dayKey]! + 1;
      } else {
        regPerDay[dayKey] = 1;
      }
    }

    // Calcula a porcentagem para o gráfico de pizza
    int totalRestrictions = restrictionDist.values.fold(0, (sum, val) => sum + val.toInt());
    if (totalRestrictions > 0) {
      restrictionDist.updateAll((key, value) => (value / totalRestrictions) * 100);
    }

    // Atualiza o Model de Estatísticas
    _stats = EventStatsModel(
      totalExpected: confirmedCount + pendingCount, // Pode ser ajustado se o evento tiver um limite fixo
      confirmed: confirmedCount,
      withRestrictions: withRestrictionsCount,
      pending: pendingCount,
      restrictionDistribution: restrictionDist,
      registrationsPerDay: regPerDay,
    );
  }

  // Função auxiliar para formatar o dia da semana
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Seg';
      case 2: return 'Ter';
      case 3: return 'Qua';
      case 4: return 'Qui';
      case 5: return 'Sex';
      case 6: return 'Sáb';
      case 7: return 'Dom';
      default: return '';
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _guestsSubscription?.cancel();
    super.dispose();
  }
}