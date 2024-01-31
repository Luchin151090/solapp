/*
import 'package:http/http.dart' as http;
import 'package:app_final/components/test/holaconductor.dart';
import 'package:app_final/main.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';

class Camara extends StatefulWidget {
  final int pedidoID;
  final String problemasOpago;
  const Camara({
    Key? key,
    required this.pedidoID,
    required this.problemasOpago,
  }) : super(key: key);

  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {
  //late List<CameraDescription> camera;
  late CameraController cameraController;
  String apiPedidosConductor =
      'https://aguasolfinal-dev-bbhx.1.us-1.fl0.io/api/pedido_conductor/';
  /*'http://10.0.2.2:8004/api/pedido_conductor/';*/
  String comentario = '';
  String estadoNuevo = '';

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

  void esProblemaOesPago() {
    if (widget.problemasOpago == 'pago') {
      setState(() {
        comentario = 'Comentarios';
        estadoNuevo = 'entregado';
      });
    } else {
      setState(() {
        comentario = 'Detalla los inconvenientes';
        estadoNuevo = 'truncado';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    esProblemaOesPago();
    cameraController = CameraController(camera[0], ResolutionPreset.medium,
        enableAudio: false);

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double anchoPantalla = MediaQuery.of(context).size.width;

    if (cameraController.value.isInitialized) {
      return Scaffold(
          body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20, left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Una foto",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Text(
                                      "te ayuda ",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                    Text(
                                      "con tus registros",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 20),
                                  child: Image.asset('lib/imagenes/fotore.png'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 0, right: 0),
                            height: 400,
                            width: MediaQuery.of(context).size.width <= 480
                                ? 430
                                : 300,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 134, 129, 129),
                                borderRadius: BorderRadius.circular(20)),
                            // width: 300,
                            child: CameraPreview(cameraController),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 10, left: 50, right: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color.fromARGB(
                                                  255, 2, 46, 83))),
                                ),
                                Container(
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 2, 46, 83))),
                                    child: const Icon(
                                      Icons.photo_camera,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color.fromARGB(
                                                  255, 2, 46, 83))),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              child: SingleChildScrollView(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: TextField(
                                      decoration:
                                          InputDecoration(hintText: comentario),
                                    ),
                                  )
                                ]),
                          )),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            width: anchoPantalla - 40,
                            //color:Colors.grey,
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: (anchoPantalla - 80) / 2,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          //REGRESA A LA MISMA VISTA Y NO CAMBIA NADA
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HolaConductor()),
                                        );
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 2, 46, 83))),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .arrow_back, // Reemplaza con el icono que desees
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Regresar",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white),
                                          )
                                        ],
                                      )),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  height: 40,
                                  width: (anchoPantalla - 80) / 2,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        updateEstadoPedido(
                                            estadoNuevo, null, widget.pedidoID);
                                        Navigator.push(
                                          context,
                                          //REGRESA A LA VISTA DE HOME PERO ACTUALIZA EL PEDIDO
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HolaConductor()),
                                        );
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
                                                      255, 2, 46, 83))),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Listo",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons
                                                .arrow_forward, // Reemplaza con el icono que desees
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ))));
    } else {
      return Scaffold(
        body: Container(
          child: Center(
            child: Text(
              "... Detectando Cámara",
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      );
    }
  }
}

 */