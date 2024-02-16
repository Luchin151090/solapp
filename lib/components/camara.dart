import 'dart:io';
import 'package:appsol_final/components/holaconductor2.dart';
import 'package:http/http.dart' as http;
import 'package:appsol_final/components/holaconductor.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Camara extends StatefulWidget {
  final int? pedidoID;
  final String? problemasOpago;
  const Camara({
    Key? key,
    this.pedidoID,
    this.problemasOpago,
  }) : super(key: key);

  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {
  //late List<CameraDescription> camera;
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
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

  Future<List<CameraDescription>> funcion() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras;
  }

  @override
  void initState() {
    startCamera();
    super.initState();
    esProblemaOesPago();
  }

  bool _cameraInitialized = false;

  void startCamera() async {
    print("somaaa");
    cameras = await availableCameras();

    cameraController = CameraController(cameras[0], ResolutionPreset.high);

    print(" Camera controller : $cameraController");

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraInitialized =
            true; // updating the flag after camera is initialized
      }); //To refresh widget
    }).catchError((e) {
      print(e);
    });
  }

  void deletePhoto(String? fileName) async {
    try {
      // Obtener el directorio de caché
      Directory cacheDir = await getTemporaryDirectory();

      // Combinar el directorio con el nombre del archivo
      String filePath = '${cacheDir.path}/$fileName';

      // Crear un objeto File para el archivo que deseas eliminar
      File file = File(filePath);

      // Verificar si el archivo existe antes de intentar eliminarlo
      if (await file.exists()) {
        // Eliminar el archivo
        await file.delete();
        print('Foto eliminada con éxito: $filePath');
      } else {
        print('El archivo no existe: $filePath');
      }
    } catch (e) {
      print('Error al eliminar la foto: $e');
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  late XFile? _image;
  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    if (_cameraInitialized && cameraController.value.isInitialized) {
      return Scaffold(
          body: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            //CAAMARA
                            Container(
                              height: largoActual,
                              width: MediaQuery.of(context).size.width <= 480
                                  ? 430
                                  : 300,
                              padding: const EdgeInsets.all(10),
                              child: CameraPreview(cameraController),
                            ),
                            //BOTON DE REGRESO
                            Positioned(
                              top: anchoActual *
                                  0.09, // Ajusta la posición vertical según tus necesidades
                              left: anchoActual *
                                  0.05, // Ajusta la posición horizontal según tus necesidades
                              child: SizedBox(
                                height: anchoActual * 0.12,
                                width: anchoActual * 0.12,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HolaConductor2()),
                                    );
                                  },
                                  child: const Icon(Icons.arrow_back,
                                      color:
                                          Color.fromARGB(255, 119, 119, 119)),
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(8),
                                    fixedSize: MaterialStatePropertyAll(Size(
                                        anchoActual * 0.14,
                                        largoActual * 0.14)),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromRGBO(230, 230, 230, 1)),
                                    surfaceTintColor: MaterialStateProperty.all(
                                        const Color.fromRGBO(230, 230, 230, 1)),
                                  ),
                                ),
                              ),
                            ),

                            //BOTONES DE TOMAR FOTO ACEPTAR Y DESCARTAR
                            Positioned(
                              bottom: largoActual * 0.02,
                              child: SizedBox(
                                width: anchoActual,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //BOTON DE ELIMINAR FOTO
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          deletePhoto(_image?.name);
                                        } catch (e) {
                                          print(
                                              'Error al eliminar la foto: $e');
                                        }
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromRGBO(
                                                      0, 106, 252, 1.000))),
                                    ),
                                    //BOTON DE TOMAR FOTO
                                    FloatingActionButton(
                                      onPressed: () async {
                                        try {
                                          final pass =
                                              await getApplicationDocumentsDirectory();
                                          final otro =
                                              path.join(pass.path, 'pictures');
                                          final picturesDirectory =
                                              Directory(otro);

                                          if (!await picturesDirectory
                                              .exists()) {
                                            await picturesDirectory.create(
                                                recursive: true);
                                            print('Directorio creado: $otro');
                                          } else {
                                            print(
                                                'El directorio ya existe: $otro');
                                          }
                                          _image = await cameraController
                                              .takePicture();
                                          print("path: ${_image?.path}");
                                        } catch (e) {
                                          print('Error al tomar la foto: $e');
                                        }
                                      },
                                      backgroundColor:
                                          Color.fromRGBO(0, 106, 252, 1.000),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    ),
                                    //BOTON DE ACEPTAR FOTO
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          print('nombre: ${_image?.name}');
                                          final Directory appDirectory =
                                              await getApplicationDocumentsDirectory();
                                          final String pictureDirectory =
                                              path.join(appDirectory.path,
                                                  'pictures');
                                          final String timestamp =
                                              DateTime.now().toString();
                                          final String fileName =
                                              '$timestamp.jpg';
                                          String filePath =
                                              '$pictureDirectory/$fileName';
                                          _image?.saveTo(filePath);
                                          print(
                                              'nuevo path y nombre: $filePath');
                                          // Ruta del directorio que quieres iterar
                                          String directorio =
                                              '/data/user/0/com.example.appsol_final/app_flutter/pictures/';
                                          // Crear un objeto Directory con la ruta del directorio
                                          Directory dir = Directory(directorio);
                                          // Verificar si el directorio existe
                                          // Listar los elementos en el directorio
                                          List<FileSystemEntity> elementos =
                                              dir.listSync();
                                          // Iterar sobre los elementos e imprimir los paths
                                          for (var elemento in elementos) {
                                            print(elemento.path);
                                          }
                                          deletePhoto(_image?.name);

                                          // ignore: use_build_context_synchronously
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (contex) {
                                                return Container(
                                                  height: largoActual * 0.2,
                                                  margin: EdgeInsets.only(
                                                      left: anchoActual * 0.08,
                                                      right: anchoActual * 0.08,
                                                      top: largoActual * 0.05,
                                                      bottom:
                                                          largoActual * 0.05),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                          child:
                                                              SingleChildScrollView(
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                child:
                                                                    TextField(
                                                                  decoration:
                                                                      InputDecoration(
                                                                          hintText:
                                                                              comentario),
                                                                ),
                                                              )
                                                            ]),
                                                      )),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            left: 20,
                                                            right: 20),
                                                        width: anchoActual - 40,
                                                        //color:Colors.grey,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              height: 40,
                                                              width:
                                                                  (anchoActual -
                                                                          80) /
                                                                      2,
                                                              child:
                                                                  ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        updateEstadoPedido(
                                                                            estadoNuevo,
                                                                            null,
                                                                            widget.pedidoID);
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          //REGRESA A LA VISTA DE HOME PERO ACTUALIZA EL PEDIDO
                                                                          MaterialPageRoute(
                                                                              builder: (context) => HolaConductor()),
                                                                        );
                                                                      },
                                                                      style: ButtonStyle(
                                                                          backgroundColor: MaterialStateProperty.all(const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              2,
                                                                              46,
                                                                              83))),
                                                                      child:
                                                                          const Row(
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
                                                                          SizedBox(
                                                                              width: 8),
                                                                          Icon(
                                                                            Icons.arrow_forward, // Reemplaza con el icono que desees
                                                                            size:
                                                                                24,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ],
                                                                      )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                        } catch (e) {
                                          print('Algun error: $e');
                                        }
                                      },
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromRGBO(
                                                      0, 106, 252, 1.000))),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]))));
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
