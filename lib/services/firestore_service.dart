import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============ VEÍCULOS ============

  // Adicionar veículo
  Future<String?> adicionarVeiculo({
    required String modelo,
    required String marca,
    required String placa,
    required int ano,
    required String tipoCombustivel,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'Usuário não autenticado';

      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('veiculos')
          .add({
        'modelo': modelo,
        'marca': marca,
        'placa': placa,
        'ano': ano,
        'tipoCombustivel': tipoCombustivel,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      return null; // Sucesso
    } catch (e) {
      return 'Erro ao adicionar veículo: $e';
    }
  }

  // Listar todos os veículos do usuário
  Stream<List<Veiculo>> listarVeiculos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('veiculos')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Veiculo.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Deletar veículo
  Future<String?> deletarVeiculo(String veiculoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'Usuário não autenticado';

      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('veiculos')
          .doc(veiculoId)
          .delete();

      return null; // Sucesso
    } catch (e) {
      return 'Erro ao deletar veículo: $e';
    }
  }

  // ============ ABASTECIMENTOS ============

  // Adicionar abastecimento
  Future<String?> adicionarAbastecimento({
    required DateTime data,
    required double quantidadeLitros,
    required double valorPago,
    required double quilometragem,
    required String tipoCombustivel,
    required String veiculoId,
    required double consumo,
    required String? observacao,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'Usuário não autenticado';

      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('abastecimentos')
          .add({
        // store as Firestore Timestamp for robust querying and ordering
        'data': Timestamp.fromDate(data),
        'quantidadeLitros': quantidadeLitros,
        'valorPago': valorPago,
        'quilometragem': quilometragem,
        'tipoCombustivel': tipoCombustivel,
        'veiculoId': veiculoId,
        'consumo': consumo,
        'observacao': observacao ?? '',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      return null; // Sucesso
    } catch (e) {
      return 'Erro ao adicionar abastecimento: $e';
    }
  }

  // Listar abastecimentos de um veículo
  Stream<List<Abastecimento>> listarAbastecimentos(String veiculoId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('abastecimentos')
        .where('veiculoId', isEqualTo: veiculoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Abastecimento.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Listar todos os abastecimentos do usuário
  Stream<List<Abastecimento>> listarTodosAbastecimentos() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('abastecimentos')
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Abastecimento.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Deletar abastecimento
  Future<String?> deletarAbastecimento(String abastecimentoId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 'Usuário não autenticado';

      await _db
          .collection('usuarios')
          .doc(userId)
          .collection('abastecimentos')
          .doc(abastecimentoId)
          .delete();

      return null; // Sucesso
    } catch (e) {
      return 'Erro ao deletar abastecimento: $e';
    }
  }
}
