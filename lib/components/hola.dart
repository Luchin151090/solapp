import 'package:appsol_final/components/asistencia.dart';
import 'package:appsol_final/components/promos.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:appsol_final/components/productos.dart';
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

class Hola2 extends StatefulWidget {
  final String? url;
  final String? LoggedInWith;
  final String direccion;
  //final double? latitud;
  // final double? longitud;

  const Hola2({
    this.url,
    this.LoggedInWith,
    this.direccion = '',
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
    print("-------get products---------");
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
        backgroundColor: Colors.white,
        body: SafeArea(
            key: _scaffoldKey,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //color: Colors.amberAccent,
                        width: MediaQuery.of(context).size.width,
                        margin:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        //color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            //LOCATION
                            Container(
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(83, 176, 68, 1.000),
                                  borderRadius: BorderRadius.circular(40)),
                              height: 45,
                              width: 251,
                              child: DropdownMenu<String>(
                                hintText: '¿Dónde lo entregamos?',
                                trailingIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 23,
                                  color: Colors.white,
                                ),
                                leadingIcon: IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              top: 30, left: 20, right: 20),
                                          height: 130,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Agregar Ubicación',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 3, 34, 60),
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  print("ubi añadidda");
                                                  await currentLocation();
                                                  Navigator.of(context).pop();
                                                },
                                                style: ButtonStyle(
                                                  minimumSize:
                                                      const MaterialStatePropertyAll(
                                                          Size(100, 40)),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color.fromRGBO(88,
                                                              184, 249, 1.000)),
                                                ),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .add_location_alt_rounded,
                                                      color: Colors.white,
                                                      size: 25,
                                                    ),
                                                    Text(
                                                      ' Agregar ubicación actual',
                                                      style: TextStyle(
                                                          fontSize: 18,
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
                                  icon: const Icon(
                                      Icons.add_location_alt_rounded,
                                      size: 23,
                                      color: Colors.white),
                                ),
                                inputDecorationTheme: InputDecorationTheme(
                                    fillColor:
                                        Color.fromRGBO(83, 176, 68, 1.000),
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
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
                                initialSelection: listUbicaciones.first,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  print("valor");
                                  print(value);
                                  setState(() {
                                    if (listUbicaciones.contains(value)) {
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
                            ),

                            // USER PHOTO
                            Container(
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 84, 81, 81),
                                  borderRadius: BorderRadius.circular(40)),
                              height: 50,
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(left: 20, top: 30),
                        child: Text(
                          "Bienvenid@, ${userProvider.user?.nombre}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: 18,
                              color: Color.fromARGB(255, 3, 34, 60)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text(
                          "Disfruta de Agua Sol!",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color.fromARGB(255, 3, 34, 60)),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TabBar(
                            controller: _tabController,
                            indicatorWeight: 10,
                            labelStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight
                                    .w400), // Ajusta el tamaño del texto de la pestaña seleccionada
                            unselectedLabelStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w300),
                            labelColor: Color.fromARGB(255, 3, 34, 60),
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
                        margin:
                            const EdgeInsets.only(top: 10, left: 10, right: 10),
                        height: MediaQuery.of(context).size.height / 2.5,
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
                                                const Promos()),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      height: 300,
                                      width: 300,
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
                                            builder: (context) => Productos()),
                                      );
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
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: const Text(
                                  "Mejora",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromARGB(255, 3, 34, 60)),
                                )),
                                Container(
                                    child: const Text(
                                  "tú vida!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 17,
                                      color: Color.fromARGB(255, 3, 34, 60)),
                                )),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const Text(
                                "Necesitas",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 6, 46, 78)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(children: [
                          Container(
                            //width: 150,
                            height: 40,
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
                                elevation: MaterialStateProperty.all(8),
                                minimumSize: const MaterialStatePropertyAll(
                                    Size(100, 40)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .attach_money_outlined, // Reemplaza con el icono que desees
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Aquí",
                                    style: TextStyle(
                                        fontSize: 16,
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
                            height: 40,
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
                                minimumSize: const MaterialStatePropertyAll(
                                    Size(100, 40)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Icon(
                                        Icons
                                            .person, // Reemplaza con el icono que desees
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                      Icon(
                                        Icons
                                            .question_mark_rounded, // Reemplaza con el icono que desees
                                        size: 12,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),

                                  SizedBox(
                                      width:
                                          8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Asistencia",
                                    style: TextStyle(
                                        fontSize: 16,
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
