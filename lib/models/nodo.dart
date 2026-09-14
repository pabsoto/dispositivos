class Nodo {
  final List<int?> estado; // el tablero en ese momento: id de pieza o null (vacio)
  final int costoG; // pasos dados desde el inicio hasta aqui
  final int costoH; // heuristica: cuanto falta estimado para llegar a la meta
  final Nodo? padre; // el nodo del que vino, para reconstruir el camino
  final int? movimiento; // posicion que se movio para llegar a este estado

  Nodo({
    required this.estado,
    required this.costoG,
    required this.costoH,
    this.padre,
    this.movimiento,
  });

  int get costoF => costoG + costoH;

  String get clave => estado.map((e) => e?.toString() ?? 'X').join(',');
}