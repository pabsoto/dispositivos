import 'package:flutter/material.dart';
import '../services/servicio_registros.dart';
import '../utils/constantes.dart';

class PantallaRecords extends StatefulWidget {
  const PantallaRecords({super.key});

  @override
  State<PantallaRecords> createState() => _PantallaRecordsState();
}

class _PantallaRecordsState extends State<PantallaRecords> {
  int _nivelSeleccionado = 2; // 2x2 por defecto

  Widget _botonNivel(int nivel) {
    final seleccionado = _nivelSeleccionado == nivel;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _nivelSeleccionado = nivel),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: seleccionado ? Constantes.verdeSalvia : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Constantes.verdeSalvia, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            '${nivel}x$nivel',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: seleccionado ? Constantes.fondo : Constantes.verdeSalvia,
            ),
          ),
        ),
      ),
    );
  }

  Color _colorPuesto(int puesto) {
    switch (puesto) {
      case 1:
        return Constantes.amarilloMantequilla;
      case 2:
        return Constantes.rosaEmpolvado;
      case 3:
        return Constantes.azulEmpolvado;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final registros = ServicioRegistros.instancia.registrosPorNivel(_nivelSeleccionado);

    return Scaffold(
      backgroundColor: Constantes.fondo,
      appBar: AppBar(
        backgroundColor: Constantes.fondo,
        foregroundColor: Constantes.marronTierra,
        elevation: 0,
        title: Text('Records', style: Constantes.tituloPrincipal(tamano: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Row(children: [_botonNivel(2), _botonNivel(3), _botonNivel(4)]),
            const SizedBox(height: 20),
            Expanded(
              child: registros.isEmpty
                  ? Center(
                      child: Text(
                        'Todavía no hay tiempos guardados\nen el nivel ${_nivelSeleccionado}x$_nivelSeleccionado',
                        style: const TextStyle(color: Constantes.marronTierra),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: registros.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final registro = registros[index];
                        final puesto = index + 1;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Constantes.rosaEmpolvado, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(color: _colorPuesto(puesto), shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(
                                  '$puesto',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Constantes.marronTierra),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  registro.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Constantes.marronTierra),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    registro.tiempoFormateado,
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Constantes.verdeSalvia),
                                  ),
                                  Text(
                                    '${registro.movimientos} mov.',
                                    style: const TextStyle(fontSize: 11, color: Constantes.marronTierra),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}