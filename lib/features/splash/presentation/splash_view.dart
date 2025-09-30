import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/domain/auth_repository.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // 1) ¿Hay token guardado?
      final token = await _authRepository.getAccessToken();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      // 2) Lee el rol guardado en login (lo guardas como 'userRole')
      final rol = await _authRepository.getUserRole();
      final r = rol?.toUpperCase();

      if (!mounted) return;

      if (r == 'GUARDIA') {
        Navigator.pushReplacementNamed(context, '/dashboard_guardia');
      } else if (r == 'RESIDENTE') {
        Navigator.pushReplacementNamed(context, '/dashboard_residente');
      } else {
        // Si no coincide, manda a login
        Navigator.pushReplacementNamed(context, '/login');
      }

      // Si más adelante agregas admin y tienes la ruta:
      // else if (r == 'ADMIN') {
      //   Navigator.pushReplacementNamed(context, '/dashboard_admin');
      // }

    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen del logo dorado
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Condominio Coral',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700), // Dorado
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFFFFD700), // indicador dorado
            ),
          ],
        ),
      ),
    );
  }
}
