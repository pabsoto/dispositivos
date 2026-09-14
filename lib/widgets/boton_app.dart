import 'package:flutter/material.dart';

class BotonApp extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color colorFondo;
  final Color colorTexto;
  final VoidCallback onPressed;

  const BotonApp({
    super.key,
    required this.texto,
    required this.icono,
    required this.colorFondo,
    required this.colorTexto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, color: colorTexto, size: 18),
      label: Text(
        texto,
        style: TextStyle(
          color: colorTexto,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo,
        elevation: 0,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}