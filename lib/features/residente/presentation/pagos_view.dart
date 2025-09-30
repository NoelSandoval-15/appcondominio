import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:appcondominio/features/auth/data/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PagosView extends StatefulWidget {
  const PagosView({super.key});

  @override
  State<PagosView> createState() => _PagosViewState();
}

class _PagosViewState extends State<PagosView> {
  final AuthService _authService = AuthService();
  List<dynamic> _pagos = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPagos();
  }

  Future<void> _fetchPagos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _authService.getWithAuth('http://10.0.2.2:8000/api/pagos/');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pagos = data;
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _error = "No autorizado. Token inválido o expirado.";
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Error inesperado: ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _loading = false;
      });
    }
  }

  Widget _buildPagoCard(dynamic pago) {
    // Ajusta campos con los nombres que venga tu JSON
    final monto = pago['monto']?.toString() ?? '';
    final tipo = pago['tipo'] ?? '';
    final estado = pago['estado'] ?? '';
    final id = pago['id']?.toString() ?? '';
    final createdAt = pago['created_at'] ?? '';
    DateTime? fechaDt;
    try {
      fechaDt = DateTime.parse(createdAt);
    } catch (_) {
      fechaDt = null;
    }
    final fechaStr = fechaDt != null ? DateFormat('dd/MM/yyyy HH:mm').format(fechaDt) : '';

    final comprobanteUrl = pago['comprobante'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado y monto grande
            Row(
              children: [
                Expanded(
                  child: Text(
                    estado.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
                Text(
                  "${monto} US\$",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("ID Pago: #$id", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),

            const Divider(),

            // Detalles
            const Text(
              "Detalles del Pago",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Tipo: $tipo"),
            Text("Fecha creación: $fechaStr"),
            const SizedBox(height: 8),

            const Divider(),

            // Comprobante (puedes precargar imagen si es URL)
            const Text(
              "Comprobante",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            comprobanteUrl.isNotEmpty
                ? Image.network(comprobanteUrl)
                : const Text("No hay comprobante"),

            const SizedBox(height: 12),

            // Botones (ej: verificar pago, descargar, etc.)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // lógica para verificar pago
                  },
                  child: const Text("Verificar Pago"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // lógica para descargar comprobante
                  },
                  child: const Text("Descargar Comprobante"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pagos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
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
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pagos.length,
        itemBuilder: (context, index) {
          return _buildPagoCard(_pagos[index]);
        },
      ),
    );
  }
}
