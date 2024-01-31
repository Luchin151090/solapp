/*import 'package:app_final/components/test/camara.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as map;
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:lottie/lottie.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class Pedido {
  final int id;
  final double montoTotal;
  final String tipo;
  final String fecha;
  String estado;

  ///REVISAR EN QUÈ FORMATO SE RECIVE LA FECHA
  final String nombre;
  final String apellidos;
  final String telefono;
  //final String ubicacion;
  final String direccion;

  Pedido({
    Key? key,
    required this.id,
    required this.montoTotal,
    required this.tipo,
    required this.fecha,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    //required this.ubicacion,
    required this.direccion,
    this.estado = 'en proceso',
  });
}

class DetallePedido {
  final int pedidoID;
  final int productoID;
  final String productoNombre;
  final int cantidadProd;
  final int? promocionID;

  const DetallePedido({
    Key? key,
    required this.pedidoID,
    required this.productoID,
    required this.productoNombre,
    required this.cantidadProd,
    required this.promocionID,
  });
}

class HolaConductor extends StatefulWidget {
  const HolaConductor({super.key});

  @override
  State<HolaConductor> createState() => _HolaConductorState();
}

class _HolaConductorState extends State<HolaConductor> {
  late io.Socket socket;
  /*String apiPedidosConductor = 'http://10.0.2.2:8004/api/pedido_conductor/';
  String apiDetallePedido = 'http://10.0.2.2:8004/api/detallepedido/';*/
  String apiPedidosConductor =
      'https://aguasolfinal-dev-bbhx.1.us-1.fl0.io/api/pedido_conductor/';
  String apiDetallePedido =
      'https://aguasolfinal-dev-bbhx.1.us-1.fl0.io/api/detallepedido/';
  int conductorID = 1;
  bool puedoLlamar = false;
  List<Pedido> listPedidosbyRuta = [];
  String productosYCantidades = '';
  int numerodePedidosExpress = 0;
  int numPedidoActual = 0;
  int pedidoIDActual = 0;
  String nombreCliente = '';
  String apellidoCliente = '';
  Pedido pedidoTrabajo = Pedido(
      id: 0,
      montoTotal: 0,
      tipo: '',
      fecha: '',
      nombre: '',
      apellidos: '',
      telefono: '',
      //ubicacion: '',
      direccion: '');
  int rutaID = 0;
  int? rutaIDpref = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
    connectToServer();
  }

  _cargarPreferencias() async {
    print('3) CARGAR PREFERENCIAS-------');
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    setState(() {
      rutaIDpref = rutaPreference.getInt("Ruta");
      print('4) esta es mi ruta Preferencia ------- $rutaIDpref');
    });
  }

  Future<void> _initialize() async {
    print('1) INITIALIZE-------------');
    print('2) esta es mi ruta Preferencia ------- $rutaIDpref');
    await _cargarPreferencias();
    print('5) esta es mi ruta Preferencia ACT---- $rutaIDpref');
    await getPedidosConductor(rutaIDpref, conductorID);
    await getDetalleXUnPedido(pedidoIDActual);
  }

  Future<dynamic> getPedidosConductor(rutaIDpref, conductorID) async {
    print("6) entro al get PEDIDOS con RUTA $rutaIDpref y COND $conductorID");
    var res = await http.get(
      Uri.parse(
          "$apiPedidosConductor${rutaIDpref.toString()}/${conductorID.toString()}"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Pedido> listTemporal = data.map<Pedido>((mapa) {
          return Pedido(
            id: mapa['id'],
            montoTotal: mapa['total'].toDouble(),
            fecha: mapa['fecha'],
            estado: mapa['estado'],
            tipo: mapa['tipo'],
            nombre: mapa['nombre'],
            apellidos: mapa['apellidos'],
            telefono: mapa['telefono'],
            //ubicacion: mapa['ubicacion'],
            direccion: mapa['direccion'],
          );
        }).toList();
        setState(() {
          print('7) Esta es la lista temporal ${listTemporal.length}');
          //SE SETEA EL VALOR DE PEDIDOS BY RUTA
          listPedidosbyRuta = listTemporal;
          //SE CALCULA LA LONGITUD DE PEDIDOS BY RUTA PARA SABER CUANTOS SON
          //EXPRESS Y CUANTOS SON NORMALES
          print(
              '8) Longitud de pedidos recibidos: ${listPedidosbyRuta.length}');
          print('9) Calculando pedidos express');
          for (var i = 0; i < listPedidosbyRuta.length; i++) {
            if (listPedidosbyRuta[i].tipo == 'express') {
              setState(() {
                numerodePedidosExpress++;
              });
            }
          }
          print('10) Cantidad de Pedidos express: $numerodePedidosExpress');
          //CALCULA EL PEDIDO SIGUIENTE QUE SE ENCUENTRA "EN PROCESO"
          for (var i = 0; i < listPedidosbyRuta.length; i++) {
            if (listPedidosbyRuta[i].estado == 'en proceso') {
              print('----------------------------------');
              print('11) Este es i $i');
              setState(() {
                pedidoIDActual = listPedidosbyRuta[i].id;
                pedidoTrabajo = listPedidosbyRuta[i];
                nombreCliente = listPedidosbyRuta[i].nombre.capitalize();
                apellidoCliente = listPedidosbyRuta[i].apellidos.capitalize();
                print('12) Este es el pedidoIDactual $pedidoIDActual');
                numPedidoActual = i + 1;
                print('13) Este es el pedido actual $numPedidoActual');
              });
              break;
            }
          }
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  void connectToServer() async {
    print("3.1) Dentro de connectToServer");
    // Reemplaza la URL con la URL de tu servidor Socket.io
    socket = //io.io('http://10.0.2.2:8004', <String, dynamic>{
        io.io('https://aguasolfinal-dev-bbhx.1.us-1.fl0.io', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });
    socket.connect();
    socket.onConnect((_) {
      print('Conexión establecida: CONDUCTOR');
      // Inicia la transmisión de ubicación cuando se conecta
      //iniciarTransmisionUbicacion();
    });
    socket.onDisconnect((_) {
      print('Conexión desconectada: CONDUCTOR');
    });
    socket.onConnectError((error) {
      print("Error de conexión $error");
    });
    socket.onError((error) {
      print("Error de socket, $error");
    });
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    socket.on(
      'creadoRuta',
      (data) {
        print("------esta es lA RUTA");
        print(data['id']);

        setState(() {
          rutaID = data['id'];
          rutaPreference.setInt("Ruta", rutaID);
        });
      },
    );
    socket.on('Llama tus Pedidos :)', (data) {
      print('Puedo llamar a mis pedidos $data');
      setState(() {
        puedoLlamar = true;
      });
      if (puedoLlamar == true) {
        _initialize();
      }
    });
    //  }
  }

  Future<dynamic> updateEstadoPedido(estadoNuevo, foto, pedidoID) async {
    if (pedidoID != 0) {
      await http.put(Uri.parse("$apiPedidosConductor$pedidoID"),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "estado": estadoNuevo,
            "foto": foto,
          }));
    } else {
      print('papas fritas');
    }
  }

  Future<dynamic> getDetalleXUnPedido(pedidoID) async {
    print('----------------------------------');
    print('14) Dentro de Detalles');
    if (pedidoID != 0) {
      var res = await http.get(
        Uri.parse(apiDetallePedido + pedidoID.toString()),
        headers: {"Content-type": "application/json"},
      );
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          List<DetallePedido> listTemporal = data.map<DetallePedido>((mapa) {
            return DetallePedido(
              pedidoID: mapa['pedido_id'],
              productoID: mapa['producto_id'],
              productoNombre: mapa['nombre'],
              cantidadProd: mapa['cantidad'],
              promocionID: mapa['promocion_id'],
            );
          }).toList();

          setState(() {
            for (var i = 0; i < listTemporal.length; i++) {
              var salto = '\n';
              if (i == 0) {
                setState(() {
                  productosYCantidades =
                      "${listTemporal[i].productoNombre} x ${listTemporal[i].cantidadProd.toString()} uds."
                          .capitalize();
                });
              } else {
                setState(() {
                  productosYCantidades =
                      "$productosYCantidades $salto${listTemporal[i].productoNombre.capitalize()} x ${listTemporal[i].cantidadProd.toString()} uds.";
                });
              }
              print('15) Estas son los prods. $productosYCantidades');
            }
          });
        }
      } catch (e) {
        print('Error en la solicitud: $e');
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      print('papas');
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;
    int numeroTotalPedidos = listPedidosbyRuta.length;
    print('16) Esta es la longitud de Pedidos $numeroTotalPedidos');
    print('17) Este es el pedido id actual $numPedidoActual');
    print('18) Este es el pedido actual $pedidoIDActual');

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // color: Colors.grey,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            //margin: const EdgeInsets.only(left: ),
                            child: IconButton(
                                onPressed: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                icon: Icon(
                                  Icons.menu,
                                  size: 30,
                                )),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: ClipRRect(
                              child: Image.asset('lib/imagenes/repartidor.jpg'),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ],
                      ),
                    ),

                    //este container tiene los pedidos programas y express
                    Container(
                      margin: const EdgeInsets.only(top: 1, left: 10),
                      height: 75,
                      // color: Colors.grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 100,
                            width: 210,
                            //color: Colors.green,
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      // color:Colors.pink,
                                      border: Border.all(
                                          width: 3,
                                          color: const Color.fromARGB(
                                              255, 1, 116, 89))),
                                  child: Text(
                                    " ${numeroTotalPedidos - numerodePedidosExpress} ",
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 53, 95),
                                        fontSize: 20),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  "Pedidos \nProgramados",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Badge(
                                  largeSize: 25,
                                  label: Text(" $numerodePedidosExpress ",
                                      style: const TextStyle(fontSize: 20)),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'lib/imagenes/express.png'))),
                                  ),
                                ),
                                const Text("Express",
                                    style: TextStyle(fontSize: 15))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    //ESTE CONTEINER TIENE LA INFO DEL PEDIDO
                    Container(
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      //color: Colors.amber,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          //,
                          children: [
                            Text(
                              "Pedido $numPedidoActual/$numeroTotalPedidos ",
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 70,
                                  child: const Text(
                                    "Productos",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  ":   ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  productosYCantidades,
                                  style: const TextStyle(fontSize: 14),
                                )
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 70,
                                  child: const Text(
                                    "Cliente",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  ":   ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "${nombreCliente} ${apellidoCliente}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 70,
                                  child: const Text(
                                    "Monto",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  ":   ",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "S/. ${pedidoTrabajo.montoTotal}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ]),
                    ),

                    // MAPA
                    Container(
                      // padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(right: 10, left: 10),
                      //width: 500,
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 16, 63, 100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(-16.40521646629229,
                                    -71.57102099896395), // Centro del mapa (California)
                                initialZoom: 17.0, // Nivel de zoom
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  //subdomains: ['a', 'b', 'c'],
                                )
                              ]),
                          Positioned(
                            bottom:
                                16.0, // Ajusta la posición vertical según tus necesidades
                            right:
                                16.0, // Ajusta la posición horizontal según tus necesidades
                            child: Container(
                              height: 40,
                              width: 40,
                              child: FloatingActionButton(
                                onPressed: () async {
                                  final Uri url = Uri(
                                    scheme: 'tel',
                                    path: pedidoTrabajo.telefono,
                                  ); // Acciones al hacer clic en el FloatingActionButton
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    print('no se puede llamar');
                                  }
                                },
                                backgroundColor:
                                    Color.fromARGB(255, 53, 142, 80),
                                child:
                                    const Icon(Icons.call, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                        margin: const EdgeInsets.only(left: 15),
                        child: const Text(
                          "Tipo de pago",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        )),

                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      margin: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 160,
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Camara(
                                              pedidoID: pedidoTrabajo.id,
                                              problemasOpago: 'problemas',
                                            )),
                                  );
                                },
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromARGB(255, 2, 86, 155))),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .camera_alt, // Reemplaza con el icono que desees
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Yape/Pin",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    )
                                  ],
                                )),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Container(
                            width: 160,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'TERMINE MI PEDIDO',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 4, 80, 143)),
                                      ),
                                      content: const Text(
                                        '¿Entregaste el pedido?',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                            onPressed: () {
                                              updateEstadoPedido('entregado',
                                                  null, pedidoTrabajo.id);
                                              Navigator.of(context).pop();
                                              initState(); // Cierra el AlertDialog
                                            },
                                            child: const Text(
                                              '¡SI!',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 13, 58, 94)),
                                            )),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Cierra el AlertDialog
                                            },
                                            child: const Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Color.fromARGB(
                                                      255, 13, 58, 94)),
                                            )),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 2, 86, 155)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .money, // Reemplaza con el icono que desees
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Efectivo",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                  ]))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 45,
        width: anchoPantalla - 30,
        margin: const EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Camara(
                        pedidoID: pedidoTrabajo.id,
                        problemasOpago: 'problemas',
                      )),
            );
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt, // Reemplaza con el icono que desees
                size: 24,
                color: Colors.white,
              ),
              SizedBox(
                  width:
                      8), // Ajusta el espacio entre el icono y el texto según tus preferencias
              Text(
                "Reportar Problemas",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/