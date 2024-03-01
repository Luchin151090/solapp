import 'dart:math';
import 'package:turf_pip/turf_pip.dart';

class Zona {
  final int id;
  final String nombre;
  final String poligono;
  List<Point> puntos;
  String departamento;
  String provincia;

  Zona(
      {required this.id,
      required this.nombre,
      required this.poligono,
      this.departamento = '',
      this.provincia = '',
      this.puntos = const [Point(10, 0)]});
}
