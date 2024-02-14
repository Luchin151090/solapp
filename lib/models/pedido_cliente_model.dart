class ProductoPedidoCliente {
  final int productoID;
  final String productoNombre;
  final int cantidadProducto;
  final String foto;
  final int promocionID;
  final String promocionNombre;
  final int cantidadPorPromo;
  int? cantidadPromos;
  ProductoPedidoCliente({
    required this.productoID,
    required this.productoNombre,
    required this.cantidadProducto,
    required this.foto,
    required this.promocionID,
    required this.promocionNombre,
    required this.cantidadPorPromo,
  });
}

class PedidoCliente {
  final int id;
  final String estado;
  final double subtotal;
  final double descuento;
  final double total;
  final String? tipoPago;
  final String tipoEnvio;
  final String fecha;
  final String direccion;
  final String distrito;
  List<ProductoPedidoCliente>? productos;
  PedidoCliente({
    required this.id,
    required this.estado,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.tipoPago,
    required this.tipoEnvio,
    required this.fecha,
    required this.direccion,
    required this.distrito,
  });
}
