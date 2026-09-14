import 'dart:math';

class ModeloTablero {
  final int tamano; // n, para una grilla n x n
  late List<int?> celdas; // longitud tamano*tamano
  late int indicePivote; // que pieza (id) fue elegida como el vacio esta ronda

  ModeloTablero({required this.tamano}) {
    _generarTableroResuelto();
  }

  int get totalCeldas => tamano * tamano;

  void _generarTableroResuelto() {
    final random = Random();
    indicePivote = random.nextInt(totalCeldas); // pivote aleatorio: cumple "empieza y termina en cualquier lugar"
    celdas = List<int?>.generate(
      totalCeldas,
      (i) => i == indicePivote ? null : i,
    );
  }

  int get posicionVacia => celdas.indexOf(null);

  List<int> obtenerMovimientosValidos() {
    final vacia = posicionVacia;
    final fila = vacia ~/ tamano;
    final columna = vacia % tamano;
    final movimientos = <int>[];

    if (fila > 0) movimientos.add(vacia - tamano);
    if (fila < tamano - 1) movimientos.add(vacia + tamano);
    if (columna > 0) movimientos.add(vacia - 1);
    if (columna < tamano - 1) movimientos.add(vacia + 1);

    return movimientos;
  }

  bool moverPieza(int posicionPieza) {
    final validos = obtenerMovimientosValidos();
    if (!validos.contains(posicionPieza)) return false;

    final vacia = posicionVacia;
    celdas[vacia] = celdas[posicionPieza];
    celdas[posicionPieza] = null;
    return true;
  }

  // Mezcla haciendo movimientos aleatorios validos (garantiza que sea resoluble)
  void mezclar({int pasos = 150}) {
    final random = Random();
    int? posicionExcluida;

    for (int i = 0; i < pasos; i++) {
      final vacia = posicionVacia;
      final movimientos = obtenerMovimientosValidos()
          .where((m) => m != posicionExcluida)
          .toList();

      final elegido = movimientos[random.nextInt(movimientos.length)];
      moverPieza(elegido);
      posicionExcluida = vacia; // evita deshacer el movimiento anterior de inmediato
    }
  }

  bool estaResuelto() {
    for (int i = 0; i < totalCeldas; i++) {
      if (i == indicePivote) {
        if (celdas[i] != null) return false;
      } else {
        if (celdas[i] != i) return false;
      }
    }
    return true;
  }

  List<int?> copiarEstado() => List<int?>.from(celdas);
}