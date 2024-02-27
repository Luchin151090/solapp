class UserModel {
  final int id;
  final String nombre;
  final String apellidos;
  double? saldoBeneficio;
  String? codigocliente;
  String? suscripcion;

  // Agrega más atributos según sea necesario

  UserModel(
      {required this.id,
      required this.nombre,
      required this.apellidos,
      this.saldoBeneficio,
      this.codigocliente,
      this.suscripcion

      // Agrega más parámetros según sea necesario
      });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['usuario']['id'] ?? 0,
      nombre: json['usuario']['nombre'] ?? '',
      apellidos: json['usuario']['apellidos'] ?? '',
      saldoBeneficio: json['usuario']['saldo_beneficios'].toDouble(),
      codigocliente: json['usuario']['codigo'],
      suscripcion: json['usuario']['suscripcion'],

      // Agrega más inicializaciones según sea necesario
    );
  }
}
