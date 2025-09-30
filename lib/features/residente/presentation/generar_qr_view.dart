import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class GenerarQRView extends StatefulWidget {
  const GenerarQRView({super.key});

  @override
  State<GenerarQRView> createState() => _GenerarQRViewState();
}

class _GenerarQRViewState extends State<GenerarQRView> {
  final _formKey = GlobalKey<FormState>();

  final _apartamentoController = TextEditingController();
  final _detalleController = TextEditingController();
  final _nombreController = TextEditingController();
  final _ciController = TextEditingController();
  final _celularController = TextEditingController();
  final _placaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _vehiculoApartamentoController = TextEditingController();
  bool _paseConocido = false;

  String? _qrData;
  File? _qrImageFile;

  Future<void> _generarQR() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        "apartamento": int.tryParse(_apartamentoController.text) ?? 0,
        "detalle": _detalleController.text,
        "visitante": {
          "nombre": _nombreController.text,
          "ci": _ciController.text,
          "celular": _celularController.text,
        },
      };

      if (_placaController.text.isNotEmpty ||
          _descripcionController.text.isNotEmpty ||
          _vehiculoApartamentoController.text.isNotEmpty) {
        data["vehiculo"] = {
          "placa": _placaController.text,
          "descripcion": _descripcionController.text,
          "apartamento": int.tryParse(_vehiculoApartamentoController.text) ?? 0,
          "pase_conocido": _paseConocido,
        };
      }

      final jsonString = jsonEncode(data);

      setState(() {
        _qrData = jsonString;
      });

      final tempDir = await getTemporaryDirectory();
      final qrFile = File("${tempDir.path}/qr_visita.png");

      final qrValidationResult = QrValidator.validate(
        data: jsonString,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: true,
        );

        final picData = await painter.toImageData(300);
        await qrFile.writeAsBytes(picData!.buffer.asUint8List());

        setState(() {
          _qrImageFile = qrFile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR generado correctamente")),
        );
      }
    }
  }

  Future<void> _guardarQR() async {
    if (_qrImageFile == null) return;

    // inicializar MediaStore (solo una vez en toda la app, por seguridad)
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = "VisitasQR"; // 👈 carpeta base

    // pedir permisos
    await Permission.storage.request();

    final mediaStore = MediaStore();
    final result = await mediaStore.saveFile(
      tempFilePath: _qrImageFile!.path,  // 👈 ruta del archivo temporal
      dirType: DirType.photo,            // 👈 vamos a "Imágenes"
      dirName: DirName.pictures,         // 👈 subcarpeta del sistema
      // relativePath: "VisitasQR"       // opcional, si quieres ruta extra
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("QR guardado en galería: ${result.name}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar el QR")),
      );
    }
  }



  Future<void> _compartirQR() async {
    if (_qrImageFile != null) {
      await Share.shareXFiles(
        [XFile(_qrImageFile!.path)],
        text: "Aquí está el QR de mi visita",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generar QR de Visita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Datos Generales",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _apartamentoController,
                decoration: const InputDecoration(
                    labelText: "Número de Apartamento"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _detalleController,
                decoration: const InputDecoration(
                    labelText: "Detalle (motivo de la visita)"),
                validator: (value) =>
                value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),

              const Text("Información del Visitante",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre completo"),
                validator: (value) =>
                value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _ciController,
                decoration:
                const InputDecoration(labelText: "Cédula de Identidad"),
                validator: (value) =>
                value!.isEmpty ? "Campo requerido" : null,
              ),
              TextFormField(
                controller: _celularController,
                decoration:
                const InputDecoration(labelText: "Número de Celular"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? "Campo requerido" : null,
              ),
              const SizedBox(height: 20),

              const Text("Información del Vehículo (Opcional)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: "Placa"),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextFormField(
                controller: _vehiculoApartamentoController,
                decoration:
                const InputDecoration(labelText: "Apartamento del Vehículo"),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text("Pase Conocido"),
                value: _paseConocido,
                onChanged: (val) {
                  setState(() {
                    _paseConocido = val;
                  });
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _generarQR,
                child: const Text("Generar QR"),
              ),
              const SizedBox(height: 20),

              if (_qrData != null) ...[
                const Text("QR generado:",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Center(
                  child: QrImageView(
                    data: _qrData!,
                    size: 250,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _guardarQR,
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar QR"),
                    ),
                    ElevatedButton.icon(
                      onPressed: _compartirQR,
                      icon: const Icon(Icons.share),
                      label: const Text("Compartir QR"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
