import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class AvisosView extends StatefulWidget {
  const AvisosView({Key? key}) : super(key: key);

  @override
  State<AvisosView> createState() => _AvisosViewState();
}

class _AvisosViewState extends State<AvisosView> {
  final AuthService _authService = AuthService();
  List<dynamic> _avisos = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAvisos();
  }

  Future<void> _fetchAvisos() async {
    try {
      final response = await _authService.getWithAuth('http://10.0.2.2:8000/api/avisos/');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _avisos = data;
          _error = null;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = "No autorizado. Token inválido o expirado.";
        });
      } else {
        setState(() {
          _error = "Error inesperado. Código: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : _avisos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _avisos.length,
        itemBuilder: (context, index) {
          final aviso = _avisos[index];
          return ListTile(
            title: Text(aviso['titulo'] ?? 'Sin título'),
            subtitle: Text(aviso['descripcion'] ?? 'Sin descripción'),
            trailing: Text(
              aviso['fecha_publicacion']?.split('T').first ?? '',
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
