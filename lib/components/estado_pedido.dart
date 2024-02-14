import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appsol_final/models/pedido_cliente_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class EstadoPedido extends StatefulWidget {
  final int? clienteId;
  const EstadoPedido({this.clienteId, Key? key}) : super(key: key);
  @override
  State<EstadoPedido> createState() => _EstadoPedido();
}

class _EstadoPedido extends State<EstadoPedido> with TickerProviderStateMixin {
  //Color colorLetra = Color.fromARGB(255, 1, 75, 135);
  Color colorLetra = Colors.black;
  //Color colorTitulos = Color.fromARGB(255, 1, 42, 76);
  Color colorTitulos = Colors.black;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosCliente = "/api/pedido_cliente/";
  String apiProductosPedido = "/api/productosPedido/";
  List<PedidoCliente> listPedidosPendientes = [];
  List<PedidoCliente> listPedidosPasados = [];
  @override
  void initState() {
    super.initState();
    ordenandoGets(widget.clienteId);
  }

  Future<dynamic> getPedidos(clienteID) async {
    print("1) get pedidosss---------");
    print(apiUrl + apiPedidosCliente + clienteID.toString());
    var res = await http.get(
      Uri.parse(apiUrl + apiPedidosCliente + clienteID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de pedidosss---------");
        var data = json.decode(res.body);
        List<PedidoCliente> tempPedidos = data.map<PedidoCliente>((mapa) {
          return PedidoCliente(
            id: mapa['id'],
            estado: mapa['estado'],
            subtotal: mapa['subtotal'].toDouble(),
            descuento: mapa['descuento'].toDouble(),
            total: mapa['total'].toDouble(),
            tipoPago: mapa['tipo_pago'],
            tipoEnvio: mapa['tipo'],
            fecha: mapa['fecha'],
            direccion: mapa['direccion'],
            distrito: mapa['distrito'],
          );
        }).toList();
        setState(() {
          for (var i = 0; i < tempPedidos.length; i++) {
            if (tempPedidos[i].estado == 'pendiente' ||
                tempPedidos[i].estado == 'en proceso') {
              listPedidosPendientes.add(tempPedidos[i]);
            } else if (tempPedidos[i].estado == 'entregado' ||
                tempPedidos[i].estado == 'truncado') {
              listPedidosPasados.add(tempPedidos[i]);
            }
          }
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getProductos(
      pedidoID, List<ProductoPedidoCliente>? listaProductos) async {
    print("1) get productos---------");
    print(apiUrl + apiPedidosCliente + pedidoID.toString());
    var res = await http.get(
      Uri.parse(apiUrl + apiPedidosCliente + pedidoID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de get ubicaciones---------");
        var data = json.decode(res.body);
        List<ProductoPedidoCliente> tempoProductos =
            data.map<ProductoPedidoCliente>((mapa) {
          return ProductoPedidoCliente(
            productoID: mapa['producto_id'],
            productoNombre: mapa['producto_nombre'],
            cantidadProducto: mapa['cantidad'],
            foto: mapa['foto'],
            promocionID: mapa['promocion_id'],
            promocionNombre: mapa['promocion_nombre'],
            cantidadPorPromo: mapa['cantidad_por_promo'],
          );
        }).toList();
        setState(() {
          if (listaProductos is List<ProductoPedidoCliente>) {
            listaProductos.addAll(tempoProductos);
          }
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<void> ordenandoGets(clienteID) async {
    await getPedidos(clienteID);
    for (var i = 0; i < listPedidosPasados.length; i++) {
      await getProductos(
          listPedidosPasados[i].id, listPedidosPasados[i].productos);
    }
    for (var i = 0; i < listPedidosPendientes.length; i++) {
      await getProductos(
          listPedidosPendientes[i].id, listPedidosPendientes[i].productos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        backgroundColor: Colors.white,
      ),*/
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: largoActual * 0.070,
            width: anchoActual,
            decoration: BoxDecoration(
                color: Color.fromARGB(129, 192, 192, 192),
                borderRadius: BorderRadius.circular(20)),
            child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: tabController,
                //indicatorWeight: 10,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromRGBO(0, 82, 164, 0.8),
                ),
                labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: largoActual * 0.020,
                    fontWeight: FontWeight
                        .w500), // Ajusta el tamaño del texto de la pestaña seleccionada
                unselectedLabelStyle: TextStyle(
                    fontSize: largoActual * 0.019, fontWeight: FontWeight.w300),
                //labelColor: colorLetra,
                unselectedLabelColor: colorLetra,
                indicatorColor: const Color.fromRGBO(83, 176, 68, 1.000),
                tabs: const [
                  Tab(
                    text: "Pendientes",
                    icon: Icon(
                      Icons.assignment_rounded,
                      size: 20,
                    ),
                    iconMargin: EdgeInsets.only(bottom: 1),
                  ),
                  Tab(
                    text: "Entregados",
                    icon: Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 20,
                    ),
                    iconMargin: EdgeInsets.only(bottom: 1),
                  ),
                ]),
          ),
          Container(
            margin: EdgeInsets.only(
              top: largoActual * 0.013,
            ),
            height: largoActual / 2.13,
            width: double.maxFinite,
            child: TabBarView(
              controller: tabController,
              children: [
                //LIST VIEW PENDIENTES
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: listPedidosPendientes.length,
                    itemBuilder: (context, index) {
                      PedidoCliente pedido = listPedidosPendientes[index];
                      return GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => 
                                //const Productos()
                                ),
                          );*/
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: anchoActual * 0.028),
                          height: anchoActual * 0.83,
                          width: anchoActual * 0.83,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 75, 108, 134),
                            borderRadius: BorderRadius.circular(50),
                            /*image: DecorationImage(
                                image:
                                    NetworkImage(pedido.productos!.first.foto),
                                fit: BoxFit.cover,
                              )*/
                          ),
                        ),
                      );
                    }),
                //LIST VIEW ENTREGADOS
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: listPedidosPasados.length,
                    itemBuilder: (context, index) {
                      PedidoCliente pedido = listPedidosPasados[index];
                      return GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => 
                                //const Productos()
                                ),
                          );*/
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: anchoActual * 0.028),
                          height: anchoActual * 0.83,
                          width: anchoActual * 0.83,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 75, 108, 134),
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image:
                                    NetworkImage(pedido.productos!.first.foto),
                                fit: BoxFit.cover,
                              )),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ]),
      )),
    );
  }
}
