/*
import 'package:app_final/components/test/hola.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key});

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  bool _isloading = false;
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  String apiCliente = '';
  late String direccion;

  // GET UBICACIÓN
  Future<void> currentLocation() async {
    var location = location_package.Location();

    // bool _serviceEnabled;
    location_package.PermissionStatus _permissionGranted;
    location_package.LocationData _locationData;

    setState(() {
      _isloading = true;
    });
    // Verificar si el servicio de ubicación está habilitado
    var _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      // Solicitar habilitación del servicio de ubicación
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Mostrar mensaje al usuario indicando que el servicio de ubicación es necesario
        setState(() {
          _isloading = true;
        });
        return;
      }
    }

    // Verificar si se otorgaron los permisos de ubicación
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == location_package.PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != location_package.PermissionStatus.granted) {
        // Mostrar mensaje al usuario indicando que los permisos de ubicación son necesarios
        return;
      }
    }

    // Obtener la ubicación
    try {
      _locationData = await location.getLocation();
      //updateLocation(_locationData);
      await obtenerDireccion(_locationData.latitude, _locationData.longitude);
      // setState(() {
      /// latitudUser = _locationData.latitude;
      // longitudUser = _locationData.longitude;

      //});

      print("----ubicación--");
      print(_locationData);
      print(latitudUser);
      print(longitudUser);
      // Aquí puedes utilizar la ubicación obtenida (_locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
    }
  }

  Future<void> obtenerDireccion(x, y) async {
    //double latitud = widget.latitud ?? 0.0; // Accede a widget.latitud
    //double longitud = widget.longitud ?? 0.0;
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
        setState(() {
          direccion =
              "${lugar.locality},${lugar.subAdministrativeArea},${lugar.street}";
        });

        //  return '${lugar.locality},${lugar.subAdministrativeArea},${lugar.street}';
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
        _isloading = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Ubicación',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 4, 80, 143)),
              ),
              content: const Text(
                'Gracias por compartir tu ubicación!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el AlertDialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Hola(direccion: direccion)),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Color.fromARGB(255, 13, 58, 94)),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              //width: 200,
              margin: const EdgeInsets.only(top: 80, right: 20),
              // color: Colors.red,
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  const Text("Mejora!",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            const SizedBox(
              height: 0,
            ),
            Container(
              //width: 200,
              margin: const EdgeInsets.only(right: 20),
              //color: Colors.red,
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  const Text("Tú experiencia de entrega",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w300)),
                ],
              ),
            ),
            Container(
              //width: 200,
              margin: const EdgeInsets.only(right: 20),
              //color: Colors.red,
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  const Text("Déjanos saber tu ubicación",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w200)),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
                width: 150,
                height: 60,
                margin: const EdgeInsets.only(right: 20),
                //color: Colors.red,
                child: ElevatedButton(
                  onPressed: () {
                    currentLocation();
                  },
                  child: _isloading
                      ? CircularProgressIndicator()
                      : const Text(
                          ">> Aquí",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w400),
                        ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 1, 59, 107))),
                )),
            //Expanded(child: Container()),
            const SizedBox(
              height: 80,
            ),
            Container(
              child: Opacity(
                  opacity: 0.9,
                  child: Image.asset('lib/imagenes/ubicacion.jpg')),
            ),
          ]),
        ),
      ),
    );
  }
}

*/