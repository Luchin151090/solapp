import 'package:appsol_final/components/asistencia.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';

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

class Hola extends StatefulWidget {
  final String? url;
  final String? LoggedInWith;
  final String direccion;
  //final double? latitud;
  // final double? longitud;

  const Hola({
    this.url,
    this.LoggedInWith,
    this.direccion = '',
    // this.latitud, // Nuevo campo
    // this.longitud, // Nuevo campo
    Key? key,
  }) : super(key: key);

  @override
  State<Hola> createState() => _HolaState();
}

class _HolaState extends State<Hola> with TickerProviderStateMixin {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  List<Producto> listProducto = [];
  late List<String> listUbicaciones = [];
  late String dropdownValue = listUbicaciones.first;

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  @override
  void initState() {
    super.initState();
    getProducts();
    listUbicaciones.add(widget.direccion);
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

  Future<dynamic> getProducts() async {
    print("1) get products---------");
    var res = await http.get(
      Uri.parse(apiUrl + '/api/products'),
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
        listUbicaciones.add(
            "${lugar.locality},${lugar.subAdministrativeArea},${lugar.street}");
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

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final TabController _tabController = TabController(length: 2, vsync: this);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Color.fromRGBO(47, 76, 245, 1.000),
          items: [
            Icon(Icons.home_rounded),
            Icon(Icons.shopping_cart_rounded),
            Icon(Icons.person)
          ],
        ),
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 9, 133, 235),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Cuenta'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Soporte'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                height: 200,
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/loginsol');
                  },
                  child: const Text(
                    "Salir",
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        margin:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        //color:Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // MENU
                            Container(
                              //margin: EdgeInsets.only(right: ),
                              child: IconButton(
                                  onPressed: () {
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                  icon: const Icon(
                                    Icons.menu,
                                    size: 25,
                                  )),
                            ),

                            // LOCATION
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /*const Text(
                                    "¿Donde lo entregamos?",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color.fromARGB(255, 7, 135, 50)),
                                  ),*/
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      /*Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            color: Colors.green),
                                        child: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: 150,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Agregar Ubicación',
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 3, 64, 113),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      const SizedBox(
                                                          height: 10),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          print("ubi añadidda");
                                                          await currentLocation();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .add_location_alt_outlined,
                                                              color:
                                                                  Colors.blue,
                                                              size: 25,
                                                            ),
                                                            Text(
                                                              ' Agregar ubicación actual ?',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          47,
                                                                          90,
                                                                          48)),
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
                                          icon: const Icon(
                                              Icons.add_location_alt_outlined,
                                              size: 23,
                                              color: Colors.white),
                                        ),
                                      ),*/
                                      DropdownMenu<String>(
                                        trailingIcon: IconButton(
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: 150,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Agregar Ubicación',
                                                        style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 3, 64, 113),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      const SizedBox(
                                                          height: 10),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          print("ubi añadidda");
                                                          await currentLocation();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .add_location_alt_outlined,
                                                              color:
                                                                  Colors.blue,
                                                              size: 25,
                                                            ),
                                                            Text(
                                                              '¿Agregar ubicación actual?',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          47,
                                                                          90,
                                                                          48)),
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
                                          icon: const Icon(
                                              Icons.add_location_alt_outlined,
                                              size: 23,
                                              color: Colors.green),
                                        ),
                                        hintText: "¿Donde lo entregamos?",
                                        menuHeight: 300,
                                        menuStyle: MenuStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 197, 251, 0)),
                                        ),
                                        initialSelection: listUbicaciones.first,
                                        onSelected: (String? value) {
                                          // This is called when the user selects an item.
                                          print("valor");
                                          print(value);
                                          setState(() {
                                            if (listUbicaciones
                                                .contains(value)) {
                                              listUbicaciones.remove(value);
                                              listUbicaciones.insert(0, value!);
                                              dropdownValue = value;
                                            }
                                          });
                                        },
                                        dropdownMenuEntries: List.generate(
                                            listUbicaciones.length, (index) {
                                          final value = listUbicaciones[index];
                                          return DropdownMenuEntry<String>(
                                              value: value,
                                              label: value.length > 20
                                                  ? '${value.substring(0, 15)}'
                                                  : value);
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // USER PHOTO
                            Container(
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 84, 81, 81),
                                  borderRadius: BorderRadius.circular(40)),
                              height: 50,
                              // width: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: widget.url != null
                                    ? Image.network(widget.url!)
                                    : Image.asset('lib/imagenes/chica.jpg'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 20),
                        child: Text(
                          "Hola, ${userProvider.user?.nombre} \nBienvenid@ a",
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 18,
                              color: Color.fromARGB(255, 3, 34, 60)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 20),
                        // color: Colors.grey,
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Disfruta de Agua Sol!",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 3, 34, 60)),
                            ),
                            Container(
                                height: 50,
                                child: Lottie.asset('lib/imagenes/vasito.json'))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        //color:Colors.red,
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 20),
                        child: TabBar(
                            controller: _tabController,
                            indicatorWeight: 10,
                            labelStyle: const TextStyle(
                                fontSize:
                                    20), // Ajusta el tamaño del texto de la pestaña seleccionada
                            unselectedLabelStyle: const TextStyle(fontSize: 16),
                            labelColor: const Color.fromARGB(255, 0, 52, 95),
                            unselectedLabelColor:
                                const Color.fromARGB(255, 46, 43, 43),
                            indicatorColor:
                                const Color.fromARGB(255, 21, 168, 14),
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
                        margin: const EdgeInsets.only(top: 20, left: 20),
                        height: MediaQuery.of(context).size.height / 3.5,
                        // color:Colors.grey,

                        //
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
                                      Navigator.pushNamed(context, '/promos');
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      height: 300,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 71, 106, 133),
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                      Navigator.pushNamed(
                                          context, '/productos');
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      height: 300,
                                      width: 300,
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
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 80,
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        //color: Colors.grey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(right: 90),
                                    child: const Text(
                                      "Mejora!",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color:
                                              Color.fromARGB(255, 2, 46, 83)),
                                    )),
                                Container(
                                    margin: const EdgeInsets.only(right: 80),
                                    //color:Colors.grey,
                                    child: const Text(
                                      "Tú vida",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color:
                                              Color.fromARGB(255, 3, 31, 54)),
                                    )),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              // color:Colors.amber,
                              child: const Text(
                                "Necesitas",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 6, 46, 78)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(children: [
                          Container(
                            //width: 150,
                            height: 50,
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
                                      content: const Text(
                                        'Muy pronto te sorprenderemos!',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Cierra el AlertDialog
                                          },
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                                color: Color.fromARGB(
                                                    255, 13, 58, 94)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 0, 59, 108)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .attach_money_outlined, // Reemplaza con el icono que desees
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    " Aquí ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: Container()),
                          Container(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Asistencia()),
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromARGB(255, 0, 59, 108)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .face, // Reemplaza con el icono que desees
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "¿ Asistencia ?",
                                    style: TextStyle(
                                        fontSize: 15,
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
