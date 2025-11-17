import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final senha = TextEditingController();
  final confirmar = TextEditingController();

  String? errorMsg;
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    confirmar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "E-mail"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: senha,
              decoration: const InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: confirmar,
              decoration: const InputDecoration(labelText: "Confirmar Senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (errorMsg != null)
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (email.text.trim().isEmpty || senha.text.isEmpty || confirmar.text.isEmpty) {
                        setState(() => errorMsg = "Preencha todos os campos!");
                        return;
                      }

                      if (senha.text != confirmar.text) {
                        setState(() => errorMsg = "As senhas não coincidem.");
                        return;
                      }

                      setState(() => loading = true);

                      final error = await auth.register(
                        email: email.text.trim(),
                        senha: senha.text.trim(),
                      );

                      if (!mounted) return;

                      setState(() {
                        loading = false;
                        errorMsg = error;
                      });

                      if (error == null && mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        });
                      }
                    },
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}
