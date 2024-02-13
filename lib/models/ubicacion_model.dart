class UbicacionModel {
  final int id;
  final double latitud;
  final double longitud;
  final String direccion;
  final int clienteID;
  final int? clienteNrID;
  final String distrito;

  UbicacionModel({
    required this.id,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.clienteID,
    required this.clienteNrID,
    required this.distrito,
  });
}
