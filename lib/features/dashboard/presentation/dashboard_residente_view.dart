import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/domain/auth_repository.dart';

class DashboardResidenteView extends StatelessWidget {
  const DashboardResidenteView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Residente'),
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
              icon: const Icon(Icons.qr_code),
              label: const Text('Generar QR de Acceso'),
              onPressed: () {
                Navigator.pushNamed(context, '/generar_qr');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.campaign),
              label: const Text('Ver Avisos'),
              onPressed: () {
                Navigator.pushNamed(context, '/avisos');
              },
            ),
           /* const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.payments),
              label: const Text('Ver Pagos'),
              onPressed: () {
                Navigator.pushNamed(context, '/pagos');
              },
            ),*/
          ],
        ),
      ),
    );
  }
}
