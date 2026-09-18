import '../models/registro_partida.dart';

class ServicioRegistros {
  ServicioRegistros._();
  static final ServicioRegistros instancia = ServicioRegistros._();

  final List<RegistroPartida> _registros = [];

  void agregarRegistro(RegistroPartida registro) {
    _registros.add(registro);
  }

  // Devuelve los registros de un nivel, ordenados del tiempo mas rapido al mas lento
  List<RegistroPartida> registrosPorNivel(int tamanoGrilla) {
    final filtrados = _registros.where((r) => r.tamanoGrilla == tamanoGrilla).toList();
    filtrados.sort((a, b) => a.tiempo.compareTo(b.tiempo));
    return filtrados;
  }
}