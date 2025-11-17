import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'veiculos_page.dart';
import 'abastecimento_page.dart';
import 'historico_page.dart';
import 'stats_page.dart';
import '../utils/navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimento App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Meus Veículos',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Meus Veículos'),
              onTap: () {
                Navigator.pop(context);
                pushSlideFade(context, const VeiculosPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_gas_station),
              title: const Text('Registrar Abastecimento'),
              onTap: () {
                Navigator.pop(context);
                pushSlideFade(context, const AbastecimentoPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico de Abastecimentos'),
              onTap: () {
                Navigator.pop(context);
                pushSlideFade(context, const HistoricoPage());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withAlpha(26),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Imagem
                  Hero(
                    tag: 'app-logo',
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bem-vindo ao Abastecimento App',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Controle seus abastecimentos e gerencie seus veículos com facilidade',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Botões de ação
                  ElevatedButton.icon(
                    onPressed: () {
                      pushSlideFade(context, const VeiculosPage());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Veículo'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      pushSlideFade(context, const AbastecimentoPage());
                    },
                    icon: const Icon(Icons.local_gas_station),
                    label: const Text('Novo Abastecimento'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      pushSlideFade(context, const StatsPage());
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Estatísticas'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

