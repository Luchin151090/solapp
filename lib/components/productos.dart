import 'package:appsol_final/components/pedido.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

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

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => _ProductosState();
}

class _ProductosState extends State<Productos> {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  List<Producto> listProducto = [];
  int cantidadP = 0;
  bool almenosUno = false;
  List<Producto> productosContabilizados = [];

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            id: mapa['id'],
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            promoID: null,
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        setState(() {
          listProducto = tempProducto;
          //conductores = tempConductor;
        });
        print("....lista productos");
        print(listProducto);
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // FUNCIONES DE SUMATORIA
  void incrementar(int index) {
    setState(() {
      almenosUno = true;
      listProducto[index].cantidad++;
    });
  }

  void disminuir(int index) {
    setState(() {
      if (listProducto[index].cantidad > 0) {
        listProducto[index].cantidad--;
      }
      // Verificar si hay al menos un producto seleccionado después de la disminución
      productosContabilizados =
          listProducto.where((producto) => producto.cantidad > 0).toList();
      print("${productosContabilizados.isEmpty} <--isEmpty?");
      almenosUno = productosContabilizados.isNotEmpty;

      print("PContabilizados: ${productosContabilizados}");
    });
  }

  double obtenerTotal() {
    double stotal = 0;
    productosContabilizados =
        listProducto.where((producto) => producto.cantidad > 0).toList();

    for (var producto in productosContabilizados) {
      print("Cantidad: ${producto.cantidad}, Precio: ${producto.precio}");
      stotal += producto.cantidad * producto.precio;
    }

    print("Total: $stotal");

    return stotal;
  }

  @override
  Widget build(BuildContext context) {
    double total = obtenerTotal();

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
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
                            children: [
                              Container(
                                child: const Text(
                                  "Nuestros Productos",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 1, 42, 76),
                                      fontWeight: FontWeight.w200,
                                      fontSize: 20),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                //color:Colors.grey,
                                //height:100,
                                child: const Text(
                                  "están hechos para ti!",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 1, 46, 84),
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //CONTAINER DE LISTBUILDER
                    SizedBox(
                      height: 420,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listProducto.length,
                          itemBuilder: (context, index) {
                            Producto producto = listProducto[index];
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
                                    width: 180,
                                    margin: const EdgeInsets.only(top: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                            image: NetworkImage(producto.foto),
                                            fit: BoxFit.scaleDown)),
                                  ),
                                  Container(
                                    width: 200,
                                    height: 100,
                                    //color: Colors.grey,
                                    margin: const EdgeInsets.only(
                                        top: 10, right: 10, left: 10),
                                    child: Column(
                                      //crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          producto.nombre.capitalize(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: Color.fromARGB(
                                                  255, 4, 62, 107)),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "S/.${producto.precio} ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 4, 62, 107)),
                                            ),
                                            Text(
                                              producto.descripcion,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 13,
                                                  color: Color.fromARGB(
                                                      255, 4, 62, 107)),
                                            ),
                                          ],
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
                                                      "disminuir ${producto.cantidad}");
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
                                              "${producto.cantidad}",
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 4, 62, 107),
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  // cantidadP = producto.cantidad++;
                                                  incrementar(index);
                                                  print(
                                                      "incrementar ${producto.cantidad}");
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
                          }),
                    ),
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
                                      ? () {
                                          print("Agregar al carrito");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Pedido(
                                                      seleccionados:
                                                          productosContabilizados,
                                                      seleccionadosPromo: const [],
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
                  ],
                ))));
  }
}
