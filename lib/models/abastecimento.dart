import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  final String id;
  final DateTime data;
  final double quantidadeLitros;
  final double valorPago;
  final double quilometragem;
  final String tipoCombustivel;
  final String veiculoId;
  final double consumo;
  final String? observacao;

  Abastecimento({
    required this.id,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    required this.veiculoId,
    required this.consumo,
    this.observacao,
  });

  // Converter para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'data': Timestamp.fromDate(data),
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'veiculoId': veiculoId,
      'consumo': consumo,
      'observacao': observacao ?? '',
    };
  }

  // Criar objeto a partir de Map (do Firestore)
  factory Abastecimento.fromMap(Map<String, dynamic> map, String id) {
    // The 'data' field in Firestore may be stored as a Timestamp or as an ISO String.
    DateTime parsedDate;
    final raw = map['data'];
    if (raw == null) {
      parsedDate = DateTime.now();
    } else if (raw is String) {
      parsedDate = DateTime.tryParse(raw) ?? DateTime.now();
    } else if (raw is Timestamp) {
      parsedDate = raw.toDate();
    } else {
      // Fallback for unexpected types
      try {
        parsedDate = DateTime.parse(raw.toString());
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }

    return Abastecimento(
      id: id,
      data: parsedDate,
      quantidadeLitros: (map['quantidadeLitros'] ?? 0).toDouble(),
      valorPago: (map['valorPago'] ?? 0).toDouble(),
      quilometragem: (map['quilometragem'] ?? 0).toDouble(),
      tipoCombustivel: map['tipoCombustivel'] ?? '',
      veiculoId: map['veiculoId'] ?? '',
      consumo: (map['consumo'] ?? 0).toDouble(),
      observacao: map['observacao'],
    );
  }
}
