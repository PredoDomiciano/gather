import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // Função para criar um novo evento
  Future<void> createEvent(String name, String code, DateTime date, String organizerId) async {
    isLoading = true;
    notifyListeners(); // Avisa a tela para mostrar a bolinha de carregamento

    try {
      // 1. Aponta para a "pasta" de eventos no Firebase (se não existir, ele cria na hora)
      CollectionReference events = _firestore.collection('events');

      // 2. Salva os dados do evento novo
      await events.add({
        'name': name,
        'code': code, // Ex: "TECH26"
        'date': date.toIso8601String(), // Salva a data num formato que o banco entende
        'organizerId': organizerId, // Vincula o evento ao organizador que criou
        'createdAt': FieldValue.serverTimestamp(), // Marca a hora exata da criação
      });

      print("Evento adicionado com sucesso no Firebase!");

    } catch (e) {
      print("Erro ao criar evento: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Avisa a tela que terminou de carregar
    }
  }
}