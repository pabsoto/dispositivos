import 'package:flutter/material.dart';
import '../utils/constantes.dart';

class PantallaConfiguracion extends StatelessWidget {
  const PantallaConfiguracion({super.key});

  Widget _opcionNivel(BuildContext context, String etiqueta, int tamano) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pop(context, tamano),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Constantes.azulEmpolvado,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: Constantes.marronTierra,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Constantes.rosaEmpolvado,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Elige tu nivel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Constantes.marronTierra,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _opcionNivel(context, '2x2', 2),
              _opcionNivel(context, '3x3', 3),
              _opcionNivel(context, '4x4', 4),
            ],
          ),
        ],
      ),
    );
  }
}