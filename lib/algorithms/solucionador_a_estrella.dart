import 'package:collection/collection.dart';
import '../models/nodo.dart';

class SolucionadorAEstrella {
  final int tamano;
  final int indicePivote;

  SolucionadorAEstrella({required this.tamano, required this.indicePivote});

  List<List<int?>>? resolver(List<int?> estadoInicial) {
    final nodoInicial = Nodo(
      estado: estadoInicial,
      costoG: 0,
      costoH: _heuristica(estadoInicial),
    );

    // Heap binario: sacar el nodo con menor costoF es O(log n), no O(n)
    final abiertos = HeapPriorityQueue<Nodo>((a, b) => a.costoF.compareTo(b.costoF));
    abiertos.add(nodoInicial);

    final visitados = <String>{};
    final mejorCostoConocido = <String, int>{nodoInicial.clave: 0};

    while (abiertos.isNotEmpty) {
      final actual = abiertos.removeFirst();

      if (visitados.contains(actual.clave)) continue;
      visitados.add(actual.clave);

      if (_esFinal(actual.estado)) {
        return _reconstruirCamino(actual);
      }

      final posicionVacia = actual.estado.indexOf(null);

      for (final posicionVecina in _vecinos(posicionVacia)) {
        final nuevoEstado = List<int?>.from(actual.estado);
        nuevoEstado[posicionVacia] = nuevoEstado[posicionVecina];
        nuevoEstado[posicionVecina] = null;

        final claveNueva = nuevoEstado.map((e) => e?.toString() ?? 'X').join(',');
        final nuevoCostoG = actual.costoG + 1;

        if (mejorCostoConocido.containsKey(claveNueva) &&
            mejorCostoConocido[claveNueva]! <= nuevoCostoG) {
          continue;
        }

        mejorCostoConocido[claveNueva] = nuevoCostoG;

        abiertos.add(Nodo(
          estado: nuevoEstado,
          costoG: nuevoCostoG,
          costoH: _heuristica(nuevoEstado),
          padre: actual,
          movimiento: posicionVecina,
        ));
      }
    }

    return null;
  }

  List<List<int?>> _reconstruirCamino(Nodo nodoFinal) {
    final camino = <List<int?>>[];
    Nodo? actual = nodoFinal;
    while (actual != null) {
      camino.add(actual.estado);
      actual = actual.padre;
    }
    return camino.reversed.toList();
  }

  int _heuristica(List<int?> estado) {
    int total = 0;
    for (int posicion = 0; posicion < estado.length; posicion++) {
      final id = estado[posicion];
      if (id == null) continue;

      final filaActual = posicion ~/ tamano;
      final columnaActual = posicion % tamano;
      final filaCorrecta = id ~/ tamano;
      final columnaCorrecta = id % tamano;

      total += (filaActual - filaCorrecta).abs() + (columnaActual - columnaCorrecta).abs();
    }
    return total;
  }

  bool _esFinal(List<int?> estado) {
    for (int i = 0; i < estado.length; i++) {
      if (i == indicePivote) {
        if (estado[i] != null) return false;
      } else {
        if (estado[i] != i) return false;
      }
    }
    return true;
  }

  List<int> _vecinos(int posicionVacia) {
    final fila = posicionVacia ~/ tamano;
    final columna = posicionVacia % tamano;
    final resultado = <int>[];
    if (fila > 0) resultado.add(posicionVacia - tamano);
    if (fila < tamano - 1) resultado.add(posicionVacia + tamano);
    if (columna > 0) resultado.add(posicionVacia - 1);
    if (columna < tamano - 1) resultado.add(posicionVacia + 1);
    return resultado;
  }
}

// Funcion de nivel superior (fuera de la clase): compute() la necesita asi
// para poder ejecutarla en un isolate aparte, sin congelar la interfaz.
List<List<int?>>? resolverEnSegundoPlano(Map<String, dynamic> parametros) {
  final solucionador = SolucionadorAEstrella(
    tamano: parametros['tamano'] as int,
    indicePivote: parametros['indicePivote'] as int,
  );
  final estadoInicial = (parametros['estadoInicial'] as List).cast<int?>();
  return solucionador.resolver(estadoInicial);
}