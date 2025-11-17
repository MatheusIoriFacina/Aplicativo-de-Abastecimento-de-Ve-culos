import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/veiculo.dart';

class AbastecimentoPage extends StatefulWidget {
  const AbastecimentoPage({super.key});

  @override
  State<AbastecimentoPage> createState() => _AbastecimentoPageState();
}

class _AbastecimentoPageState extends State<AbastecimentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _valorController = TextEditingController();
  final _quilometragemController = TextEditingController();
  final _consumoController = TextEditingController();
  final _observacaoController = TextEditingController();

  DateTime _dataSelecionada = DateTime.now();
  String? _veiculoSelecionadoId;
  String _tipoCombustivel = 'Gasolina';
  bool _isLoading = false;
  String? _errorMsg;

  final List<String> combustiveis = ['Gasolina', 'Diesel', 'Etanol', 'Híbrido'];

  @override
  void dispose() {
    _quantidadeController.dispose();
    _valorController.dispose();
    _quilometragemController.dispose();
    _consumoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() => _dataSelecionada = data);
    }
  }

  Future<void> _registrarAbastecimento() async {
    if (!_formKey.currentState!.validate()) return;
    if (_veiculoSelecionadoId == null) {
      setState(() => _errorMsg = 'Selecione um veículo');
      return;
    }

    setState(() => _isLoading = true);

    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final error = await firestore.adicionarAbastecimento(
      data: _dataSelecionada,
      quantidadeLitros: double.parse(_quantidadeController.text),
      valorPago: double.parse(_valorController.text),
      quilometragem: double.parse(_quilometragemController.text),
      tipoCombustivel: _tipoCombustivel,
      veiculoId: _veiculoSelecionadoId!,
      consumo: double.parse(_consumoController.text),
      observacao: _observacaoController.text.trim().isEmpty
          ? null
          : _observacaoController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (error == null) {
        _quantidadeController.clear();
        _valorController.clear();
        _quilometragemController.clear();
        _consumoController.clear();
        _observacaoController.clear();
        _dataSelecionada = DateTime.now();
        _veiculoSelecionadoId = null;
        _tipoCombustivel = 'Gasolina';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abastecimento registrado com sucesso!')),
        );
      } else {
        setState(() => _errorMsg = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Abastecimento')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Seleção de veículo
                StreamBuilder<List<Veiculo>>(
                  stream: firestore.listarVeiculos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Cadastre um veículo primeiro',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    final veiculos = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      initialValue: _veiculoSelecionadoId,
                      decoration:
                          const InputDecoration(labelText: 'Selecione um veículo'),
                      items: veiculos
                          .map((veiculo) {
                            return DropdownMenuItem<String>(
                              value: veiculo.id,
                              child: Text(
                                  '${veiculo.marca} ${veiculo.modelo} (${veiculo.placa})'),
                            );
                          })
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _veiculoSelecionadoId = newValue;
                          // Atualizar tipo de combustível do veículo selecionado
                          final veiculo = veiculos.firstWhere(
                              (v) => v.id == newValue,
                              orElse: () => veiculos.first);
                          _tipoCombustivel = veiculo.tipoCombustivel;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um veículo';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Data do abastecimento
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data do Abastecimento'),
                  subtitle:
                      Text('${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selecionarData,
                ),
                const SizedBox(height: 16),
                // Quantidade de litros
                TextFormField(
                  controller: _quantidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade (L)',
                    suffixText: 'L',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Quantidade é obrigatória';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Quantidade deve ser um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Valor pago
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(
                    labelText: 'Valor Pago (R\$)',
                    prefixText: 'R\$ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Valor é obrigatório';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Valor deve ser um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Quilometragem
                TextFormField(
                  controller: _quilometragemController,
                  decoration: const InputDecoration(
                    labelText: 'Quilometragem (km)',
                    suffixText: 'km',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Quilometragem é obrigatória';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Quilometragem deve ser um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Consumo
                TextFormField(
                  controller: _consumoController,
                  decoration: const InputDecoration(
                    labelText: 'Consumo (km/L)',
                    suffixText: 'km/L',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Consumo é obrigatório';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Consumo deve ser um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Observação
                TextFormField(
                  controller: _observacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    hintText: 'Ex: Abastecimento na volta do trabalho',
                  ),
                  maxLines: 3,
                ),
                if (_errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarAbastecimento,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Registrar Abastecimento'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
