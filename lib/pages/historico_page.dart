import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';

class HistoricoPage extends StatelessWidget {
  const HistoricoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Abastecimentos')),
      body: StreamBuilder<List<Abastecimento>>(
        stream: firestore.listarTodosAbastecimentos(),
        builder: (context, abastecimentoSnapshot) {
          if (abastecimentoSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!abastecimentoSnapshot.hasData ||
              abastecimentoSnapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Nenhum abastecimento registrado',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final abastecimentos = abastecimentoSnapshot.data!;

          return StreamBuilder<List<Veiculo>>(
            stream: firestore.listarVeiculos(),
            builder: (context, veiculoSnapshot) {
              final veiculos = veiculoSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: abastecimentos.length,
                itemBuilder: (context, index) {
                  final abastecimento = abastecimentos[index];
                  final veiculo = veiculos.firstWhere(
                    (v) => v.id == abastecimento.veiculoId,
                    orElse: () => Veiculo(
                      id: '',
                      modelo: 'Veículo Deletado',
                      marca: '',
                      placa: 'N/A',
                      ano: 0,
                      tipoCombustivel: '',
                    ),
                  );

                  final precoLitro = abastecimento.quantidadeLitros > 0
                      ? abastecimento.valorPago /
                          abastecimento.quantidadeLitros
                      : 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho com veículo e data
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${veiculo.marca} ${veiculo.modelo}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      veiculo.placa,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${abastecimento.data.day}/${abastecimento.data.month}/${abastecimento.data.year}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  Text(
                                    '${abastecimento.data.hour}:${abastecimento.data.minute.toString().padLeft(2, '0')}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          // Detalhes do abastecimento
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.5,
                            children: [
                              _buildDetalhe(
                                context,
                                'Quantidade',
                                '${abastecimento.quantidadeLitros.toStringAsFixed(2)} L',
                              ),
                              _buildDetalhe(
                                context,
                                'Valor Pago',
                                'R\$ ${abastecimento.valorPago.toStringAsFixed(2)}',
                              ),
                              _buildDetalhe(
                                context,
                                'Preço/L',
                                'R\$ ${precoLitro.toStringAsFixed(2)}',
                              ),
                              _buildDetalhe(
                                context,
                                'Consumo',
                                '${abastecimento.consumo.toStringAsFixed(2)} km/L',
                              ),
                              _buildDetalhe(
                                context,
                                'Quilometragem',
                                '${abastecimento.quilometragem.toStringAsFixed(0)} km',
                              ),
                              _buildDetalhe(
                                context,
                                'Combustível',
                                abastecimento.tipoCombustivel,
                              ),
                            ],
                          ),
                          if (abastecimento.observacao != null &&
                              abastecimento.observacao!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Observação',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    abastecimento.observacao!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          // Botão de exclusão
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () async {
                                final confirm =
                                    await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text('Confirmar exclusão'),
                                    content: const Text(
                                        'Deseja realmente excluir este abastecimento?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm ?? false) {
                                  if (context.mounted) {
                                    final error = await firestore
                                        .deletarAbastecimento(abastecimento.id);
                                    if (error == null && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Abastecimento removido com sucesso!')),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Remover'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetalhe(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
