import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String? _selectedVeiculoId;

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estatísticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<List<Veiculo>>(
              stream: firestore.listarVeiculos(),
              builder: (context, snapshot) {
                final veiculos = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue: _selectedVeiculoId,
                  decoration: const InputDecoration(labelText: 'Veículo'),
                  items: veiculos
                      .map((v) => DropdownMenuItem(
                            value: v.id,
                            child: Text('${v.marca} ${v.modelo} (${v.placa})'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedVeiculoId = value),
                  hint: const Text('Selecione um veículo'),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedVeiculoId == null
                  ? Center(
                      child: Text(
                        'Selecione um veículo para ver as estatísticas',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : StreamBuilder<List<Abastecimento>>(
                      stream: firestore.listarAbastecimentos(_selectedVeiculoId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          final errorMessage = snapshot.error.toString();
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Erro ao carregar abastecimentos:',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  SelectableText(
                                    errorMessage,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 10,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: errorMessage));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Erro copiado para a área de transferência!')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copiar Erro'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final list = snapshot.data ?? [];
                        if (list.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhum abastecimento para este veículo',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        // Ordenar por data ascendente
                        final sorted = List<Abastecimento>.from(list)
                          ..sort((a, b) => a.data.compareTo(b.data));

                        // Montar pontos para gráfico de valor pago
                        final spotsValor = <FlSpot>[];
                        final spotsConsumo = <BarChartGroupData>[];

                        for (var i = 0; i < sorted.length; i++) {
                          final a = sorted[i];
                          spotsValor.add(FlSpot(i.toDouble(), a.valorPago));

                          spotsConsumo.add(
                            BarChartGroupData(x: i, barRods: [
                              BarChartRodData(
                                  toY: a.consumo, color: Theme.of(context).colorScheme.primary)
                            ]),
                          );
                        }

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Legend
                              Row(
                                children: [
                                  _legendDot(context, Theme.of(context).colorScheme.primary, 'Valor (R\$)'),
                                  const SizedBox(width: 12),
                                  _legendDot(context, Theme.of(context).colorScheme.error, 'Consumo (km/L)'),
                                ],
                              ),
                              const SizedBox(height: 8),

                              Text('Valor pago por abastecimento', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 220,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: true),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 || index >= sorted.length) return const SizedBox.shrink();
                                          final step = (sorted.length / 6).ceil();
                                          if (step > 1 && index % step != 0) return const SizedBox.shrink();
                                          final d = sorted[index].data;
                                          return Transform.rotate(
                                            angle: -0.6,
                                            child: Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10)),
                                          );
                                        }),
                                      ),
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                    ),
                                    borderData: FlBorderData(show: true),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            final idx = spot.x.toInt();
                                            final a = sorted[idx];
                                            return LineTooltipItem(
                                                'R\$ ${a.valorPago.toStringAsFixed(2)}\n${a.data.day}/${a.data.month}/${a.data.year}',
                                                TextStyle(color: Theme.of(context).colorScheme.onPrimary));
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: spotsValor,
                                        isCurved: true,
                                        color: Theme.of(context).colorScheme.primary,
                                        barWidth: 3,
                                        dotData: FlDotData(show: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('Consumo (km/L) por abastecimento', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 260,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: spotsConsumo,
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          final a = sorted[group.x.toInt()];
                                          return BarTooltipItem('${a.consumo.toStringAsFixed(2)} km/L\nR\$ ${a.valorPago.toStringAsFixed(2)}', TextStyle(color: Theme.of(context).colorScheme.onPrimary));
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 || index >= sorted.length) return const SizedBox.shrink();
                                        final step = (sorted.length / 8).ceil();
                                        if (step > 1 && index % step != 0) return const SizedBox.shrink();
                                        final d = sorted[index].data;
                                        return Transform.rotate(
                                          angle: -0.6,
                                          child: Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10)),
                                        );
                                      })),
                                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
