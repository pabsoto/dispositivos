import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'pieza_rompecabezas.dart';

class GrillaRompecabezas extends StatelessWidget {
  final int tamano;
  final List<int?> celdas;
  final Map<int, Uint8List> imagenesPorId;
  final void Function(int posicion) onTocarPieza;
  final List<int> movimientosValidos;

  const GrillaRompecabezas({
    super.key,
    required this.tamano,
    required this.celdas,
    required this.imagenesPorId,
    required this.onTocarPieza,
    required this.movimientosValidos,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // fuerza que el tablero sea siempre cuadrado, sin importar el celular
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final ladoCelda = restricciones.maxWidth / tamano;
          final piezasVisibles = <Widget>[];

          for (int posicion = 0; posicion < celdas.length; posicion++) {
            final id = celdas[posicion];
            if (id == null) continue;

            final fila = posicion ~/ tamano;
            final columna = posicion % tamano;

            piezasVisibles.add(
              AnimatedPositioned(
                key: ValueKey(id), // clave estable: asi Flutter anima la posicion en vez de recrear el widget
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                left: columna * ladoCelda,
                top: fila * ladoCelda,
                width: ladoCelda,
                height: ladoCelda,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: PiezaRompecabezas(
                    imagenBytes: imagenesPorId[id]!,
                    sePuedeMover: movimientosValidos.contains(posicion),
                    onTap: () => onTocarPieza(posicion),
                  ),
                ),
              ),
            );
          }

          return Stack(children: piezasVisibles);
        },
      ),
    );
  }
}