import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/domain/auth_repository.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _roleCtrl = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _loading = false;
  String? _error;

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final data = {
      'username': _emailCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
      'nombre': _nameCtrl.text.trim(),
      'rol': _roleCtrl.text.trim(), // 'residente' o 'guardia'
    };

    final success = await _authRepository.register(data);

    if (success) {
      // Opcional: login automático después del registro
      final loggedIn = await _authRepository.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );

      if (loggedIn) {
        final user = await _authRepository.getUser();
        final rol = user?['roles'];
        if (rol == 'guardia') {
          Navigator.pushReplacementNamed(context, '/dashboard_guardia');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard_residente');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      setState(() {
        _loading = false;
        _error = 'Error al registrar. Verifica los datos.';
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su nombre';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su correo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(labelText: 'Rol (residente o guardia)'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su rol';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitRegister,
                  child: const Text('Registrarse'),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
