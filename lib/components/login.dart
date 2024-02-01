import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/holaconductor.dart';
import 'package:appsol_final/components/prueba.dart';
import 'package:appsol_final/modeluser/user_model.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

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
              codigocliente: data['usuario']['codigocliente']  ?? 'NoCode',
              suscripcion:data['usuario']['suscripcion'] ?? 'NoSubscribe');
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
              apellidos: data['usuario']['apellidos']
            );

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

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 234, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO SOL
              Container(
                //color: Colors.amber,
                margin: const EdgeInsets.only(top: 30, left: 20),
                height: MediaQuery.of(context).size.height / 8,
                width: MediaQuery.of(context).size.width / 2.25,
                child: Opacity(
                    opacity: 1,
                    child: Image.asset('lib/imagenes/logo_sol_tiny.png')),
              ),

              const SizedBox(
                height: 20,
              ),

              // FRASES DE SOL
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: const Text(
                  "Llevando vida a tu hogar !",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: const Text(
                  "Conoce la mejor agua del Sur.",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              // FORMULARIO

              Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

              Container(
                margin: const EdgeInsets.only(left: 20),
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

                          if (rol == 4) {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Hola()),
                            );
                          } else if (rol == 5) {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HolaConductor()),
                            );
                          } else if (rol == 3) {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Prueba()),
                            );
                          }
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
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 1, 61, 109)),
                  ),
                  child: const Text(
                    "Bienvenido",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(left: 20),
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
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 1, 61, 109))),
                  child: const Text(
                    "Registrar",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 200,
                //color:Colors.red,
                margin: const EdgeInsets.only(left: 20),
                child: const Center(child: Text("o continua con:")),
              ),
              const SizedBox(
                height: 3,
              ),
              Container(
                //color:Colors.red,
                margin: const EdgeInsets.only(left: 20, right: 20),
                width: 200,
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
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Center(
                  child: Container(
                    //color: Colors.red,
                    height: MediaQuery.of(context).size.height / 2.5,
                    width: MediaQuery.of(context).size.width,
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                            image: AssetImage('lib/imagenes/parejitajoven.jpg'),
                            fit: BoxFit.fill)),
                    // padding: EdgeInsets.all(20),
                    // child: Image.asset('lib/imagenes/BIDON7.png'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //),
    );
  }
}
