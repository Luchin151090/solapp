import 'package:appsol_final/components/asistencia.dart';
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
import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';

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
  List<Ubicacion> listUbicacionesObjetos=[];
  //late List<String> listUbicaciones = [];
  late String dropdownValue = listUbicacionesObjetos.first.direccion;
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  late String direccion;

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  @override
  void initState() {
    super.initState();
    getProducts();
    getUbicaciones(widget.clienteId);
    /* if (widget.latitud != null && widget.longitud != null) {
    obtenerDireccion(widget.latitud!, widget.longitud!).then((res2) {
      setState(() {
        print("coor");
        print(res2);
        listUbicaciones.add(res2);
        dropdownValue = listUbicaciones.first;
      });
    });
  } else {
    print("Las coordenadas son nulas");
    obtenerDireccion(-16.4054755, -71.5706074).then((res) {
      setState(() {
        listUbicaciones.add(res);
      });
    });
  }*/
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  Future<dynamic> getUbicaciones(clienteID) async {
    print("-------get ubicaciones---------");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Ubicacion> tempUbicacion = data.map<Ubicacion>((mapa) {
          return Ubicacion(
            id: mapa['id'],
            latitud: mapa['latitud'].toDouble(),
            longitud: mapa['longitud'].toDouble(),
            direccion: mapa['direccion'],
            clienteID: mapa['cliente_id'],
            clienteNrID: null,
            distrito: mapa['distrito'],
          );
        }).toList();

        setState(() {
          listUbicacionesObjetos = tempUbicacion;
          //conductores = tempConductor;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> creadoUbicacion(latitudUser,longitudUser,direccion,clienteId, distrito) async {
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
    print("-------get products---------");
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

        setState(() {
          listProducto = tempProducto;
          //conductores = tempConductor;
        });
        print("....lista productos");
        print(listProducto[0].foto);
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  bool _autoScrollInProgress = false;

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (!_autoScrollInProgress) {
        _autoScroll();
      }
    });
  }

  void _autoScroll() async {
    try {
      // Marcar que el desplazamiento automático está en progreso
      _autoScrollInProgress = true;

      print("Auto-scroll initiated");

      // Espera 5 segundos antes de iniciar el desplazamiento automático
      await Future.delayed(const Duration(seconds: 2));

      // CONTROLLER 1
      if (_scrollController1.hasClients) {
        print("ScrollController1 has clients");

        // Verificar que el controlador tenga posiciones antes de realizar operaciones
        if (_scrollController1.position.maxScrollExtent > 0.0) {
          // Desplázate hacia abajo
          await _scrollController1.animateTo(
            _scrollController1.position.maxScrollExtent,
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
          );

          // Espera 4 segundos antes de volver a la posición inicial
          await Future.delayed(const Duration(seconds: 4));

          // Desplázate de nuevo hacia arriba
          await _scrollController1.animateTo(
            0.0,
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
          );
        } else {
          print("ScrollController1 has no positions");
        }
      } else {
        print("ScrollController1 has no clients");
      }

      // CONTROLLER 2
      if (_scrollController2.hasClients) {
        print("ScrollController1 has clients");

        // Verificar que el controlador tenga posiciones antes de realizar operaciones
        if (_scrollController2.position.maxScrollExtent > 0.0) {
          // Desplázate hacia abajo
          await _scrollController2.animateTo(
            _scrollController2.position.maxScrollExtent,
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
          );

          // Espera 4 segundos antes de volver a la posición inicial
          await Future.delayed(const Duration(seconds: 4));

          // Desplázate de nuevo hacia arriba
          await _scrollController2.animateTo(
            0.0,
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
          );
        } else {
          print("ScrollController1 has no positions");
        }
      } else {
        print("ScrollController1 has no clients");
      }

      // Marcar que el desplazamiento automático ha terminado
      _autoScrollInProgress = false;
    } catch (e) {
      print("---Error");
      print(e);
    }
  }

  Future<void> obtenerDireccion(x, y) async {
    //double latitud = widget.latitud ?? 0.0; // Accede a widget.latitud
    //double longitud = widget.longitud ?? 0.0;
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);

    if (placemark.isNotEmpty) {
      Placemark lugar = placemark.first;
      setState(() {
        direccion="${lugar.locality},${lugar.subAdministrativeArea},${lugar.street}";
        creadoUbicacion(x, y, direccion, widget.clienteId, lugar.locality);
      });
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

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final TabController _tabController = TabController(length: 2, vsync: this);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final pedidoProvider = context.watch<PedidoProvider>();
    esVacio(pedidoProvider.pedido);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            key: _scaffoldKey,
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: anchoActual,
                        margin: EdgeInsets.only(
                            top: largoActual * 0.013,
                            left: anchoActual * 0.028,
                            right: anchoActual * 0.028),
                        //color: Colors.red,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //LOCATION
                            Container(
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(83, 176, 68, 1.000),
                                  borderRadius: BorderRadius.circular(40)),
                              height: largoActual * 0.059,
                              width: anchoActual * 0.7,
                              child: DropdownMenu<String>(
                                hintText: '¿Dónde lo entregamos?',
                                trailingIcon: Icon(
                                  Icons.arrow_drop_down,
                                  size: largoActual * 0.031,
                                  color: Colors.white,
                                ),
                                leadingIcon: IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              top: largoActual * 0.041,
                                              left: anchoActual * 0.055,
                                              right: anchoActual * 0.055),
                                          height: largoActual * 0.18,
                                          width: anchoActual,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Agregar Ubicación',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 3, 34, 60),
                                                  fontSize: largoActual * 0.023,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: largoActual * 0.013),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  print("ubi añadidda");
                                                  await currentLocation();
                                                
                                                  Navigator.of(context).pop();
                                                },
                                                style: ButtonStyle(
                                                  minimumSize:
                                                      MaterialStatePropertyAll(
                                                          Size(
                                                              anchoActual *
                                                                  0.28,
                                                              largoActual *
                                                                  0.054)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          const Color.fromRGBO(
                                                              88,
                                                              184,
                                                              249,
                                                              1.000)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_location_alt_rounded,
                                                      color: Colors.white,
                                                      size: largoActual * 0.034,
                                                    ),
                                                    Text(
                                                      ' Agregar ubicación actual',
                                                      style: TextStyle(
                                                          fontSize:
                                                              largoActual *
                                                                  0.024,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.white),
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
                                  icon: Icon(Icons.add_location_alt_rounded,
                                      size: largoActual * 0.031,
                                      color: Colors.white),
                                ),
                                inputDecorationTheme: InputDecorationTheme(
                                    fillColor:
                                        Color.fromRGBO(83, 176, 68, 1.000),
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: largoActual * 0.018,
                                      //fontWeight: FontWeight.w400
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            width: 0, color: Colors.white))),
                                expandedInsets: EdgeInsets.zero,
                                menuStyle: MenuStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 252, 255, 255)),
                                ),
                                initialSelection: listUbicacionesObjetos.first.direccion,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  print("valor");
                                  print(value);
                                  setState(() {
                                    for(var i=0; i<listUbicacionesObjetos.length;i++){
                                      if (listUbicacionesObjetos[i].direccion==value){
                                        listUbicacionesObjetos[i].remove(value);
                                        listUbicacionesObjetos.insert(0, value!);
                                        dropdownValue = value;
                                    }
                                    }
                                    
                                  });
                                },
                                dropdownMenuEntries: List.generate(
                                    listUbicacionesObjetos.length, (index) {
                                  final value = listUbicacionesObjetos[index].direccion;
                                  return DropdownMenuEntry<String>(
                                      value: value,
                                      label: value.length > 20
                                          ? '${value.substring(0, 15)}'
                                          : value);
                                }).toList(),
                              ),
                            ),

                            // USER PHOTO
                            Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(0, 106, 252, 1.000),
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
                                  icon: const Icon(Icons.shopping_cart_rounded),
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
                      Container(
                        width: anchoActual,
                        margin: EdgeInsets.only(
                            left: anchoActual * 0.055,
                            top: largoActual * 0.02),
                        child: Text(
                          "Bienvenid@, ${userProvider.user?.nombre}",
                          style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: largoActual * 0.021,
                              color: const Color.fromARGB(255, 3, 34, 60)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: anchoActual * 0.055),
                        child: Text(
                          "Disfruta de Agua Sol!",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: largoActual * 0.021,
                              color: const Color.fromARGB(255, 3, 34, 60)),
                        ),
                      ),
                      Container(
                        height: largoActual * 0.05,
                        width: anchoActual,
                        margin: EdgeInsets.only(
                            top: largoActual * 0.013,
                           ),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                            controller: _tabController,
                            //indicatorWeight: 10,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color.fromRGBO(120,251,99,0.3),
                            ),
                            labelStyle: TextStyle(
                                fontSize: largoActual * 0.0203,
                                fontWeight: FontWeight
                                    .w400), // Ajusta el tamaño del texto de la pestaña seleccionada
                            unselectedLabelStyle: TextStyle(
                                fontSize: largoActual * 0.020,
                                fontWeight: FontWeight.w300),
                            labelColor: const Color.fromARGB(255, 3, 34, 60),
                            unselectedLabelColor:
                                const Color.fromARGB(255, 3, 34, 60),
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
                      Container(
                        margin: EdgeInsets.only(
                            top: largoActual * 0.013,),
                        height: largoActual / 2.2,
                        width: double.maxFinite,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            ListView.builder(
                                controller: _scrollController1,
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
                                          color:
                                              Color.fromARGB(255, 71, 106, 133),
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                controller: _scrollController2,
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
                                          color:
                                              Color.fromARGB(255, 75, 108, 134),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          image: DecorationImage(
                                            image: NetworkImage(producto.foto),
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: largoActual * 0.02,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: anchoActual * 0.055,
                            right: anchoActual * 0.055),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text(
                                  "Mejora",
                                  style: TextStyle(
                                      fontSize: largoActual * 0.021,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          const Color.fromARGB(255, 3, 34, 60)),
                                )),
                                Container(
                                    child: Text(
                                  "tú vida!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: largoActual * 0.021,
                                      color:
                                          const Color.fromARGB(255, 3, 34, 60)),
                                )),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: largoActual * 0.027),
                              child: Text(
                                "Necesitas",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: largoActual * 0.021,
                                    color:
                                        const Color.fromARGB(255, 6, 46, 78)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: anchoActual * 0.028,
                            right: anchoActual * 0.028),
                        child: Row(children: [
                          Container(
                            //width: 150,
                            height: largoActual * 0.054,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'PRONTO',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 4, 80, 143)),
                                      ),
                                      content: Text(
                                        'Muy pronto te sorprenderemos!',
                                        style: TextStyle(
                                            fontSize: largoActual * 0.027,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Cierra el AlertDialog
                                          },
                                          child: Text(
                                            'OK',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: largoActual * 0.034,
                                                color: const Color.fromARGB(
                                                    255, 13, 58, 94)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(8),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.28, largoActual * 0.054)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .attach_money_outlined, // Reemplaza con el icono que desees
                                    size: largoActual * 0.028,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width: anchoActual *
                                          0.022), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Aquí",
                                    style: TextStyle(
                                        fontSize: largoActual * 0.021,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                          Container(
                            width: anchoActual * 0.55,
                            height: largoActual * 0.054,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Asistencia()),
                                );
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(8),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.28, largoActual * 0.054)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .support_agent_rounded, // Reemplaza con el icono que desees
                                    size: largoActual * 0.028,
                                    color: Colors.white,
                                  ),

                                  SizedBox(
                                      width: anchoActual *
                                          0.022), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Asistencia",
                                    style: TextStyle(
                                        fontSize: largoActual * 0.021,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ]))));
  }
}
