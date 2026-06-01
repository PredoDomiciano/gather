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

  void fetchEvents(String organizerId) {
    _eventsSubscription?.cancel();
    _eventsSubscription = _eventService.getOrganizerEvents(organizerId).listen((eventData) {
      _events = eventData;
      notifyListeners();
    });
  }

  void selectEvent(EventModel event) {
    _selectedEvent = event;
    _guestsSubscription?.cancel();
    
    _guestsSubscription = _eventService.getEventGuests(event.id).listen((guestList) {
      _guests = guestList;
      _calculateStats();
      notifyListeners();
    });
  }

  void _calculateStats() {
    if (_selectedEvent == null) return;

    int confirmedCount = 0;
    int withRestrictionsCount = 0;
    Map<String, int> restrictionDist = {};
    Map<String, int> regPerDay = {};

    for (var guest in _guests) {
      if (guest.status == 'Confirmado') {
        confirmedCount++;
      }

      var restricoesReais = guest.dietaryRestrictions.where((r) => r != 'Sem restrições').toList();

      if (restricoesReais.isNotEmpty) {
        withRestrictionsCount++;
        
        for (var restriction in restricoesReais) {
          if (restrictionDist.containsKey(restriction)) {
            restrictionDist[restriction] = restrictionDist[restriction]! + 1;
          } else {
            restrictionDist[restriction] = 1;
          }
        }
      }

      String dayKey = _getDayOfWeek(guest.registrationDate.weekday);
      if (regPerDay.containsKey(dayKey)) {
        regPerDay[dayKey] = regPerDay[dayKey]! + 1;
      } else {
        regPerDay[dayKey] = 1;
      }
    }
    
    int totalExpected = _selectedEvent!.maxPeople;
    int realPendingCount = (totalExpected - confirmedCount) > 0 ? (totalExpected - confirmedCount) : 0;

    _stats = EventStatsModel(
      totalExpected: totalExpected, 
      confirmed: confirmedCount,
      withRestrictions: withRestrictionsCount,
      pending: realPendingCount, 
      restrictionDistribution: restrictionDist,
      registrationsPerDay: regPerDay,
    );
  }

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