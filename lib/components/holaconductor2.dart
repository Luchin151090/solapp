import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/components/camara.dart';
import 'package:appsol_final/components/pdf.dart';

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
  String? tipo_pago;

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
    this.tipo_pago,
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

class HolaConductor2 extends StatefulWidget {
  const HolaConductor2({
    Key? key,
  }) : super(key: key);

  @override
  State<HolaConductor2> createState() => _HolaConductor2State();
}

class _HolaConductor2State extends State<HolaConductor2> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  bool puedoLlamar = false;
  List<Pedido> listPedidosbyRuta = [];
  String productosYCantidades = '';
  int numerodePedidosExpress = 0;
  int numPedidoActual = 1;
  int pedidoIDActual = 0;
  String nombreCliente = '';
  String apellidoCliente = '';
  Color colorProgreso = Colors.transparent;
  Pedido pedidoTrabajo = Pedido(
      id: 0,
      montoTotal: 0,
      tipo: '',
      fecha: '',
      nombre: '',
      apellidos: '',
      telefono: '',
      //ubicacion: '',
      direccion: '',
      tipo_pago: '');
  int rutaID = 0;
  int? rutaIDpref = 0;
  int? conductorIDpref = 0;
  double totalMonto = 0;
  int cantidad = 0;
  double totalYape = 0;
  double totalPlin = 0;
  double totalEfectivo = 0;
  int totalPendiente = 0;
  int totalProceso = 0;
  double decimalProgreso = 0;
  int porcentajeProgreso = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
    connectToServer();
  }

  _cargarPreferencias() async {
    print('3) CARGAR PREFERENCIAS-------');
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    if (rutaPreference.getInt("Ruta") != null) {
      print('3.a)  EMTRO A los IFS------- ');
      setState(() {
        rutaIDpref = rutaPreference.getInt("Ruta");
      });
    } else {
      setState(() {
        rutaIDpref = 5;
      });
    }
    if (userPreference.getInt("userID") != null) {
      setState(() {
        conductorIDpref = userPreference.getInt("userID");
      });
    } else {
      setState(() {
        conductorIDpref = 0;
      });
    }

    print('4) esta es mi ruta Preferencia ------- $rutaIDpref');
    print('4) esta es mi COND Preferencia ------- $conductorIDpref');
  }

  Future<void> _initialize() async {
    print('1) INITIALIZE-------------');
    print('2) esta es mi ruta Preferencia ------- $rutaIDpref');
    await _cargarPreferencias();
    print('5) esta es mi ruta Preferencia ACT---- $rutaIDpref');
    await getPedidosConductor(rutaIDpref, conductorIDpref);
    await getDetalleXUnPedido(pedidoIDActual);
  }

  Future<dynamic> getPedidosConductor(rutaIDpref, conductorID) async {
    print("6) entro al get PEDIDOS con RUTA $rutaIDpref y COND $conductorID");
    var res = await http.get(
      Uri.parse(
          "$apiUrl$apiPedidosConductor${rutaIDpref.toString()}/${conductorID.toString()}"),
      headers: {"Content-type": "application/json"},
    );
    print(
        "que fue chamooo: $apiPedidosConductor${rutaIDpref.toString()}/${conductorID.toString()}");
    try {
      print("flag");
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
            tipo_pago: mapa['tipo_pago'],
          );
        }).toList();
        print('7) Esta es la lista temporal ${listTemporal.length}');
        //SE SETEA EL VALOR DE PEDIDOS BY RUTA
        setState(() {
          listPedidosbyRuta = listTemporal;
        });
        //SE CALCULA LA LONGITUD DE PEDIDOS BY RUTA PARA SABER CUANTOS SON
        //EXPRESS Y CUANTOS SON NORMALES
        print('7.5) Monto total de lista temporal');
        for (var i = 0; i < listPedidosbyRuta.length; i++) {
          setState(() {
            totalMonto += listPedidosbyRuta[i].montoTotal;
            print('tipo: ${listPedidosbyRuta[i].tipo_pago}');
          });

          switch (listPedidosbyRuta[i].tipo_pago) {
            case 'yape':
              setState(() {
                totalYape += listPedidosbyRuta[i].montoTotal;
              });
              break;
            case 'plin':
              setState(() {
                totalPlin += listPedidosbyRuta[i].montoTotal;
              });
              break;
            case 'efectivo':
              setState(() {
                totalEfectivo += listPedidosbyRuta[i].montoTotal;
              });
              break;
            default:
          }
          switch (listPedidosbyRuta[i].estado) {
            case 'pendiente':
              setState(() {
                totalPendiente++;
              });

              break;
            case 'en proceso':
              setState(() {
                totalProceso++;
              });

              break;
            default:
          }
        }
        print(
            '---precio total de los pedidos: $totalMonto \n yape: $totalYape \n plin:$totalPlin \n efectivo:$totalEfectivo \n #pendientes: $totalPendiente \n #procesos: $totalProceso');
        setState(() {
          cantidad = listPedidosbyRuta.length;
          numerodePedidosExpress = 0;
          numPedidoActual = 0;
        });
        print('8) Longitud de pedidos recibidos: $cantidad');
        print('9) Calculando pedidos express');

        for (var i = 0; i < listPedidosbyRuta.length; i++) {
          if (listPedidosbyRuta[i].tipo == 'express') {
            setState(() {
              numerodePedidosExpress++;
            });
          }
          if (listPedidosbyRuta[i].estado == 'entregado') {
            setState(() {
              numPedidoActual++;
            });
          }
        }

        print("---- numerp de Pedido Actual $numPedidoActual");
        setState(() {
          decimalProgreso = ((numPedidoActual) / cantidad);
          print("-------$numPedidoActual/$cantidad = $decimalProgreso");
          porcentajeProgreso = (decimalProgreso * 100).round();
        });
        if (porcentajeProgreso < 33.4) {
          setState(() {
            colorProgreso = Color.fromRGBO(255, 0, 93, 1.000);
          });
        } else if (porcentajeProgreso < 66.6) {
          setState(() {
            colorProgreso = Color.fromRGBO(244, 183, 87, 1.000);
          });
        } else {
          setState(() {
            colorProgreso = Color.fromRGBO(120, 251, 99, 1.000);
          });
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
            });
            break;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  void connectToServer() async {
    print("3.1) Dentro de connectToServer");
    // Reemplaza la URL con la URL de tu servidor Socket.io
    socket = io.io(apiUrl, <String, dynamic>{
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
      await http.put(Uri.parse("$apiUrl$apiPedidosConductor$pedidoID"),
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
    print('pedido ID: $pedidoID');
    if (pedidoID != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetallePedido + pedidoID.toString()),
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
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    int numeroTotalPedidos = listPedidosbyRuta.length;
    print('16) Esta es la longitud de Pedidos $numeroTotalPedidos');
    print('17) Este es el pedido actual $numPedidoActual');
    print('18) Este es el pedido id actual $pedidoIDActual');
    final userProvider = context.watch<UserProvider>();
    conductorIDpref = userProvider.user?.id;
    //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        //key: _scaffoldKey,
        body: SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                    height: largoActual,
                    width: anchoActual,
                    child: Stack(children: [
                      //EL MAPA OCUPA TODA LA PANTALLA
                      FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(-16.4055561, -71.5712185),
                            initialZoom: 9.2,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                          ]),

                      //BOTON DE MENU
                      //FALTA HABILITAR
                      Positioned(
                        top: anchoActual *
                            0.09, // Ajusta la posición vertical según tus necesidades
                        left: anchoActual *
                            0.05, // Ajusta la posición horizontal según tus necesidades
                        child: SizedBox(
                          height: anchoActual * 0.12,
                          width: anchoActual * 0.12,
                          child: FloatingActionButton(
                            elevation: 20,
                            onPressed: () async {
                              //Habiuliteishon
                            },
                            backgroundColor:
                                const Color.fromRGBO(230, 230, 230, 1),
                            child: const Icon(Icons.menu,
                                color: Color.fromARGB(255, 119, 119, 119)),
                          ),
                        ),
                      ),

                      //BARRA DE PROGRESO
                      Positioned(
                        top: anchoActual *
                            0.08, // Ajusta la posición vertical según tus necesidades
                        right: anchoActual *
                            0.05, // Ajusta la posición horizontal según tus necesidades
                        child: Card(
                          surfaceTintColor:
                              const Color.fromARGB(108, 255, 255, 255),
                          color: const Color.fromARGB(0, 255, 255, 255),
                          elevation: 20,
                          child: Container(
                              alignment: Alignment.center,
                              height: anchoActual * 0.12,
                              width: anchoActual * 0.65,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LinearPercentIndicator(
                                    lineHeight: anchoActual * 0.07,
                                    width: anchoActual * 0.50,
                                    percent: decimalProgreso,
                                    center: Text("$porcentajeProgreso %"),
                                    leading: Text("$numPedidoActual"),
                                    trailing: Text("$numeroTotalPedidos"),
                                    progressColor: colorProgreso,
                                    backgroundColor:
                                        Color.fromARGB(108, 194, 194, 194),
                                    animateFromLastPercent: true,
                                    animationDuration: 50000,
                                    barRadius: Radius.circular(20),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      //BOTON DE LLAMADASSS
                      Positioned(
                        bottom: anchoActual *
                            0.05, // Ajusta la posición vertical según tus necesidades
                        right: anchoActual *
                            0.05, // Ajusta la posición horizontal según tus necesidades
                        child: SizedBox(
                          height: anchoActual * 0.14,
                          width: anchoActual * 0.14,
                          child: ElevatedButton(
                            onPressed: () async {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: pedidoTrabajo.telefono,
                              ); // Acciones al hacer clic en el FloatingActionButton
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                print('no se puede llamar:(');
                              }
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(8),
                              fixedSize: MaterialStatePropertyAll(
                                  Size(anchoActual * 0.14, largoActual * 0.14)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(83, 176, 68, 1.000)),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [Icon(Icons.call, color: Colors.white)],
                            ),
                          ),
                        ),
                      ),
                      //BOTON DE INFO DEL PEDIDO
                      Positioned(
                        bottom: anchoActual *
                            0.05, // Ajusta la posición vertical según tus necesidades
                        left: anchoActual *
                            0.05, // Ajusta la posición horizontal según tus necesidades
                        child: SizedBox(
                          height: anchoActual * 0.14,
                          width: anchoActual * 0.14,
                          child: ElevatedButton(
                            onPressed: () {
                              if (numPedidoActual == numeroTotalPedidos) {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: anchoActual * 0.08,
                                            right: anchoActual * 0.08,
                                            top: largoActual * 0.05,
                                            bottom: largoActual * 0.05),
                                        child: Column(children: [
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 15),
                                              child: const Text(
                                                "¡Terminaste de entregar los pedidos de tu ruta!",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 15),
                                              child: const Text(
                                                "Aquí puedes generar el pdf con el reporte de tu ruta ;) ",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                          SizedBox(
                                            width: anchoActual,
                                            height: 19,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => Pdf(
                                                            rutaID: rutaIDpref,
                                                            pedidos:
                                                                totalPendiente,
                                                            totalMonto:
                                                                totalMonto,
                                                            totalYape:
                                                                totalYape,
                                                            totalPlin:
                                                                totalPlin,
                                                            totalEfectivo:
                                                                totalEfectivo,
                                                            pedidosEntregados:
                                                                totalProceso,
                                                          )),
                                                );
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        const Color.fromARGB(
                                                            255, 2, 86, 155)),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .picture_as_pdf_outlined, // Reemplaza con el icono que desees
                                                    size: 10,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          3), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                                  Text(
                                                    "Crear informe",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ]),
                                      );
                                    });
                              } else {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: anchoActual * 0.08,
                                            right: anchoActual * 0.08,
                                            top: largoActual * 0.05,
                                            bottom: largoActual * 0.05),
                                        child: Column(children: [
                                          Text(
                                            "Pedido ${numPedidoActual + 1}/$numeroTotalPedidos",
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 70,
                                                child: const Text(
                                                  "Productos",
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              )
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 70,
                                                child: const Text(
                                                  "Cliente",
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 70,
                                                child: const Text(
                                                  "Monto",
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 15),
                                              child: const Text(
                                                "Tipo de pago",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          //BOTONES YAPE Y EFECTIVO
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              //BOTON YAPE PLIN
                                              Container(
                                                width:
                                                    anchoActual * (164.5 / 400),
                                                height: largoActual * 0.05,
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Camara(
                                                                      pedidoID:
                                                                          pedidoTrabajo
                                                                              .id,
                                                                      problemasOpago:
                                                                          'pago',
                                                                    )),
                                                      );
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Color
                                                                    .fromRGBO(
                                                                        0,
                                                                        106,
                                                                        252,
                                                                        1.000))),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .camera_alt, // Reemplaza con el icono que desees
                                                          size: 18,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          "Yape/Plin",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      ],
                                                    )),
                                              ),
                                              //BOTON EFECTIVO
                                              Container(
                                                width:
                                                    anchoActual * (164.5 / 400),
                                                height: largoActual * 0.05,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            'TERMINE MI PEDIDO',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        0,
                                                                        106,
                                                                        252,
                                                                        1.000)),
                                                          ),
                                                          content: const Text(
                                                            '¿Entregaste el pedido?',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                          actions: <Widget>[
                                                            ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  print(
                                                                      "print CHIIIII");
                                                                  print(
                                                                      pedidoTrabajo
                                                                          .id);
                                                                  await updateEstadoPedido(
                                                                      'entregado',
                                                                      null,
                                                                      pedidoTrabajo
                                                                          .id);
                                                                  await _initialize();
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
                                                                  '¡SI!',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                      color: Color.fromRGBO(
                                                                          0,
                                                                          106,
                                                                          252,
                                                                          1.000)),
                                                                )),
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Cierra el AlertDialog
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Cancelar',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          18,
                                                                      color: Color.fromRGBO(
                                                                          0,
                                                                          106,
                                                                          252,
                                                                          1.000)),
                                                                )),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(const Color
                                                                .fromRGBO(
                                                                0,
                                                                106,
                                                                252,
                                                                1.000)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .money, // Reemplaza con el icono que desees
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                                      Text(
                                                        "Efectivo",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          //BOTON DE PROBLEMASS
                                          Container(
                                            width: anchoActual,
                                            height: largoActual * 0.05,
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Camara(
                                                              pedidoID:
                                                                  pedidoTrabajo
                                                                      .id,
                                                              problemasOpago:
                                                                  'problemas',
                                                            )),
                                                  );
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(const Color
                                                                .fromRGBO(230,
                                                                230, 230, 1))),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .camera_alt, // Reemplaza con el icono que desees
                                                      size: 18,
                                                      color: Color.fromARGB(
                                                          255, 119, 119, 119),
                                                    ),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      "¿Problemas?",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Color.fromARGB(
                                                              255,
                                                              119,
                                                              119,
                                                              119)),
                                                    )
                                                  ],
                                                )),
                                          ),

                                          /*SizedBox(
                      width: anchoActual,
                      height: 19,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Pdf(
                                      rutaID: rutaIDpref,
                                      pedidos: totalPendiente,
                                      totalMonto: totalMonto,
                                      totalYape: totalYape,
                                      totalPlin: totalPlin,
                                      totalEfectivo: totalEfectivo,
                                      pedidosEntregados: totalProceso,
                                    )),
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
                                  .picture_as_pdf_outlined, // Reemplaza con el icono que desees
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(
                                width:
                                    3), // Ajusta el espacio entre el icono y el texto según tus preferencias
                            Text(
                              "Crear informe",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
               */
                                        ]),
                                      );
                                    });
                              }
                            },
                            child: const Icon(Icons.info_rounded,
                                color: Colors.white),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(8),
                              minimumSize: MaterialStatePropertyAll(Size(
                                  anchoActual * 0.28, largoActual * 0.054)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(0, 106, 252, 1.000)),
                            ),
                          ),
                        ),
                      ),
                    ])))));
  }
}
