import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:turf_pip/turf_pip.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/models/zona_model.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key});

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiZona = '/zona';
  bool _isloading = false;
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  int? clienteID = 0;
  late String direccion;
  late String? distrito;
  List<Zona> listZonas = [];

  Future<dynamic> getZonas() async {
    var res = await http.get(
      Uri.parse(apiUrl + apiZona),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Zona> tempZona = data.map<Zona>((mapa) {
          return Zona(
            id: mapa['id'],
            nombre: mapa['nombre'],
            poligono: mapa['poligono'],
            departamento: mapa['departamento'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            listZonas = tempZona;
          });
          for (var i = 0; i < tempZona.length; i++) {
            List tempString = tempZona[i].poligono.split(',');
            for (var j = 0; j < tempString.length; j++) {
              print((j / 2).runtimeType);
              if (j / 2 is int) {
                //SI ES PAR
                double x = double.parse(tempString[j]);
                double y = double.parse(tempString[j - 1]);
                setState(() {
                  tempZona[i].puntos.add(Point(x, y));
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  // GET UBICACIÓN
  Future<dynamic> creadoUbicacion(clienteId, distrito) async {
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

  Future<void> obtenerDireccion(x, y) async {
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
        Point puntoUbi = Point(x, y);
        setState(() {
          direccion =
              "${lugar.locality}, ${lugar.subAdministrativeArea}, ${lugar.street}";
          setState(() {
            distrito = lugar.locality;
          });
        });
      } else {
        direccion = "Default";
      }
      print("x-----y");
      print("${x},${y}");
    } catch (e) {
      //throw Exception("Error ${e}");
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Error de Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: Text(
              'Hubo un problema al obtener la ubicación. Por favor, inténtelo de nuevo.',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el AlertDialog
                  setState(() {
                    _isloading = false;
                  });
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        latitudUser = x;
        longitudUser = y;
        _isloading = false;
        creadoUbicacion(clienteID, distrito);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: const Text(
                'Ubicación',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              content: const Text(
                'Gracias por compartir tu ubicación!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el AlertDialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BarraNavegacion(
                                indice: 0,
                                subIndice: 0,
                              )),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 25,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<void> currentLocation() async {
    var location = location_package.Location();
    location_package.PermissionStatus permissionGranted;
    location_package.LocationData locationData;

    setState(() {
      _isloading = true;
    });

    // Verificar si el servicio de ubicación está habilitado
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar habilitación del servicio de ubicación
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Mostrar mensaje al usuario indicando que el servicio de ubicación es necesario
        setState(() {
          _isloading = true;
        });
        return;
      }
    }

    // Verificar si se otorgaron los permisos de ubicación
    permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) {
        // Mostrar mensaje al usuario indicando que los permisos de ubicación son necesarios
        return;
      }
    }

    // Obtener la ubicación
    try {
      locationData = await location.getLocation();

      //updateLocation(locationData);
      await obtenerDireccion(locationData.latitude, locationData.longitude);

      print("----ubicación--");
      print(locationData);
      print("----latitud--");
      print(latitudUser);
      print("----longitud--");
      print(longitudUser);

      // Aquí puedes utilizar la ubicación obtenida (locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    clienteID = userProvider.user?.id;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Colors.white,
          Color.fromRGBO(0, 106, 252, 1.000),
          Color.fromRGBO(0, 106, 252, 1.000),
        ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 80),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Text("Mejora tu experiencia",
                            style: TextStyle(
                                fontSize: largoActual * 0.03,
                                fontWeight: FontWeight.w400,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Text("Déjanos saber tu ubicación",
                            style: TextStyle(
                                fontSize: largoActual * 0.03,
                                fontWeight: FontWeight.w200,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: largoActual * 0.05,
                  ),
                  Container(
                    height: largoActual * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Lottie.asset('lib/imagenes/ubi4.json'),
                  ),
                  SizedBox(
                    height: largoActual * 0.05,
                  ),
                  SizedBox(
                      width: anchoActual * (350 / 500),
                      height: largoActual * (38 / 600),
                      child: ElevatedButton(
                        onPressed: () {
                          currentLocation();
                        },
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            minimumSize: MaterialStatePropertyAll(Size(
                                anchoActual * (350 / 500),
                                largoActual * (38 / 600))),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255))),
                        child: _isloading
                            ? const CircularProgressIndicator(
                                color: Color.fromRGBO(0, 106, 252, 1.000),
                                strokeWidth: 3,
                              )
                            : const Text(
                                "Aquí",
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 106, 252, 1.000),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500),
                              ),
                      )),
                ]),
          ),
        ),
      ),
    );
  }
}
