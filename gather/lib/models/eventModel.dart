class EventModel {
  final String id;
  final String organizerId; 
  final String code; 
  final String title; 
  final DateTime startDate; // Nova variável de início
  final DateTime endDate;   // Nova variável de fim
  final int maxPeople; 

  EventModel({
    required this.id,
    required this.organizerId,
    required this.code,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.maxPeople, 
  });

  factory EventModel.fromJson(Map<String, dynamic> json, String documentId) {
    // Tratamento de segurança: se for um evento antigo que só tinha 'date', ele usa para as duas.
    DateTime parsedStartDate = json['startDate'] != null 
        ? DateTime.parse(json['startDate']) 
        : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now());
        
    DateTime parsedEndDate = json['endDate'] != null 
        ? DateTime.parse(json['endDate']) 
        : parsedStartDate; 

    return EventModel(
      id: documentId,
      organizerId: json['organizerId'] ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      maxPeople: json['maxPeople'] ?? 0, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizerId': organizerId,
      'code': code,
      'title': title,
      'startDate': startDate.toIso8601String(), // Salva o início
      'endDate': endDate.toIso8601String(),     // Salva o final
      'maxPeople': maxPeople, 
    };
  }
}