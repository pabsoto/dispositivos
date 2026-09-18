import '../models/registro_partida.dart';

class ServicioRegistros {
  // Patron Singleton: constructor privado + una sola instancia compartida
  ServicioRegistros._();
  static final ServicioRegistros instancia = ServicioRegistros._();

  final List<RegistroPartida> _registros = [];

  List<RegistroPartida> get registros => List.unmodifiable(_registros);

  void agregarRegistro(RegistroPartida registro) {
    _registros.insert(0, registro); // el mas reciente aparece primero
  }
}