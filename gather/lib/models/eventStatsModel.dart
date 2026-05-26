class EventStatsModel {
  final int totalExpected; // Para a barra inferior do gráfico "Status de Confirmações"
  final int confirmed; // Card: "Confirmados 85"
  final int withRestrictions; // Card: "Com Restrições 65"
  final int pending; // Card: "Pendentes 25"
  
  // Para o gráfico de pizza "Distribuição de Restrições Alimentares"
  // Ex: {'Vegano': 12.0, 'Sem Lactose': 20.0, 'Vegetariano': 18.0}
  final Map<String, double> restrictionDistribution; 
  
  // Para o gráfico de barras "Registros por Dia"
  // Ex: {'Seg': 12, 'Ter': 19, 'Qua': 15, 'Qui': 22, 'Sex': 17}
  final Map<String, int> registrationsPerDay; 

  EventStatsModel({
    required this.totalExpected,
    required this.confirmed,
    required this.withRestrictions,
    required this.pending,
    required this.restrictionDistribution,
    required this.registrationsPerDay,
  });

  // Um construtor vazio é muito útil para o ViewModel iniciar o estado
  // antes de terminar de calcular os dados do Firebase.
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