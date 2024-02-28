import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:lottie/lottie.dart';

class Producto {
  final String nombre;
  final double precio;
  final String descripcion;

  final String foto;

  Producto(
      {required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.foto});
}

class Hola2 extends StatefulWidget {
  final String? url;
  final String? loggedInWith;
  final int? clienteId;
  //final double? latitud;
  // final double? longitud;

  const Hola2({
    this.url,
    this.loggedInWith,
    this.clienteId,
    // this.latitud, // Nuevo campo
    // this.longitud, // Nuevo campo
    Key? key,
  }) : super(key: key);

  @override
  State<Hola2> createState() => _HolaState();
}

class _HolaState extends State<Hola2> with TickerProviderStateMixin {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  List<Producto> listProducto = [];
  List<UbicacionModel> listUbicacionesObjetos = [];
  List<String> ubicacionesString = [];
  String? _ubicacionSelected;
  late String? dropdownValue;
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorTextos = const Color.fromARGB(255, 1, 42, 76);
  late String direccion;
  late UbicacionModel miUbicacion;
  Timer? _timer;
  //bool _disposed = false;
  //bool _autoScrollInProgress = false;

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  DateTime fechaLimite = DateTime.now();

  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      print('es string');
      return DateTime.parse(fecha);
    } else {
      print('no es string');
      return DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    ordenarFuncionesInit();
  }

  Future<void> ordenarFuncionesInit() async {
    await getUbicaciones(widget.clienteId);
    await getProducts();
  }

  Future<dynamic> getUbicaciones(clienteID) async {
    print("1) get ubicaciones---------");
    print("$apiUrl/api/ubicacion/$clienteID");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de get ubicaciones---------");
        var data = json.decode(res.body);
        List<UbicacionModel> tempUbicacion = data.map<UbicacionModel>((mapa) {
          return UbicacionModel(
            id: mapa['id'],
            latitud: mapa['latitud'].toDouble(),
            longitud: mapa['longitud'].toDouble(),
            direccion: mapa['direccion'],
            clienteID: mapa['cliente_id'],
            clienteNrID: null,
            distrito: mapa['distrito'],
          );
        }).toList();
        if (mounted) {
          setState(() {
            listUbicacionesObjetos = tempUbicacion;
            print(listUbicacionesObjetos);
          });
          for (var i = 0; i < listUbicacionesObjetos.length; i++) {
            setState(() {
              ubicacionesString.add(listUbicacionesObjetos[i].direccion);
            });
          }
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> creadoUbicacion(
      latitudUser, longitudUser, direccion, clienteId, distrito) async {
    print("cREANDO UBIIIIIIIIII");
    await http.post(Uri.parse("$apiUrl/api/ubicacion"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "latitud": latitudUser,
          "longitud": longitudUser,
          "direccion": direccion,
          "cliente_id": clienteId,
          "cliente_nr_id": null,
          "distrito": distrito,
        }));
  }

  Future<dynamic> getProducts() async {
    print("3) get products---------");
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        // VERIFICAR SI EL WIDGET EXISTE Y LUEGO SETEAMOS EL VALOR
        if (mounted) {
          setState(() {
            listProducto = tempProducto;
            //conductores = tempConductor;
          });
        }

        print("4) ....lista productos");
        //print(listProducto[0].foto);
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<void> obtenerDireccion(x, y) async {
    //double latitud = widget.latitud ?? 0.0; // Accede a widget.latitud
    //double longitud = widget.longitud ?? 0.0;
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);

    if (placemark.isNotEmpty) {
      Placemark lugar = placemark.first;
      setState(() {
        direccion =
            "${lugar.locality}, ${lugar.subAdministrativeArea}, ${lugar.street}";
      });
      await creadoUbicacion(x, y, direccion, widget.clienteId, lugar.locality);
      //  return '${lugar.locality},${lugar.subAdministrativeArea},${lugar.street}';
    }
    print("x-----y");
    print("${x},${y}");

    // return '';
  }

  Future<void> currentLocation() async {
    var location = location_package.Location();

//Obtener la ubicación
    location_package.LocationData _locationData;

    // Obtener la ubicación
    try {
      _locationData = await location.getLocation();
      //updateLocation(_locationData);

      // OBTENER DIRECCION ACTUAL
      obtenerDireccion(_locationData.latitude, _locationData.longitude);
      //setState(() {
      // latitudUser = _locationData.latitude;
      //longitudUser = _locationData.longitude;
      // });

      print("----ubicación--");
      print(_locationData);
      //print(latitudUser);
      //print(longitudUser);
      // Aquí puedes utilizar la ubicación obtenida (_locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      print('ES PEDIDOOO');
      cantCarrito = pedido.cantidadProd;
      if (pedido.cantidadProd > 0) {
        setState(() {
          colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
        });
      } else {
        setState(() {
          colorCantidadCarrito = Colors.grey;
        });
      }
    } else {
      print('no es pedido');
      setState(() {
        cantCarrito = 0;
        colorCantidadCarrito = Colors.grey;
      });
    }
  }

  void direccionesVacias() {
    if (listUbicacionesObjetos.isEmpty) {
      setState(() {
        dropdownValue = "";
      });
    } else {
      setState(() {
        dropdownValue = listUbicacionesObjetos.first.direccion;
        miUbicacion = listUbicacionesObjetos.first;
      });
    }
  }

  UbicacionModel direccionSeleccionada(String direccion) {
    UbicacionModel ubicacionObjeto = UbicacionModel(
        id: 0,
        latitud: 0,
        longitud: 0,
        direccion: 'direccion',
        clienteID: 0,
        clienteNrID: 0,
        distrito: 'distrito');
    for (var i = 0; i < listUbicacionesObjetos.length; i++) {
      if (listUbicacionesObjetos[i].direccion == direccion) {
        setState(() {
          ubicacionObjeto = listUbicacionesObjetos[i];
        });
      }
    }
    return ubicacionObjeto;
  }
  // TEST UBICACIONES PARA DROPDOWN

  @override
  void dispose() {
    //_disposed = true; // Mark as disposed
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final TabController _tabController = TabController(length: 2, vsync: this);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final pedidoProvider = context.watch<PedidoProvider>();
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    direccionesVacias();
    esVacio(pedidoProvider.pedido);
    print("ya esta corriendo el widget");
    print(listUbicacionesObjetos);
    return Scaffold(
        backgroundColor: Colors.white,
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          child: SafeArea(
              key: _scaffoldKey,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //CONTAINER DE UBICACION Y CARRITO
                        Container(
                          width: anchoActual,
                          margin: EdgeInsets.only(
                              left: anchoActual * 0.028,
                              right: anchoActual * 0.028),
                          //color: Colors.red,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //LOCATION
                              Container(
                                width: MediaQuery.of(context).size.width / 1.4,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: anchoActual * 0.7,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            83, 176, 68, 1.000),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        //color: Colors.amberAccent,
                                        margin: const EdgeInsets.only(
                                            left: 12, right: 5),
                                        child: DropdownButton<String>(
                                          hint: Text(
                                            '¿A dónde llevamos tu pedido?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: largoActual * 0.018,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          icon: IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                        0, 106, 252, 1.000),
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        top:
                                                            largoActual * 0.041,
                                                        left:
                                                            anchoActual * 0.055,
                                                        right: anchoActual *
                                                            0.055),
                                                    height: largoActual * 0.17,
                                                    width: anchoActual,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Text(
                                                            'Agregar Ubicación',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  largoActual *
                                                                      0.023,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.013),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            print(
                                                                "ubi añadidda");
                                                            await currentLocation();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(8),
                                                            minimumSize:
                                                                MaterialStatePropertyAll(Size(
                                                                    anchoActual *
                                                                        0.28,
                                                                    largoActual *
                                                                        0.054)),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .white),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .add_location_alt_rounded,
                                                                color: const Color
                                                                    .fromRGBO(
                                                                    0,
                                                                    106,
                                                                    252,
                                                                    1.000),
                                                                size:
                                                                    largoActual *
                                                                        0.034,
                                                              ),
                                                              Text(
                                                                ' Agregar ubicación actual',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.021,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        0,
                                                                        106,
                                                                        252,
                                                                        1.000)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(
                                                Icons.add_location_alt_rounded,
                                                size: largoActual * 0.031,
                                                color: Colors.white),
                                          ),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: largoActual * 0.018,
                                              fontWeight: FontWeight.w500),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          elevation: 20,
                                          dropdownColor: const Color.fromRGBO(
                                              83, 176, 68, 1.000),
                                          isExpanded: true,
                                          value: _ubicacionSelected,
                                          items: ubicacionesString
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            print(newValue);
                                            setState(() {
                                              _ubicacionSelected = newValue!;
                                              miUbicacion =
                                                  direccionSeleccionada(
                                                      newValue);
                                              Provider.of<UbicacionProvider>(
                                                      context,
                                                      listen: false)
                                                  .updateUbicacion(miUbicacion);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().shakeX(
                                    duration: Duration(milliseconds: 300),
                                  ),

                              //CARRITO
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        0, 106, 252, 1.000),
                                    borderRadius: BorderRadius.circular(50)),
                                height: largoActual * 0.059,
                                width: largoActual * 0.059,
                                child: Badge(
                                  largeSize: 18,
                                  backgroundColor: colorCantidadCarrito,
                                  label: Text(cantCarrito.toString(),
                                      style: const TextStyle(fontSize: 12)),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Pedido()
                                            //const Promos()
                                            ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.shopping_cart_rounded),
                                    color: Colors.white,
                                    iconSize: largoActual * 0.030,
                                  ).animate().shakeY(
                                        duration: Duration(milliseconds: 300),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //BIENVENIDA DEL CLIENTE
                        Container(
                          width: anchoActual,
                          margin: EdgeInsets.only(
                              left: anchoActual * 0.055,
                              top: largoActual * 0.016),
                          child: Text(
                            "Bienvenid@, ${userProvider.user?.nombre.capitalize()}",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: largoActual * 0.019,
                                color: colorLetra),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.055),
                          child: Text(
                            "Disfruta de Agua Sol!",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: largoActual * 0.019,
                                color: colorTextos),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.016,
                        ),
                        //TAB BAR PRODUCTOS/PROMOCIONES
                        SizedBox(
                          height: largoActual * 0.046,
                          width: anchoActual,
                          child: TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              controller: _tabController,
                              indicatorWeight: 10,
                              /*indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromRGBO(120, 251, 99, 0.5),
                              ),*/
                              labelStyle: TextStyle(
                                  fontSize: largoActual * 0.019,
                                  fontWeight: FontWeight
                                      .w500), // Ajusta el tamaño del texto de la pestaña seleccionada
                              unselectedLabelStyle: TextStyle(
                                  fontSize: largoActual * 0.019,
                                  fontWeight: FontWeight.w300),
                              labelColor: colorTextos,
                              unselectedLabelColor: colorTextos,
                              indicatorColor:
                                  const Color.fromRGBO(83, 176, 68, 1.000),
                              tabs: const [
                                Tab(
                                  text: "Promociones",
                                ),
                                Tab(
                                  text: "Productos",
                                ),
                              ]),
                        ),
                        //IMAGENES DE PRODUCTOS Y PROMOCIONES TAB BAR
                        Container(
                          margin: EdgeInsets.only(
                            top: largoActual * 0.013,
                          ),
                          height: largoActual / 2.5,
                          width: double.maxFinite,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ListView.builder(
                                  controller: scrollController1,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarraNavegacion(
                                                    indice: 0,
                                                    subIndice: 1,
                                                  )
                                              //const Promos()
                                              ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: anchoActual * 0.028),
                                        height: anchoActual * 0.83,
                                        width: anchoActual * 0.83,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 130, 219, 133),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'lib/imagenes/bodegon.png'),
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    );
                                  }),
                              ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController2,
                                  itemCount: listProducto.length,
                                  itemBuilder: (context, index) {
                                    Producto producto = listProducto[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BarraNavegacion(
                                                    indice: 0,
                                                    subIndice: 2,
                                                  )
                                              //const Productos()
                                              ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: anchoActual * 0.028),
                                        height: anchoActual * 0.83,
                                        width: anchoActual * 0.83,
                                        decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 130, 219, 133),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(producto.foto),
                                              fit: BoxFit.fitHeight,
                                            )),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        //Expanded(child: Container()),
                        SizedBox(
                          height: largoActual * 0.03,
                        ),
                        //BILLETERA SOL
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.055),
                          child: Text(
                            "Billetera Sol",
                            style: TextStyle(
                                color: colorTextos,
                                fontWeight: FontWeight.w500,
                                fontSize: largoActual * 0.019),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.15,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              surfaceTintColor: Colors.white,
                              color: Colors.white,
                              elevation: 10,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 40, right: 40, bottom: 10, top: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /** SARITA =) YA ESTA EL END POINT DE SALDO SERA QU LO PRUEBS  */
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'S/. ${userProvider.user?.saldoBeneficio}0',
                                          style: TextStyle(
                                              color: colorLetra,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 35),
                                        ),
                                        Text(
                                          'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                          style: TextStyle(
                                              color: colorLetra,
                                              fontWeight: FontWeight.w400,
                                              fontSize: largoActual * 0.016),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        //color: Colors.amberAccent,
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      child: Lottie.asset(
                                          'lib/imagenes/billetera3.json'),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                      ]))),
        ));
  }
}
