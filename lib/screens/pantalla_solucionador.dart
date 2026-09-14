import 'package:flutter/material.dart';

class PantallaSolucionador extends StatefulWidget {
  const PantallaSolucionador({super.key});

  @override
  State<PantallaSolucionador> createState() => _PantallaSolucionadorState();
}

class _PantallaSolucionadorState extends State<PantallaSolucionador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solver'),
      ),
      body: const Center(
        child: Text('Solver Screen - TODO'),
      ),
    );
  }
}
