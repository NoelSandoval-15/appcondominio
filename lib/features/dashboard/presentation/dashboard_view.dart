import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/domain/auth_repository.dart';

class DashboardGuardiaView extends StatelessWidget {
  const DashboardGuardiaView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guardia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authRepository.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR'),
              onPressed: () {
                Navigator.pushNamed(context, '/escanear_qr');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('Agenda de Visitas'),
              onPressed: () {
                Navigator.pushNamed(context, '/agenda_visitas');
              },
            ),
          ],
        ),
      ),
    );
  }
}
