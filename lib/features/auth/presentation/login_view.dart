import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/domain/auth_repository.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();

  bool _loading = false;
  String? _error;

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final success = await _authRepository.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!success) {
      setState(() {
        _loading = false;
        _error = 'Credenciales incorrectas';
      });
      return;
    }

    //final rol = await _authRepository.getUserRole();

    final user = await _authRepository.getUser();
    final rol = user?['roles'];

    setState(() => _loading = false);

    if (rol == 'GUARDIA') {
      Navigator.pushReplacementNamed(context, '/dashboard_guardia');
    } else if (rol == 'RESIDENTE') {
      Navigator.pushReplacementNamed(context, '/dashboard_residente');
    } else if (rol == 'ADMIN') {
      Navigator.pushReplacementNamed(context, '/dashboard_admin');
    } else {
      setState(() => _error = 'Rol desconocido');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo o usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su correo o usuario';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su contraseña';
                   return null;
                },
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitLogin,
                  child: const Text('Ingresar'),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
