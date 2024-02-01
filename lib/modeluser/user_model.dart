

class UserModel {
  final int id;
  final String nombre;
  final String apellidos;
  String? codigocliente;
  String? suscripcion;
  // Agrega más atributos según sea necesario

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.codigocliente,
    this.suscripcion


    // Agrega más parámetros según sea necesario
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:json['usuario']['id'] ?? 0,
      nombre: json['usuario']['nombre'] ?? '',
      apellidos: json['usuario']['apellidos'] ?? '',
      codigocliente: json['usuario']['codigocliente'],
      suscripcion: json['usuario']['suscripcion'] ,


      // Agrega más inicializaciones según sea necesario
    );
  }
}
