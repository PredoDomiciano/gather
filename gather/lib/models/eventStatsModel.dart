class EventStatsModel {
  final int totalExpected;
  final int confirmed;
  final int withRestrictions;
  final int pending;
  final Map<String, int> restrictionDistribution;
  final Map<String, int> registrationsPerDay;

  EventStatsModel({
    required this.totalExpected,
    required this.confirmed,
    required this.withRestrictions,
    required this.pending,
    required this.restrictionDistribution,
    required this.registrationsPerDay,
  });

  factory EventStatsModel.empty() {
    return EventStatsModel(
      totalExpected: 0,
      confirmed: 0,
      withRestrictions: 0,
      pending: 0,
      restrictionDistribution: {},
      registrationsPerDay: {},
    );
  }
}