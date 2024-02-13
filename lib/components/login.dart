import 'package:appsol_final/components/holaconductor.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/prueba.dart';
import 'package:appsol_final/components/ubicacion.dart';
import 'package:appsol_final/models/user_model.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  double opacity = 0.0;
  String apiLogin = '/api/login';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _contrasena = TextEditingController();
  late int status = 0;
  late int rol = 0;
  late UserModel userData;
  bool yaTieneUbicaciones = false;

  @override
  void initState() {
    super.initState();
    //getUsers();
    // Iniciar la animación de la opacidad después de 500 milisegundos
    Timer(Duration(milliseconds: 900), () {
      setState(() {
        opacity = 1;
      });
    });
  }

  Future<dynamic> loginsol(username, password) async {
    try {
      print("------loginsool");
      print(username);

      var res = await http.post(Uri.parse(apiUrl + apiLogin),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"nickname": username, "contrasena": password}));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);

        // CLIENTE

        if (data['usuario']['rol_id'] == 4) {
          print("cli");

          // data['usuario']['nombre']
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombre'],
              apellidos: data['usuario']['apellidos'],
              codigocliente: data['usuario']['codigocliente'] ?? 'NoCode',
              suscripcion: data['usuario']['suscripcion'] ?? 'NoSubscribe');
          setState(() {
            status = 200;
            rol = 4;
          });
        }
        //CONDUCTOR
        else if (data['usuario']['rol_id'] == 5) {
          print("conductor");
          userData = UserModel(
            id: data['usuario']['id'],
            nombre: data['usuario']['nombres'],
            apellidos: data['usuario']['apellidos'],
          );

          setState(() {
            status = 200;
            rol = 5;
          });
        }
        // GERENTE
        else if (data['usuario']['rol_id'] == 3) {
          print("gerente");
          userData = UserModel(
              id: data['usuario']['id'],
              nombre: data['usuario']['nombre'],
              apellidos: data['usuario']['apellidos']);

          setState(() {
            status = 200;
            rol = 3;
          });
        }

        // ACTUALIZAMOS EL ESTADO DEL PROVIDER, PARA QUE SE PUEDA USAR DE MANERA GLOBAL
        Provider.of<UserProvider>(context, listen: false).updateUser(userData);
      } else if (res.statusCode == 401) {
        var data400 = json.decode(res.body);
        print("data400");
        print(data400);
        setState(() {
          status = 401;
        });
      } else if (res.statusCode == 404) {
        var data404 = json.decode(res.body);
        print("data 404");
        print(data404);
        setState(() {
          status = 404;
        });
      } else {
        throw Exception("Codigo de estado desconocido ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Excepcion $e");
    }
  }

  Future<dynamic> tieneUbicaciones(clienteID) async {
    print("-------get ubicaciones---------");
    print("$apiUrl/api/ubicacion/$clienteID");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("-------entro al try de get ubicaciones---------");
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
        setState(() {
          if (tempUbicacion.isEmpty) {
            print("${tempUbicacion.length}");
            //NOT TIENE UBIS
            yaTieneUbicaciones = false;
          } else {
            //SI TIENE UBISSS
            yaTieneUbicaciones = true;
          }
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;

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
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LOGO SOL
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 30, left: 20),
                    height: MediaQuery.of(context).size.height / 8,
                    width: MediaQuery.of(context).size.width / 2.25,
                    child: Opacity(
                        opacity: 1,
                        child: Image.asset(
                            'lib/imagenes/logo_aguasol_blanco.png')),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 20,
                ),
                // FORMULARIO
                Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              controller: _usuario,
                              decoration: const InputDecoration(
                                hintText: 'Usuario',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese su usuario';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextFormField(
                              controller: _contrasena,
                              decoration: const InputDecoration(
                                hintText: 'Contraseña',
                                border: InputBorder.none,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese su contraseña';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    width: 500,
                    margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        print(largoActual);
                        print(anchoActual);
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(
                                      backgroundColor: Colors.green,
                                    ),
                                    SizedBox(width: 20),
                                    Text("Cargando..."),
                                  ],
                                ),
                              );
                            },
                          );
                          try {
                            await loginsol(_usuario.text, _contrasena.text);

                            if (status == 200) {
                              Navigator.of(context)
                                  .pop(); // Cerrar el primer AlertDialog

                              //SI ES CLIENTE
                              if (rol == 4) {
                                await tieneUbicaciones(userData.id);
                                //SI YA TIENE UBICACIONES INGRESA DIRECTAMENTE A LA BARRA DE AVEGACION
                                if (yaTieneUbicaciones == true) {
                                  print("YA tiene unibicaciones");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BarraNavegacion(
                                                indice: 0, subIndice: 0)),
                                  );
                                  //SI NO TIENE UBICACIONES INGRESA A UBICACION
                                } else {
                                  print("NO tiene unibicaciones");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Ubicacion()),
                                  );
                                }

                                //SI ES CONDUCTOR
                              } else if (rol == 5) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HolaConductor()),
                                );

                                //SI ES GERENTE
                              } else if (rol == 3) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Prueba()),
                                );
                              }
                              //SI NO ESTA REGISTRADO
                            } else if (status == 401) {
                              Navigator.of(context)
                                  .pop(); // Cerrar el primer AlertDialog

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    content: Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text("Credenciales inválidas"),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else if (status == 404) {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    content: Row(
                                      children: [
                                        SizedBox(width: 20),
                                        Text("Usuario no existente"),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            print("Excepción durante el inicio de sesión: $e");
                          }
                        }
                      },
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(8),
                        surfaceTintColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      child: const Text(
                        "Ingresa",
                        style: TextStyle(
                          color: Color.fromRGBO(0, 106, 252, 1.000),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Container(
                    width: 800,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        print(largoActual);
                        print(anchoActual);

                        /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Formu()),
                            );*/
                      },
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(8),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(0, 106, 252, 1.000))),
                      child: const Text(
                        "Regístrate",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: const Center(
                      child: Text(
                    "o continua con:",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )),
                ),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          // Resto de tu código...
                          /*  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Hola(
                                            url: user.photoURL,
                                            LoggedInWith: LoggedInWith)));*/
                        },
                        child: Image.asset(
                          'lib/imagenes/google.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          print("google");
                          /*  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Hola(
                                            url: user.photoURL,
                                            LoggedInWith: LoggedInWith)));*/

                          print("ooog");
                        },
                        child: Image.asset(
                          'lib/imagenes/facebook.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
