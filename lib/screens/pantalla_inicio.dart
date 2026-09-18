import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/servicio_imagen.dart';
import '../utils/constantes.dart';
import '../widgets/boton_app.dart';
import 'pantalla_configuracion.dart';
import 'pantalla_records.dart';
import 'pantalla_rompecabezas.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final ServicioImagen _servicioImagen = ServicioImagen();
  File? _imagenSeleccionada;

  Future<void> _elegirImagen(ImageSource fuente) async {
    final imagen = await _servicioImagen.seleccionarImagen(fuente);
    if (imagen != null) {
      setState(() => _imagenSeleccionada = imagen);
    }
  }

  Future<void> _continuar() async {
    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona una imagen')),
      );
      return;
    }

    final nivel = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Constantes.fondo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const PantallaConfiguracion(),
    );

    if (nivel == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaRompecabezas(
          imagen: _imagenSeleccionada!,
          tamanoGrilla: nivel,
        ),
      ),
    );
  }

  void _irARecords() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaRecords()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constantes.fondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text('Rompecabezas', style: Constantes.tituloPrincipal()),
              const SizedBox(height: 24),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Constantes.rosaEmpolvado, width: 2),
                      ),
                      child: _imagenSeleccionada != null
                          ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
                          : CustomPaint(
                              painter: _Cuadriculado(),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.image_outlined, size: 48, color: Constantes.rosaEmpolvado),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Tu imagen va aquí',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Constantes.marronTierra),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    if (_imagenSeleccionada != null)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _imagenSeleccionada = null),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Constantes.rosaEmpolvado,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Constantes.marronTierra, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: BotonApp(
                      texto: 'Subir imagen',
                      icono: Icons.upload_rounded,
                      colorFondo: Constantes.rosaEmpolvado,
                      colorTexto: Constantes.marronTierra,
                      onPressed: () => _elegirImagen(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BotonApp(
                      texto: 'Tomar foto',
                      icono: Icons.camera_alt_rounded,
                      colorFondo: Constantes.amarilloMantequilla,
                      colorTexto: Constantes.marronTierra,
                      onPressed: () => _elegirImagen(ImageSource.camera),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BotonApp(
                texto: 'Continuar',
                icono: Icons.arrow_forward_rounded,
                colorFondo: Constantes.verdeSalvia,
                colorTexto: Constantes.fondo,
                onPressed: _continuar,
              ),
              const SizedBox(height: 12),
              BotonApp(
                texto: 'Ir a records',
                icono: Icons.emoji_events_rounded,
                colorFondo: Constantes.azulEmpolvado,
                colorTexto: Constantes.marronTierra,
                onPressed: _irARecords,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cuadriculado extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Constantes.rosaEmpolvado.withOpacity(0.15)
      ..strokeWidth = 1;

    final gridSize = 20.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}