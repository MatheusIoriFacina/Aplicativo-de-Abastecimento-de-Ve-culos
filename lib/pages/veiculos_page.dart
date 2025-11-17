import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/veiculo.dart';

class VeiculosPage extends StatefulWidget {
  const VeiculosPage({super.key});

  @override
  State<VeiculosPage> createState() => _VeiculosPageState();
}

class _VeiculosPageState extends State<VeiculosPage> {
  final _formKey = GlobalKey<FormState>();
  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  String _tipoCombustivel = 'Gasolina';
  bool _isLoading = false;
  String? _errorMsg;

  final List<String> combustiveis = ['Gasolina', 'Diesel', 'Etanol', 'Híbrido'];

  @override
  void dispose() {
    _modeloController.dispose();
    _marcaController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _adicionarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final error = await firestore.adicionarVeiculo(
      modelo: _modeloController.text.trim(),
      marca: _marcaController.text.trim(),
      placa: _placaController.text.trim(),
      ano: int.parse(_anoController.text),
      tipoCombustivel: _tipoCombustivel,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (error == null) {
        _modeloController.clear();
        _marcaController.clear();
        _placaController.clear();
        _anoController.clear();
        _tipoCombustivel = 'Gasolina';

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo adicionado com sucesso!')),
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
      appBar: AppBar(title: const Text('Meus Veículos')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Formulário de adição
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Adicionar Novo Veículo',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _modeloController,
                          decoration:
                              const InputDecoration(labelText: 'Modelo'),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Modelo é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _marcaController,
                          decoration: const InputDecoration(labelText: 'Marca'),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Marca é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _placaController,
                          decoration: const InputDecoration(labelText: 'Placa'),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Placa é obrigatória';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _anoController,
                          decoration: const InputDecoration(labelText: 'Ano'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Ano é obrigatório';
                            }
                            if (int.tryParse(value!) == null) {
                              return 'Ano deve ser um número válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _tipoCombustivel,
                          decoration: const InputDecoration(
                              labelText: 'Tipo de Combustível'),
                          items: combustiveis
                              .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                              .toList(),
                          onChanged: (newValue) {
                            setState(() => _tipoCombustivel = newValue!);
                          },
                        ),
                        if (_errorMsg != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              _errorMsg!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _adicionarVeiculo,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Adicionar Veículo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Lista de veículos
              Text(
                'Seus Veículos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Veiculo>>(
                stream: firestore.listarVeiculos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Nenhum veículo cadastrado',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }

                  final veiculos = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: veiculos.length,
                    itemBuilder: (context, index) {
                      final veiculo = veiculos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text('${veiculo.marca} ${veiculo.modelo}'),
                          subtitle: Text(
                            '${veiculo.placa} • ${veiculo.ano} • ${veiculo.tipoCombustivel}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirmar exclusão'),
                                  content: const Text(
                                      'Deseja realmente excluir este veículo?'),
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
                                final error = await firestore.deletarVeiculo(veiculo.id);
                                if (!mounted) return;
                                if (error == null) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veículo removido com sucesso!')),
                                  );
                                } else {
                                  setState(() => _errorMsg = error);
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
