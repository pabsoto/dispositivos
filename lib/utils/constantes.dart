import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Constantes {
  static const Color fondo = Color(0xFFFBF4E3);
  static const Color marronTierra = Color(0xFF4A3428);
  static const Color rosaEmpolvado = Color(0xFFE9AFC2);
  static const Color verdeSalvia = Color(0xFF6B8552);
  static const Color amarilloMantequilla = Color(0xFFEFC94C);
  static const Color azulEmpolvado = Color(0xFF8FB6D6);

  static TextStyle tituloPrincipal({double tamano = 28, Color? color}) {
    return GoogleFonts.baloo2(
      fontSize: tamano,
      fontWeight: FontWeight.w700,
      color: color ?? marronTierra,
    );
  }

  static TextStyle subtitulo({double tamano = 18, Color? color}) {
    return GoogleFonts.baloo2(
      fontSize: tamano,
      fontWeight: FontWeight.w600,
      color: color ?? marronTierra,
    );
  }
}