class GuestModel {
  final String id;
  final String eventId;
  final String name;
  final List<String> dietaryRestrictions; // Ex: ['Vegano', 'Sem Lactose']
  final String additionalNotes;
  final String status; // Ex: 'Confirmado', 'Pendente'
  final DateTime registrationDate;

  GuestModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.dietaryRestrictions,
    required this.additionalNotes,
    required this.status,
    required this.registrationDate,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json, String documentId) {
    return GuestModel(
      id: documentId,
      eventId: json['eventId'] ?? '',
      name: json['name'] ?? '',
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      additionalNotes: json['additionalNotes'] ?? '',
      status: json['status'] ?? 'Pendente',
      registrationDate: json['registrationDate'] != null 
          ? DateTime.parse(json['registrationDate']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'name': name,
      'dietaryRestrictions': dietaryRestrictions,
      'additionalNotes': additionalNotes,
      'status': status,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }
}