import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../algorithms/solucionador_a_estrella.dart';
import '../models/modelo_tablero.dart';
import '../services/servicio_imagen.dart';
import '../utils/constantes.dart';
import '../widgets/boton_app.dart';
import '../widgets/grilla_rompecabezas.dart';
import 'package:flutter/foundation.dart';

class PantallaRompecabezas extends StatefulWidget {
  final File imagen;
  final int tamanoGrilla;

  const PantallaRompecabezas({
    super.key,
    required this.imagen,
    required this.tamanoGrilla,
  });

  @override
  State<PantallaRompecabezas> createState() => _PantallaRompecabezasState();
}

class _PantallaRompecabezasState extends State<PantallaRompecabezas> {
  late ModeloTablero _tablero;
  Map<int, Uint8List> _imagenesPorId = {};
  bool _cargando = true;
  bool _resolviendo = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    _tablero = ModeloTablero(tamano: widget.tamanoGrilla);
    _tablero.mezclar(pasos: widget.tamanoGrilla == 4 ? 50 : 150);

    final servicio = ServicioImagen();
    final piezas = await servicio.recortarEnPiezas(widget.imagen, widget.tamanoGrilla);

    setState(() {
      _imagenesPorId = {for (int i = 0; i < piezas.length; i++) i: piezas[i]};
      _cargando = false;
    });
  }

  void _alTocarPieza(int posicion) {
    if (_resolviendo) return;
    setState(() => _tablero.moverPieza(posicion));
    if (_tablero.estaResuelto()) _mostrarVictoria();
  }

  void _mostrarVictoria() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Constantes.fondo,
        title: const Text('Completaste el rompecabezas', style: TextStyle(color: Constantes.marronTierra)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  Future<void> _resolverConIA() async {
  setState(() => _resolviendo = true);

  final camino = await compute(resolverEnSegundoPlano, {
    'tamano': _tablero.tamano,
    'indicePivote': _tablero.indicePivote,
    'estadoInicial': _tablero.copiarEstado(),
  });

  if (camino == null || !mounted) {
    setState(() => _resolviendo = false);
    return;
  }

  for (final estado in camino) {
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _tablero.celdas = List<int?>.from(estado));
  }

  setState(() => _resolviendo = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constantes.fondo,
      appBar: AppBar(
        backgroundColor: Constantes.fondo,
        foregroundColor: Constantes.marronTierra,
        elevation: 0,
        title: Text('Nivel ${widget.tamanoGrilla}x${widget.tamanoGrilla}'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Constantes.verdeSalvia))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: GrillaRompecabezas(
                          tamano: _tablero.tamano,
                          celdas: _tablero.celdas,
                          imagenesPorId: _imagenesPorId,
                          movimientosValidos: _resolviendo ? [] : _tablero.obtenerMovimientosValidos(),
                          onTocarPieza: _alTocarPieza,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BotonApp(
                      texto: _resolviendo ? 'Resolviendo...' : 'Resolver con IA',
                      icono: Icons.auto_awesome_rounded,
                      colorFondo: Constantes.azulEmpolvado,
                      colorTexto: Constantes.marronTierra,
                      onPressed: _resolviendo ? () {} : _resolverConIA,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}