import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // Função para criar um novo evento
  Future<void> createEvent(String name, String code, DateTime date, String organizerId) async {
    isLoading = true;
    notifyListeners(); // Avisa o ecrã para mostrar a bolinha de carregamento

    try {
      // 1. Aponta para a coleção de eventos no Firebase
      CollectionReference events = _firestore.collection('events');

      // 2. Salva os dados do evento novo
      await events.add({
        'title': name, // CORREÇÃO: Alterado de 'name' para 'title' para coincidir com o EventModel e as Views!
        'code': code, // Ex: "TECH26"
        'date': date.toIso8601String(), // Guarda a data num formato compatível
        'organizerId': organizerId, // Vincula o evento ao organizador que o criou
        'createdAt': FieldValue.serverTimestamp(), // Marca a hora exata do registo
      });

      print("Evento adicionado com sucesso no Firebase!");

    } catch (e) {
      print("Erro ao criar evento: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Avisa o ecrã que terminou de carregar
    }
  }
}