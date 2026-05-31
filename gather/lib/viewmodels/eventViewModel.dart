import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // Atualizado para receber startDate e endDate
  Future<void> createEvent(String name, String code, DateTime startDate, DateTime endDate, String organizerId, int maxPeople) async {
    isLoading = true;
    notifyListeners(); 

    try {
      CollectionReference events = _firestore.collection('events');

      await events.add({
        'title': name, 
        'code': code, 
        'startDate': startDate.toIso8601String(), 
        'endDate': endDate.toIso8601String(), 
        'organizerId': organizerId, 
        'maxPeople': maxPeople, 
        'createdAt': FieldValue.serverTimestamp(), 
      });

      print("Evento adicionado com sucesso no Firebase!");

    } catch (e) {
      print("Erro ao criar evento: $e");
    } finally {
      isLoading = false;
      notifyListeners(); 
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      print("Evento excluído com sucesso!");
    } catch (e) {
      print("Erro ao excluir evento: $e");
    }
  }
}