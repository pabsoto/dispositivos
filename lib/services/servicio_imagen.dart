import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ServicioImagen {
  final ImagePicker _picker = ImagePicker();

  Future<File?> seleccionarImagen(ImageSource fuente) async {
    final XFile? archivo = await _picker.pickImage(source: fuente);
    if (archivo == null) return null;
    return File(archivo.path);
  }

  // Recorta la imagen en tamano x tamano piezas cuadradas
  Future<List<Uint8List>> recortarEnPiezas(File archivo, int tamano) async {
    final bytesOriginales = await archivo.readAsBytes();
    final imagenDecodificada = img.decodeImage(bytesOriginales);

    if (imagenDecodificada == null) {
      throw Exception('No se pudo leer la imagen');
    }

    // Recorta primero un cuadrado perfecto tomando el centro de la foto
    final lado = imagenDecodificada.width < imagenDecodificada.height
        ? imagenDecodificada.width
        : imagenDecodificada.height;

    final offsetX = (imagenDecodificada.width - lado) ~/ 2;
    final offsetY = (imagenDecodificada.height - lado) ~/ 2;

    final imagenCuadrada = img.copyCrop(
      imagenDecodificada,
      x: offsetX,
      y: offsetY,
      width: lado,
      height: lado,
    );

    final ladoPieza = lado ~/ tamano;
    final piezas = <Uint8List>[];

    for (int fila = 0; fila < tamano; fila++) {
      for (int columna = 0; columna < tamano; columna++) {
        final pieza = img.copyCrop(
          imagenCuadrada,
          x: columna * ladoPieza,
          y: fila * ladoPieza,
          width: ladoPieza,
          height: ladoPieza,
        );
        piezas.add(Uint8List.fromList(img.encodePng(pieza)));
      }
    }

    return piezas;
  }
}