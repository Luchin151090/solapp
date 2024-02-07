class Producto {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String foto;
  final int? promoID;
  int cantidad;

  Producto(
      {required this.id,
      required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.foto,
      required this.promoID,
      this.cantidad = 0});
}
