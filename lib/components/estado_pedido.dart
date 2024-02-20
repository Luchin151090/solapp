import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appsol_final/models/pedido_cliente_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

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
  Color colorOF = Colors.grey;
  Color colorON = Color.fromRGBO(120, 251, 99, 1.000);
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosCliente = "/api/pedido_cliente/";
  String apiProductosPedido = "/api/productosPedido/";
  String iconoRecibido = 'lib/imagenes/recibidoon4.json';
  String iconoEnCaminoON = 'lib/imagenes/encaminoon1.json';
  String iconoEnCaminoOF = 'lib/imagenes/encaminoof1.json';
  String iconoEntregadoON = 'lib/imagenes/entregadoon1.json';
  String iconoEntregadoOF = 'lib/imagenes/entregadoof1.json';

  String mensajePendiente =
      'Ya recibimos tu pedido!, estamos gestionando la entrega ;)';
  String mensajeEncamino = 'Tus productos Sol ya estan em camino!';
  String mensajeEntregado = 'Ya entregamos tu pedido';
  String linea = 'lib/imagenes/lineacargando.json';
  List<PedidoCliente> listPedidosPendientes = [];
  List<PedidoCliente> listPedidosPasados = [];
  List<ProductoPedidoCliente> listProductosPedidoPendiente = [];
  List<ProductoPedidoCliente> listProductosPedidoPasados = [];

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
        // Verificar si el widget está montado antes de llamar a setState
        if (mounted) {
          setState(() {
            for (var i = 0; i < tempPedidos.length; i++) {
              if (tempPedidos[i].estado == 'pendiente') {
                tempPedidos[i].mensaje = mensajePendiente;
                tempPedidos[i].iconoRecibido = iconoRecibido;
                tempPedidos[i].colorRecibido = colorON;
                tempPedidos[i].iconoProceso = iconoEnCaminoOF;
                tempPedidos[i].colorProceso = colorOF;
                tempPedidos[i].iconoEntregado = iconoEntregadoOF;
                tempPedidos[i].colorEntregado = colorOF;
                listPedidosPendientes.add(tempPedidos[i]);

                // ACA SE PUEDE AGREGAR UN ATRIBUTO DE FECHA DE ENTREGA AL PEDIDO
              } else if (tempPedidos[i].estado == 'en proceso') {
                tempPedidos[i].mensaje = mensajeEncamino;
                tempPedidos[i].iconoRecibido = iconoRecibido;
                tempPedidos[i].colorRecibido = colorON;
                tempPedidos[i].iconoProceso = iconoEnCaminoON;
                tempPedidos[i].colorProceso = colorON;
                tempPedidos[i].iconoEntregado = iconoEntregadoOF;
                tempPedidos[i].colorEntregado = colorOF;
                listPedidosPendientes.add(tempPedidos[i]);
              } else if (tempPedidos[i].estado == 'entregado' ||
                  tempPedidos[i].estado == 'truncado') {
                listPedidosPasados.add(tempPedidos[i]);
              }
            }
          });
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getProductos(
      pedidoID, List<ProductoPedidoCliente> listaProductos) async {
    print("1) get productos---------");
    print(apiUrl + apiProductosPedido + pedidoID.toString());
    var res = await http.get(
      Uri.parse(apiUrl + apiProductosPedido + pedidoID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de get Productos---------");
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
        // Verificar si el widget está montado antes de llamar a setState
        if (mounted) {
          setState(() {
            print("es lista producto");
            print(tempoProductos);
            listaProductos.addAll(tempoProductos);
          });
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<void> ordenandoGets(clienteID) async {
    await getPedidos(clienteID);
    for (var i = 0; i < listPedidosPasados.length; i++) {
      await getProductos(listPedidosPasados[i].id, listProductosPedidoPasados);
    }
    for (var i = 0; i < listPedidosPendientes.length; i++) {
      await getProductos(
          listPedidosPendientes[i].id, listProductosPedidoPendiente);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    print(listPedidosPendientes);
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        backgroundColor: Colors.white,
      ),*/
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //TAB BAR
          Container(
            height: largoActual * 0.060,
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
                    color: Color.fromARGB(255, 0, 0, 0),
                    border: Border.all(
                        color: Colors.white,
                        width: 2,
                        style: BorderStyle.solid)),
                labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: largoActual * 0.018,
                    fontWeight: FontWeight
                        .w400), // Ajusta el tamaño del texto de la pestaña seleccionada
                unselectedLabelStyle: TextStyle(
                    fontSize: largoActual * 0.018, fontWeight: FontWeight.w300),
                //labelColor: colorLetra,
                unselectedLabelColor: colorLetra,
                tabs: const [
                  Tab(
                    text: "Pendientes",
                    icon: Icon(
                      Icons.assignment_rounded,
                      size: 18,
                    ),
                    iconMargin: EdgeInsets.only(bottom: 1),
                  ),
                  Tab(
                    text: "Entregados",
                    icon: Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 18,
                    ),
                    iconMargin: EdgeInsets.only(bottom: 1),
                  ),
                ]),
          ),
          //CONTAINER
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: largoActual * 0.013,
            ),
            height: largoActual / 1.301,
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
                        child: SizedBox(
                          height: anchoActual * 0.51,
                          child: Card(
                            surfaceTintColor: Colors.white,
                            color: Colors.white,
                            elevation: 8,
                            margin: EdgeInsets.only(
                              top: largoActual * 0.0068,
                              bottom: largoActual * 0.013,
                              left: largoActual * 0.0068,
                              right: largoActual * 0.0068,
                            ),
                            child: Container(
                              margin: EdgeInsets.all(
                                largoActual * 0.025,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: largoActual * 0.07,
                                        width: anchoActual * 0.15,
                                        decoration: BoxDecoration(
                                            color: pedido.colorRecibido,
                                            borderRadius:
                                                BorderRadius.circular(80)),
                                        child:
                                            Lottie.asset(pedido.iconoRecibido),
                                      ),
                                      Container(
                                        width: anchoActual * 0.15,
                                        color: Colors.transparent,
                                        child: Lottie.asset(linea),
                                      ),
                                      Container(
                                        height: largoActual * 0.07,
                                        width: anchoActual * 0.15,
                                        decoration: BoxDecoration(
                                            color: pedido.colorProceso,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child:
                                            Lottie.asset(pedido.iconoProceso),
                                      ),
                                      Container(
                                        width: anchoActual * 0.15,
                                        color: Colors.transparent,
                                        child: Lottie.asset(linea),
                                      ),
                                      Container(
                                        height: largoActual * 0.07,
                                        width: anchoActual * 0.15,
                                        decoration: BoxDecoration(
                                            color: pedido.colorEntregado,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        child:
                                            Lottie.asset(pedido.iconoEntregado),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: largoActual * 0.02,
                                  ),
                                  Text(
                                    pedido.mensaje,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorLetra),
                                  ),
                                  Text(
                                    "Fecha: ${pedido.fecha}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorLetra),
                                  ),
                                  Text(
                                    "Total: ${pedido.total}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorLetra),
                                  ),
                                  Text(
                                    "Dirección: ${pedido.direccion}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorLetra),
                                  ),
                                ],
                              ),
                            ),
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
