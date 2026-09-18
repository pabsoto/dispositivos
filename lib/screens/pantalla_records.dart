import 'package:flutter/material.dart';
import '../services/servicio_registros.dart';
import '../utils/constantes.dart';

class PantallaRecords extends StatelessWidget {
  const PantallaRecords({super.key});

  @override
  Widget build(BuildContext context) {
    final registros = ServicioRegistros.instancia.registros;

    return Scaffold(
      backgroundColor: Constantes.fondo,
      appBar: AppBar(
        backgroundColor: Constantes.fondo,
        foregroundColor: Constantes.marronTierra,
        elevation: 0,
        title: Text('Records', style: Constantes.tituloPrincipal(tamano: 24)),
      ),
      body: registros.isEmpty
          ? const Center(
              child: Text(
                'Todavía no tienes tiempos guardados',
                style: TextStyle(color: Constantes.marronTierra),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: registros.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final registro = registros[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Constantes.rosaEmpolvado, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nivel ${registro.tamanoGrilla}x${registro.tamanoGrilla}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Constantes.marronTierra),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            registro.fechaFormateada,
                            style: const TextStyle(fontSize: 12, color: Constantes.marronTierra),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Constantes.verdeSalvia,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              registro.tiempoFormateado,
                              style: const TextStyle(color: Constantes.fondo, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${registro.movimientos} movimientos',
                            style: const TextStyle(fontSize: 12, color: Constantes.marronTierra),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}