import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final senha = TextEditingController();
  bool loading = false;
  String? errorMsg;

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
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
            const SizedBox(height: 20),

            if (errorMsg != null)
              Text(errorMsg!, style: const TextStyle(color: Colors.red)),

            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (email.text.trim().isEmpty || senha.text.isEmpty) {
                        setState(() => errorMsg = "Preencha todos os campos!");
                        return;
                      }

                      setState(() => loading = true);

                      final error = await auth.login(
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
              child:
                  loading ? const CircularProgressIndicator() : const Text("Entrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}
