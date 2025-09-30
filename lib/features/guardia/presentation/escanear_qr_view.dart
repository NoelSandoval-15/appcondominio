import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EscanearQRView extends StatefulWidget {
  const EscanearQRView({super.key});

  @override
  State<EscanearQRView> createState() => _EscanearQRViewState();
}

class _EscanearQRViewState extends State<EscanearQRView> {
  CameraController? _cameraController;
  late final BarcodeScanner _barcodeScanner;
  bool loading = false;
  String? errorMsg;

  File? _capturedImage; // foto tomada
  Map<String, dynamic>? qrData; // datos QR decodificados

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final picture = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(picture.path);
      });
    } catch (e) {
      setState(() => errorMsg = "Error al capturar foto: $e");
    }
  }

  Future<void> _analyzePicture() async {
    if (_capturedImage == null) return;

    try {
      final inputImage = InputImage.fromFile(_capturedImage!);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) {
        setState(() {
          errorMsg = "No se detectó ningún QR, intente de nuevo.";
          _capturedImage = null;
        });
        return;
      }

      for (final barcode in barcodes) {
        try {
          final data = jsonDecode(barcode.rawValue ?? "");
          setState(() {
            qrData = data;
            errorMsg = null;
          });
          return;
        } catch (_) {
          setState(() {
            errorMsg = "El QR no contiene un JSON válido.";
            _capturedImage = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMsg = "Error al analizar: $e";
        _capturedImage = null;
      });
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
      errorMsg = null;
    });
  }

  void _reintentar() {
    setState(() {
      qrData = null;
      errorMsg = null;
      _capturedImage = null;
    });
  }

  Future<void> _registrarVisita() async {
    if (qrData == null) return;

    setState(() => loading = true);

    final token = await storage.read(key: "auth_token");
    final url = Uri.parse("http://127.0.0.1:8000/api/visitas/registrar/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(qrData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Visita registrada correctamente")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de red: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear QR de Visita")),
      body: qrData == null
          ? _capturedImage == null
      // Cámara lista
          ? Column(
        children: [
          Expanded(
            flex: 5,
            child: _cameraController == null ||
                !_cameraController!.value.isInitialized
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(errorMsg!,
                        style: const TextStyle(
                            color: Colors.red, fontSize: 14)),
                  ),
                ElevatedButton.icon(
                  onPressed: _takePicture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capturar QR"),
                ),
              ],
            ),
          ),
        ],
      )
      // Vista previa de la foto
          : Column(
        children: [
          Expanded(
            flex: 5,
            child: Image.file(_capturedImage!, fit: BoxFit.cover),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: _retakePicture,
                  icon: const Icon(Icons.close),
                  label: const Text("Reintentar"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  onPressed: _analyzePicture,
                  icon: const Icon(Icons.check),
                  label: const Text("Analizar"),
                ),
              ],
            ),
          ),
        ],
      )
      // Formulario con datos del QR
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Datos del QR",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildReadOnlyField("Apartamento", "${qrData!['apartamento']}"),
            _buildReadOnlyField("Detalle", "${qrData!['detalle']}"),
            _buildReadOnlyField(
                "Nombre visitante", "${qrData!['visitante']['nombre']}"),
            _buildReadOnlyField(
                "CI visitante", "${qrData!['visitante']['ci']}"),
            _buildReadOnlyField(
                "Celular visitante", "${qrData!['visitante']['celular']}"),
            if (qrData!.containsKey("vehiculo")) ...[
              const SizedBox(height: 10),
              const Text("Vehículo",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              _buildReadOnlyField(
                  "Placa", "${qrData!['vehiculo']['placa']}"),
              _buildReadOnlyField(
                  "Descripción", "${qrData!['vehiculo']['descripcion']}"),
              _buildReadOnlyField("Apartamento",
                  "${qrData!['vehiculo']['apartamento']}"),
              _buildReadOnlyField("Pase conocido",
                  "${qrData!['vehiculo']['pase_conocido']}"),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: loading ? null : _registrarVisita,
                  icon: const Icon(Icons.check),
                  label: loading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text("Registrar visita"),
                ),
                ElevatedButton.icon(
                  onPressed: _reintentar,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reintentar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
      ),
    );
  }
}
