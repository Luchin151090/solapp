import 'package:appsol_final/components/holaconductor2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:appsol_final/models/producto_model.dart';

class ActualizadoStock extends StatefulWidget {
  const ActualizadoStock({
    Key? key,
  }) : super(key: key);

  @override
  State<ActualizadoStock> createState() => _ActualizadoStockState();
}

class _ActualizadoStockState extends State<ActualizadoStock> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  String mensaje =
      'El día de hoy todavía no te han asignado una ruta, espera un momento ;)';
  bool puedoLlamar = false;
  int numerodePedidosExpress = 0;
  int numPedidoActual = 1;
  int pedidoIDActual = 0;
  List<Pedido> listPedidosbyRuta = [];
  List<Producto> listProducto = [];
  bool tengoruta = false;
  Color colorProgreso = Colors.transparent;
  Color colorBotonesAzul = const Color.fromRGBO(0, 106, 252, 1.000);
  Color colorTexto = const Color.fromARGB(255, 75, 75, 75);
  int rutaID = 0;
  int? rutaIDpref = 0;
  //
  int? conductorIDpref = 0;
  int cantidad = 0;
  List<int> idpedidos = [];

  //CREAR UN FUNCION QUE LLAME EL ENDPOINT EN EL QUE SE VERIFICA QUE EL CONDUCTOR
  //TIENE UNA RUTA ASIGNADA PARA ESE DÍA
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
              montoTotal: mapa['total']?.toDouble(),
              latitud: mapa['latitud']?.toDouble(),
              longitud: mapa['longitud']?.toDouble(),
              fecha: mapa['fecha'],
              estado: mapa['estado'],
              tipo: mapa['tipo'],
              nombre: mapa['nombre'],
              apellidos: mapa['apellidos'],
              telefono: mapa['telefono'],
              direccion: mapa['direccion'],
              tipoPago: mapa['tipo_pago'],
              comentario: mapa['observacion'] ?? 'sin comentarios');
        }).toList();
        print('7) Esta es la lista temporal ${listTemporal.length}');
        //SE SETEA EL VALOR DE PEDIDOS BY RUTA
        setState(() {
          listPedidosbyRuta = listTemporal;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
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
            for (var j = 0; j < listProducto.length; j++) {
              for (var i = 0; i < listTemporal.length; i++) {
                if (listProducto[j].nombre == listTemporal[i].productoNombre) {
                  setState(() {
                    listProducto[j].cantidadActual += 1;
                  });
                }
              }
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
            cantidadStock: TextEditingController(),
            cantidadActual: 0,
            cantidadRequeridaParaRuta: 0,
          );
        }).toList();

        if (mounted) {
          setState(() {
            listProducto = tempProducto;
            //conductores = tempConductor;
          });
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
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
        rutaIDpref = 1;
      });
    }
    if (userPreference.getInt("userID") != null) {
      setState(() {
        conductorIDpref = userPreference.getInt("userID");
      });
    } else {
      setState(() {
        conductorIDpref = 3;
      });
    }

    print('4) esta es mi ruta Preferencia ------- $rutaIDpref');
    print('4) esta es mi COND Preferencia ------- $conductorIDpref');
  }

  Future<void> _initialize() async {
    print('1) INITIALIZE-------------');
    await getProducts();
    print('2) esta es mi ruta Preferencia ------- $rutaIDpref');
    await _cargarPreferencias();
    print('5) esta es mi ruta Preferencia ACT---- $rutaIDpref');
    await getPedidosConductor(rutaIDpref, conductorIDpref);
    await getDetalleXUnPedido(pedidoIDActual);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
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
    final userProvider = context.watch<UserProvider>();
    conductorIDpref = userProvider.user?.id;
    //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        //key: _scaffoldKey,
        body: PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromRGBO(0, 106, 252, 1.000),
          Color.fromRGBO(0, 106, 252, 1.000),
          Colors.white,
          Colors.white,
        ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
        child: SafeArea(
            top: true,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: largoActual * 0.03,
                      ),
                      //MENSAJE DE ACTUALIZA TU STOCK O ALGO ASÍ
                      Text(
                        'Actualiza tu stock',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: largoActual * 0.04),
                      ),
                      SizedBox(
                        height: largoActual * 0.02,
                      ),
                      //LISTVIEW BUILDER QUE CREE TEXT FROM FIELD
                      SizedBox(
                        height: largoActual * 0.75,
                        width: anchoActual,
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: listProducto.length,
                            itemBuilder: (context, index) {
                              Producto producto = listProducto[index];
                              return Card(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                elevation: 8,
                                margin: EdgeInsets.only(
                                    left: anchoActual * 0.03,
                                    right: anchoActual * 0.03,
                                    bottom: largoActual * 0.012),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //CONTAINER DE LA FOTO DEL PRODUCTO
                                    Container(
                                      height: largoActual * 0.085,
                                      width: anchoActual * 0.085,
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image:
                                                  NetworkImage(producto.foto),
                                              fit: BoxFit.scaleDown)),
                                    ),
                                    //DESCRIPCION DEL PRODUCTO
                                    Container(
                                      width: anchoActual * 0.42,
                                      height: largoActual * 0.129,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          //NOMBRE DEL PRODUCTO
                                          Text(
                                            producto.nombre.capitalize(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: largoActual * 0.019,
                                                color: const Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          //CUANTOS TIENES, CUANTOS NECESITAS, CUANTOAS TE FALTAN PARA
                                          //CUMPLIR CON TU RUTA
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Stock actual: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                              Text(
                                                producto.cantidadActual
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Stock requerido: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                              Text(
                                                producto
                                                    .cantidadRequeridaParaRuta
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Stock min. faltante: ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                              Text(
                                                '${producto.cantidadActual - producto.cantidadRequeridaParaRuta}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        largoActual * 0.016,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    //AREA PARA INGRESAR LA CANTIDAD QUE ESTAS AÑADIENDO AL CARRO

                                    SizedBox(
                                      width: anchoActual * 0.16,
                                      child: TextFormField(
                                        controller: producto.cantidadStock,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value != null) {
                                            int valor = int.parse(value);
                                            if (valor <=
                                                producto
                                                    .cantidadRequeridaParaRuta) {
                                              return 'Debes ingresar más producto para completar tu ruta';
                                            }
                                          }
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+'))
                                        ],
                                        style: TextStyle(
                                            fontSize: largoActual * 0.03),
                                        cursorColor: const Color.fromRGBO(
                                            0, 106, 252, 1.000),
                                        enableInteractiveSelection: false,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: const Color.fromARGB(
                                              255,
                                              244,
                                              244,
                                              244), // Cambia este color según tus preferencias

                                          hintText: '0',
                                          disabledBorder: InputBorder.none,

                                          hintStyle: TextStyle(
                                              fontSize: largoActual * 0.03),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                      //ESPACIOSSS
                      SizedBox(
                        height: largoActual * 0.04,
                      ),
                      //BOTON DE ACTUALIZAR
                      SizedBox(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HolaConductor2()
                                      //const Promos()
                                      ),
                                );
                                //QUE LO LLEVE A LA VISTA DE FORMULARIO DE LLENADO DE STOCK
                              },
                              child: Text('¡Comenzar!'))),
                    ],
                  ),
                ))),
      ),
    ));
  }
}
