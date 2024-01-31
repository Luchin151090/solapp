// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
//import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/*class Usuario {
  final int id;
	final int rol_id;
	final String nickname;
	final String contrasena;
	String? email;
	final String nombres;// varchar(100) not null,
	final String apellidos;// varchar(200) not null,
	final String dni;// varchar(200) no,
	String fecha_nacimiento;// date not null,
	String? licencia;// varchar (100),
	String? frecuencia;// int,
	String? sexo;// varchar(100),
	String? direccion;// varchar(150),
	String? telefono;// varchar(50),
	String? codigo;// varchar(200),
	double? saldo_beneficios;// int,
	String? direccion_empresa;// varchar(200),
	String? suscripcion;// varchar(200),
	String? ubicacion; //varchar(200), --GEOMETRY
	String? ruc;// varchar(200),
	String? nombre_empresa;// varchar(200),
	String? zona_trabajo_id;//int


   Usuario(
      {required this.id,
      required this.nombres,
      required this.apellidos,
      required this.dni,
      this.codigo,
      required this.nickname,
      required this.contrasena,
      this.direccion,
      this.direccion_empresa,
      required this.fecha_nacimiento,
      this.email,
      this.frecuencia,
      this.licencia,
      this.nombre_empresa,
      required this.rol_id,
      this.ruc,
      this.saldo_beneficios,
      this.sexo,
      this.suscripcion,
      this.telefono,
      this.ubicacion,
      this.zona_trabajo_id
});
}*/

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
  late SharedPreferences cliente;
  late SharedPreferences conductor;
  late SharedPreferences gerente;
  late int status = 0;
  late int rol = 0;

  //List<Usuario>usuarios= [];

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
/*
  String? LoggedInWith;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;*/

  /* Future<dynamic>getUsers()async{
    var res = await http.get(
      Uri.parse(apiUsers),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Usuario> tempUsuario = data.map<Usuario>((mapa) {
          return Usuario(
              id: mapa['id'],
              nombres: mapa['nombres'],
              apellidos: mapa['apellidos'],
              licencia: mapa['licencia'],
              dni: mapa['dni'],
              fecha_nacimiento: mapa['fecha_nacimiento'],
              nickname: mapa['nickname'],
              contrasena: mapa['contrasena'],
              email: mapa['email'],
              rol_id: mapa['rol_id'],
              codigo: mapa['codigo'],
              direccion: mapa['direccion'],
              direccion_empresa: mapa['direccion_empresa'],
              nombre_empresa: mapa['nombre_empresa'],
              ruc: mapa['ruc'],
              sexo: mapa['sexo'],
              saldo_beneficios:mapa['saldo_beneficios'],
              suscripcion: mapa['mapa'],
              telefono: mapa['telefono'],
              ubicacion: mapa['ubicacion'],
              frecuencia: mapa['frecuencia'],
              zona_trabajo_id: mapa['zona_trabajo_id']
              
              
          );
        }).toList();

        setState(() {
          usuarios = tempUsuario;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }*/

  /* Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      LoggedInWith = "google";
      return user;
    } catch (e) {
      print('Error during Google sign-in: $e');
      return null;
    }
  }*/

  /* Future<dynamic> signInWithFacebook() async {
    // Inicia sesión con Facebook
    try {
      print("tengo hambre chamo");
      final LoginResult result = await FacebookAuth.instance.login();
      print("no he desayunado");
      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        final AuthCredential credential =
            FacebookAuthProvider.credential(accessToken!.token);

        // Autentica con Firebase
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;
        LoggedInWith = "face";
        return user;
      }
    } catch (e) {
      print("aca?");
      print(e.toString());
      // Manejar el error
    }
    return null;
  }*/
  Future<dynamic> loginsol(username, password) async {
    try {
      print("------loginsool");
      print(username);
      cliente = await SharedPreferences.getInstance();
      conductor = await SharedPreferences.getInstance();
      gerente = await SharedPreferences.getInstance();
      var res = await http.post(Uri.parse(apiUrl + apiLogin),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({"nickname": username, "contrasena": password}));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        // CLIENTE
        if (data['usuario']['rol_id'] == 4) {
          print("cli");
          cliente.setInt('cliid', data['usuario']['id']);
          cliente.setString('clidireccion',data['usuario']['direccion']);
          cliente.setString('clinombre', data['usuario']['nombre']);
          cliente.setString('cliapellidos', data['usuario']['apellidos']);
          cliente.setString('clisexo', data['usuario']['sexo']);
          cliente.setString('clisuscripcion', data['usuario']['suscripcion']);
          cliente.setInt('clisaldobeneficio', data['usuario']['saldo_beneficios']);
          setState(() {
            status = 200;
            rol = 4;
          });
        }
        //CONDUCTOR
        else if (data['usuario']['rol_id'] == 5) {
          print("conductor");
          conductor.setString('condnombre', data['usuario']['nombres']);
          conductor.setString('condapellidos', data['usuario']['apellidos']);
          conductor.setString('condsexo', data['usuario']['licencia']);
          conductor.setString('conddni', data['usuario']['dni']);
          conductor.setInt('condid', data['usuario']['id']);
          setState(() {
            status = 200;
            rol = 5;
          });
        }
        // GERENTE
        else if (data['usuario']['rol_id'] == 3) {
          print("gerente");
          gerente.setInt('getid', data['usuario']['id']);
          gerente.setString('gernombre', data['usuario']['nombre']);
          gerente.setString('gerapellidos', data['usuario']['apellidos']);
          gerente.setString('gerdni', data['usuario']['sexo']);


          setState(() {
            status = 200;
            rol = 3;
          });
        }
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
                          /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Prueba()),
                            );*/
                          } else if (rol == 5) {
                            /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Prueba()),
                            );*/
                          } else if(rol==3){
                             /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Prueba()),
                            );*/
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
