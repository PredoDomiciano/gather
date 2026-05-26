import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/eventModel.dart';
import '../models/guestModel.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================
  // FUNÇÕES DO ORGANIZADOR
  // ==========================================

  // Busca todos os eventos criados por um organizador específico (Stream para atualizar em tempo real)
  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Busca todos os convidados de um evento específico (Para calcular as estatísticas localmente)
  Stream<List<GuestModel>> getEventGuests(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('guests')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GuestModel.fromJson(doc.data(), doc.id))
            .toList());
  }
  Future<void> createNewEvent(EventModel event) async {
    try {
      await _firestore.collection('events').add(event.toJson());
    } catch (e) {
      throw Exception('Erro ao criar evento: $e');
    }
  }

  // ==========================================
  // FUNÇÕES DO CONVIDADO
  // ==========================================

  // Busca um evento pelo código (ex: "BOLO24"). 
  // Retorna o EventModel se existir, ou null se for inválido.
  Future<EventModel?> getEventByCode(String code) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        return EventModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null; // Código não encontrado
    } catch (e) {
      throw Exception('Erro ao buscar evento pelo código: $e');
    }
  }

  // Salva o formulário de restrições do convidado na subcoleção do evento
  Future<void> submitGuestPreferences(GuestModel guest) async {
    try {
      await _firestore
          .collection('events')
          .doc(guest.eventId)
          .collection('guests')
          .add(guest.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar preferências: $e');
    }
  }
}