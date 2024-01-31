/*
//import 'package:app_final/components/test/pedido.dart';
import 'package:app_final/components/test/productos.dart';
import 'package:app_final/components/test/pedido.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:lottie/lottie.dart';

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

  //String apiPromociones = 'https://aguasol-30pw.onrender.com/api/promocion';
  //String apiProductoPromocion ='https://aguasol-30pw.onrender.com/api/prod_prom';
  //String apiProducto = 'https://aguasol-30pw.onrender.com/api/products';
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
              foto:
                  '$apiUrl/images/${mapa['foto'].replaceAll(r'\\', '/')}');
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
      Uri.parse('$apiUrl/api/prod_prom/'+ promocionID.toString()),
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
        appBar: AppBar(
          title: Text(""),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, left: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: const Text(
                                      "Llévate !",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 7, 55, 95),
                                          fontSize: 30,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                  Container(
                                    child: const Text(
                                      "las mejores promos",
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  Container(
                                    child: const Text(
                                      "Solo para tí",
                                      style: TextStyle(fontSize: 27),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 20),
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.blue,
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          'lib/imagenes/gotitapastel.jpg'),
                                      fit: BoxFit.fill,
                                    )),
                              )
                            ]),
                      ),
                      const SizedBox(
                        height: 30,
                      ),

                      //CONTAINER CON LIST BUILDER
                      Container(
                          margin: const EdgeInsets.only(left: 20),
                          padding: const EdgeInsets.all(8),
                          height: 300,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 51, 106, 99),
                              borderRadius: BorderRadius.circular(20)),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listPromociones.length,
                            itemBuilder: (context, index) {
                              Promo promocion = listPromociones[index];
                              return Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.all(10),
                                width: 330,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 390,
                                      height: 160,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                              image:
                                                  NetworkImage(promocion.foto),
                                              fit: BoxFit.scaleDown)),
                                    ),
                                    Container(
                                      height: 90,
                                      margin: const EdgeInsets.only(left: 0),
                                      // color:Colors.blue,
                                      child: Column(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,

                                        children: [
                                          Text(promocion.nombre,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255))),
                                          Text(promocion.descripcion,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255))),
                                          Container(
                                            height: 40,
                                            width: 160,
                                            //color:Colors.pink,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        disminuir(index);
                                                        print(
                                                            "disminuir ${promocion.cantidad}");
                                                      });
                                                    },
                                                    iconSize: 27,
                                                    color: Colors.amber,
                                                    icon: const Icon(Icons
                                                        .remove_circle_outline)),
                                                Text(
                                                  promocion.cantidad.toString(),
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 20),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        incrementar(index);
                                                        print(
                                                            "incrementar ${promocion.cantidad}");
                                                      });
                                                    },
                                                    iconSize: 27,
                                                    color: const Color.fromARGB(
                                                        255, 224, 41, 206),
                                                    icon: const Icon(Icons
                                                        .add_circle_outline))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text(
                          "Su importe es de:",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                            color: Color.fromARGB(255, 1, 25, 44),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: Text(
                          "S/.${total}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                              color: Color.fromARGB(255, 4, 62, 107)),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text(
                          "¿Quieres la promo?",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color.fromARGB(255, 1, 32, 56)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: 200,
                        height: 100,
                        child: Row(
                          children: [
                            ElevatedButton(
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
                                  backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 48, 107, 100),
                              )),
                              child: const Text(
                                "Si!",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 25,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                                height: 80,
                                width: 80,
                                child: Stack(
                                  children: [
                                    Lottie.asset('lib/imagenes/party.json'),
                                    Lottie.asset('lib/animatios/anim_16.json'),
                                  ],
                                ))
                          ],
                        ),
                      )
                    ]))));
  }
}

*/