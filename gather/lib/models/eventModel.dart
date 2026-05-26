class EventModel {
  final String id;
  final String organizerId; // ID do usuário criador
  final String code; // Ex: BOLO24
  final String title; // Ex: Almoço Executivo
  final DateTime date; 

  EventModel({
    required this.id,
    required this.organizerId,
    required this.code,
    required this.title,
    required this.date,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, String documentId) {
    return EventModel(
      id: documentId,
      organizerId: json['organizerId'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(), // No Firestore, você pode preferir (json['date'] as Timestamp).toDate()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizerId': organizerId,
      'code': code,
      'title': title,
      'date': date.toIso8601String(),
    };
  }
}