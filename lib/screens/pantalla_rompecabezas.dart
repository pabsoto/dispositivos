import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../algorithms/solucionador_a_estrella.dart';
import '../models/modelo_tablero.dart';
import '../models/registro_partida.dart';
import '../services/servicio_imagen.dart';
import '../services/servicio_registros.dart';
import '../utils/constantes.dart';
import '../widgets/boton_app.dart';
import '../widgets/grilla_rompecabezas.dart';

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

  final Stopwatch _cronometro = Stopwatch();
  Timer? _temporizadorUI;
  bool _cronometroIniciado = false;
  bool _resueltoConIA = false;
  bool _finalizado = false;
  int _contadorMovimientos = 0;
  late List<int?> _estadoInicial;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _temporizadorUI?.cancel();
    super.dispose();
  }

  Future<void> _inicializar() async {
    _tablero = ModeloTablero(tamano: widget.tamanoGrilla);
    _tablero.mezclar(pasos: widget.tamanoGrilla == 4 ? 50 : 150);
    _estadoInicial = List<int?>.from(_tablero.celdas);

    final servicio = ServicioImagen();
    final piezas = await servicio.recortarEnPiezas(widget.imagen, widget.tamanoGrilla);

    setState(() {
      _imagenesPorId = {for (int i = 0; i < piezas.length; i++) i: piezas[i]};
      _cargando = false;
    });
  }

  void _iniciarCronometroSiHaceFalta() {
    if (_cronometroIniciado || _resolviendo) return;
    _cronometroIniciado = true;
    _cronometro.start();

    _temporizadorUI = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _detenerCronometro() {
    _cronometro.stop();
    _temporizadorUI?.cancel();
  }

  void _reiniciarCronometro() {
    _cronometro.reset();
    _cronometroIniciado = false;
    _temporizadorUI?.cancel();
  }

  void _empezarDeNuevo() {
    if (_resolviendo) return;
    _reiniciarCronometro();
    setState(() {
      _tablero.celdas = List<int?>.from(_estadoInicial);
      _contadorMovimientos = 0;
      _finalizado = false;
      _resueltoConIA = false;
    });
  }

  void _mezclarDeNuevo() {
    if (_resolviendo) return;
    _reiniciarCronometro();
    setState(() {
      _tablero = ModeloTablero(tamano: widget.tamanoGrilla);
      _tablero.mezclar(pasos: widget.tamanoGrilla == 4 ? 50 : 150);
      _estadoInicial = List<int?>.from(_tablero.celdas);
      _contadorMovimientos = 0;
      _finalizado = false;
      _resueltoConIA = false;
    });
  }

  String get _tiempoActualFormateado {
    final ms = _cronometro.elapsedMilliseconds;
    final minutos = (ms ~/ 60000).toString().padLeft(2, '0');
    final segundos = ((ms ~/ 1000) % 60).toString().padLeft(2, '0');
    final centesimas = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutos:$segundos.$centesimas';
  }

  void _alTocarPieza(int posicion) {
    if (_resolviendo || _finalizado) return;

    _iniciarCronometroSiHaceFalta();
    setState(() {
      _tablero.moverPieza(posicion);
      _contadorMovimientos++;
    });

    if (_tablero.estaResuelto()) {
      _finalizado = true;
      _detenerCronometro();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          if (_resueltoConIA) {
            _mostrarVictoriaIA();
          } else {
            _mostrarDialogoGuardarRecord();
          }
        }
      });
    }
  }

  void _mostrarDialogoGuardarRecord() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DialogoGuardarRecord(
        tiempo: _cronometro.elapsed,
        movimientos: _contadorMovimientos,
        onGuardar: (nombre) {
          ServicioRegistros.instancia.agregarRegistro(
            RegistroPartida(
              nombre: nombre,
              tamanoGrilla: widget.tamanoGrilla,
              tiempo: _cronometro.elapsed,
              fecha: DateTime.now(),
              movimientos: _contadorMovimientos,
            ),
          );
        },
      ),
    );
  }

  void _mostrarVictoriaIA() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Constantes.fondo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Constantes.azulEmpolvado,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.sparkles, color: Constantes.fondo, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              'Resuelto con A*',
              style: Constantes.subtitulo(tamano: 22, color: Constantes.marronTierra),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'El algoritmo encontró la solución',
              style: TextStyle(fontSize: 15, color: Constantes.marronTierra),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Constantes.azulEmpolvado),
              child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolverConIA() async {
    _resueltoConIA = true;
    _detenerCronometro();

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

    if (_tablero.estaResuelto()) {
      _finalizado = true;
      _mostrarVictoriaIA();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constantes.fondo,
      appBar: AppBar(
        backgroundColor: Constantes.fondo,
        foregroundColor: Constantes.marronTierra,
        elevation: 0,
        title: Text('Nivel ${widget.tamanoGrilla}x${widget.tamanoGrilla}', style: Constantes.tituloPrincipal(tamano: 24)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Constantes.verdeSalvia))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _tiempoActualFormateado,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Constantes.marronTierra,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$_contadorMovimientos movimientos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Constantes.marronTierra,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: BotonApp(
                            texto: 'Empezar de nuevo',
                            icono: Icons.refresh_rounded,
                            colorFondo: Constantes.amarilloMantequilla,
                            colorTexto: Constantes.marronTierra,
                            onPressed: _empezarDeNuevo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BotonApp(
                            texto: 'Mezclar de nuevo',
                            icono: Icons.shuffle_rounded,
                            colorFondo: Constantes.rosaEmpolvado,
                            colorTexto: Constantes.marronTierra,
                            onPressed: _mezclarDeNuevo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Constantes.rosaEmpolvado, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(widget.imagen, width: 140, height: 140, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guíate con la imagen original',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Constantes.marronTierra),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Usa esta como referencia',
                                style: TextStyle(fontSize: 11, color: Constantes.marronTierra),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _DialogoGuardarRecord extends StatefulWidget {
  final Duration tiempo;
  final int movimientos;
  final void Function(String nombre) onGuardar;

  const _DialogoGuardarRecord({
    required this.tiempo,
    required this.movimientos,
    required this.onGuardar,
  });

  @override
  State<_DialogoGuardarRecord> createState() => _DialogoGuardarRecordState();
}

class _DialogoGuardarRecordState extends State<_DialogoGuardarRecord> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  String get _tiempoFormateado {
    final ms = widget.tiempo.inMilliseconds;
    final minutos = (ms ~/ 60000).toString().padLeft(2, '0');
    final segundos = ((ms ~/ 1000) % 60).toString().padLeft(2, '0');
    final centesimas = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutos:$segundos.$centesimas';
  }

  void _guardar() {
    final nombre = _controlador.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para guardar tu récord')),
      );
      return;
    }
    widget.onGuardar(nombre);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Constantes.fondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Constantes.verdeSalvia,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.trophy, color: Constantes.fondo, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Lo lograste!',
              style: Constantes.subtitulo(tamano: 22, color: Constantes.marronTierra),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text('Tiempo: $_tiempoFormateado', style: const TextStyle(fontSize: 16, color: Constantes.marronTierra)),
            const SizedBox(height: 4),
            Text('Movimientos: ${widget.movimientos}', style: const TextStyle(fontSize: 16, color: Constantes.marronTierra)),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Si quieres guardar tu récord, ingresa tu nombre',
                style: TextStyle(fontSize: 13, color: Constantes.marronTierra),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controlador,
              maxLength: 20,
              style: const TextStyle(color: Constantes.marronTierra),
              decoration: InputDecoration(
                hintText: 'Tu nombre',
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Constantes.rosaEmpolvado, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Omitir', style: TextStyle(color: Constantes.marronTierra, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constantes.verdeSalvia,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _guardar,
                    child: const Text(
                      'Guardar récord',
                      style: TextStyle(color: Constantes.fondo, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}