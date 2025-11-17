class Veiculo {
  final String id;
  final String modelo;
  final String marca;
  final String placa;
  final int ano;
  final String tipoCombustivel;

  Veiculo({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
  });

  // Converter para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
    };
  }

  // Criar objeto a partir de Map (do Firestore)
  factory Veiculo.fromMap(Map<String, dynamic> map, String id) {
    return Veiculo(
      id: id,
      modelo: map['modelo'] ?? '',
      marca: map['marca'] ?? '',
      placa: map['placa'] ?? '',
      ano: map['ano'] ?? 0,
      tipoCombustivel: map['tipoCombustivel'] ?? '',
    );
  }

  // Criar cópia com alterações
  Veiculo copyWith({
    String? id,
    String? modelo,
    String? marca,
    String? placa,
    int? ano,
    String? tipoCombustivel,
  }) {
    return Veiculo(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      marca: marca ?? this.marca,
      placa: placa ?? this.placa,
      ano: ano ?? this.ano,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
    );
  }
}
