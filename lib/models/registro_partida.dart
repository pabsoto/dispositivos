class RegistroPartida {
  final int tamanoGrilla;
  final Duration tiempo;
  final DateTime fecha;
  final int movimientos;

  RegistroPartida({
    required this.tamanoGrilla,
    required this.tiempo,
    required this.fecha,
    required this.movimientos,
  });

  String get tiempoFormateado {
    final minutos = tiempo.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = tiempo.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centesimas = ((tiempo.inMilliseconds.remainder(1000)) ~/ 10).toString().padLeft(2, '0');
    return '$minutos:$segundos.$centesimas';
  }

  String get fechaFormateada {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} - $hora:$minuto';
  }
}