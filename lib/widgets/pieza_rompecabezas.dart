import 'dart:typed_data';
import 'package:flutter/material.dart';

class PiezaRompecabezas extends StatefulWidget {
  final Uint8List imagenBytes;
  final VoidCallback onTap;
  final bool sePuedeMover;

  const PiezaRompecabezas({
    super.key,
    required this.imagenBytes,
    required this.onTap,
    required this.sePuedeMover,
  });

  @override
  State<PiezaRompecabezas> createState() => _PiezaRompecabezasState();
}

class _PiezaRompecabezasState extends State<PiezaRompecabezas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    // La pieza sube de tamano y vuelve a bajar: efecto "sale y vuelve a la matriz"
    _escala = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.12).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controlador);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.sePuedeMover
          ? () {
              _controlador.forward(from: 0);
              widget.onTap();
            }
          : null,
      child: AnimatedBuilder(
        animation: _escala,
        builder: (context, child) {
          return Transform.scale(
            scale: _escala.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: _controlador.isAnimating
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14), // esquinas redondeadas, pide la rubrica
                child: Image.memory(widget.imagenBytes, fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }
}