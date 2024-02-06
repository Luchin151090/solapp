import 'package:appsol_final/components/productos.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Promo {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String fechaLimite;
  final String foto;
  int cantidad;

  Promo(
      {required this.id,
      required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.fechaLimite,
      required this.foto,
      this.cantidad = 0});
}

class ProductoPromocion {
  final int promocionId;
  final int productoId;
  final int cantidadProd;
  final int? cantidadPromo;

  ProductoPromocion({
    required this.promocionId,
    required this.productoId,
    required this.cantidadProd,
    required this.cantidadPromo,
  });
}

class Promos extends StatefulWidget {
  const Promos({super.key});
  @override
  State<Promos> createState() => _PromosState();
}

class _PromosState extends State<Promos> {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  DateTime fechaLim = DateTime.now();

  List<Producto> productosContabilizados = [];
  List<Promo> promocionesContabilizadas = [];
  List<Promo> listPromociones = [];
  List<ProductoPromocion> prodPromContabilizadas = [];
  List<ProductoPromocion> listProdProm = [];
  int cantidadP = 0;
  bool almenosUno = false;

  @override
  void initState() {
    super.initState();
    getPromociones();
  }

  DateTime mesyAnio(String fecha) {
    fechaLim = DateTime.parse(fecha);
    return fechaLim;
  }

  Future<dynamic> getPromociones() async {
    var res = await http.get(
      Uri.parse('$apiUrl/api/promocion'),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Promo> tempPromocion = data.map<Promo>((mapa) {
          return Promo(
              id: mapa['id'],
              nombre: mapa['nombre'],
              precio: mapa['precio'].toDouble(),
              descripcion: mapa['descripcion'],
              fechaLimite: mapa['fecha_limite'],
              foto: '$apiUrl/images/${mapa['foto'].replaceAll(r'\\', '/')}');
        }).toList();

        setState(() {
          listPromociones = tempPromocion;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

//MOVER A LA OTRA VISTA
  Future<dynamic> getProductoPromocion(promocionID, cantidadPromo) async {
    print("cantidad promo----${cantidadPromo}");
    var res = await http.get(
      Uri.parse('$apiUrl/api/prod_prom/' + promocionID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<ProductoPromocion> tempProductoPromocion =
            data.map<ProductoPromocion>((mapa) {
          return ProductoPromocion(
            promocionId: mapa['promocion_id'],
            productoId: mapa['producto_id'],
            cantidadProd: mapa['cantidad'],
            cantidadPromo: cantidadPromo,
          );
        }).toList();

        setState(() {
          listProdProm = tempProductoPromocion;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getProducto(
      productoID, cantidadProdXProm, cantidadProm, promoID) async {
    ;

    var res = await http.get(
      Uri.parse('$apiUrl/api/products' + "/" + productoID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
              id: mapa['id'],
              precio: 0.0,
              nombre: mapa['nombre'],
              descripcion: mapa['descripcion'],
              foto: "",
              cantidad: cantidadProdXProm * cantidadProm,
              promoID: promoID);
        }).toList();

        setState(() {
          productosContabilizados.addAll(tempProducto);
          print("Prodctos contabilizados");
          print(productosContabilizados);
          //listProductos = tempProducto;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

//FUNCIONES DE SUMATORIA
  void incrementar(int index) {
    setState(() {
      almenosUno = true;
      listPromociones[index].cantidad++;
    });
  }

  void disminuir(int index) {
    setState(() {
      promocionesContabilizadas = [];

      if (listPromociones[index].cantidad > 0) {
        listPromociones[index].cantidad--;
      }
      promocionesContabilizadas =
          listPromociones.where((promocion) => promocion.cantidad > 0).toList();
      print("${promocionesContabilizadas.isEmpty} <--isEmpty?");
      almenosUno = promocionesContabilizadas.isNotEmpty;

      print("PContabilizados: ${promocionesContabilizadas}");
    });
  }

  double obtenerTotal() {
    double stotal = 0;

    promocionesContabilizadas =
        listPromociones.where((promo) => promo.cantidad > 0).toList();
    for (var promo in promocionesContabilizadas) {
      stotal += promo.cantidad * promo.precio;
    }
    return stotal;
  }

  Future<void> obtenerProducto() async {
    setState(() {
      prodPromContabilizadas = [];
    });

    for (var promo in promocionesContabilizadas) {
      await getProductoPromocion(promo.id, promo.cantidad);
      prodPromContabilizadas.addAll(listProdProm);
    }

    print(prodPromContabilizadas);
    setState(() {
      productosContabilizados = [];
    });

    for (var i = 0; i < prodPromContabilizadas.length; i++) {
      await getProducto(
          prodPromContabilizadas[i].productoId,
          prodPromContabilizadas[i].cantidadProd,
          prodPromContabilizadas[i].cantidadPromo,
          prodPromContabilizadas[i].promocionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = obtenerTotal();
    //final TabController _tabController = TabController(length: 2, vsync: this);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 0, left: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Llévate las mejores promos!",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 1, 42, 76),
                                        fontWeight: FontWeight.w200,
                                        fontSize: 20),
                                  ),
                                  Container(
                                    child: const Text(
                                      "Solo para tí",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 1, 46, 84),
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),

                      //CONTAINER CON LIST BUILDER
                      Container(
                          height: 455,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listPromociones.length,
                            itemBuilder: (context, index) {
                              Promo promocion = listPromociones[index];
                              return Card(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                elevation: 8,
                                margin: const EdgeInsets.only(
                                    top: 20, left: 10, right: 10, bottom: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 230,
                                      width: 200,
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image:
                                                  NetworkImage(promocion.foto),
                                              fit: BoxFit.scaleDown)),
                                    ),
                                    Container(
                                      width: 230,
                                      margin: const EdgeInsets.only(
                                          top: 10, right: 15, left: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            promocion.nombre,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          Flex(
                                            direction: Axis.vertical,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                promocion.descripcion
                                                    .capitalize(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 13,
                                                    color: Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Val. Hasta: ${mesyAnio(promocion.fechaLimite).day.toString()}/${mesyAnio(promocion.fechaLimite).month.toString()}/${mesyAnio(promocion.fechaLimite).year.toString()}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                                color: Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          Text(
                                            "S/.${promocion.precio} ",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // cantidadP = producto.cantidad++;
                                                    disminuir(index);
                                                    print(
                                                        "disminuir ${promocion.cantidad}");
                                                  });
                                                },
                                                iconSize: 30,
                                                color: const Color.fromARGB(
                                                    255, 0, 57, 103),
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Color.fromRGBO(
                                                      0, 170, 219, 1.000),
                                                ),
                                              ),
                                              Text(
                                                "${promocion.cantidad}",
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 4, 62, 107),
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // cantidadP = producto.cantidad++;
                                                    incrementar(index);
                                                    print(
                                                        "incrementar ${promocion.cantidad}");
                                                  });
                                                },
                                                iconSize: 30,
                                                color: const Color.fromARGB(
                                                    255, 0, 49, 89),
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                  color: Color.fromRGBO(
                                                      0, 170, 219, 1.000),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: const Text(
                                  "Subtotal:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 1, 25, 44)),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "S/.${total}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 4, 62, 107)),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 20),
                                child: const Text(
                                  "Agregar al carrito",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 1, 32, 56)),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 20),
                                child: ElevatedButton(
                                    onPressed: almenosUno
                                        ? () async {
                                            await obtenerProducto();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Pedido(
                                                        seleccionados:
                                                            productosContabilizados,
                                                        seleccionadosPromo:
                                                            promocionesContabilizadas,
                                                        total: obtenerTotal(),
                                                      )),
                                            );
                                          }
                                        : null,
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(8),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromRGBO(
                                                    120, 251, 99, 1.000))),
                                    child: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.white,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]))));
  }
}
