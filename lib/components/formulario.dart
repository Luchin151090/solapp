import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class Formu extends StatefulWidget {
  const Formu({super.key});

  @override
  State<Formu> createState() => _FormuState();
}

class _FormuState extends State<Formu> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nombres = TextEditingController();
  final TextEditingController _apellidos = TextEditingController();
  final TextEditingController _dni = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  bool _obscureText = true;
  String? selectedSexo;
  List<String> sexos = ['Masculino', 'Femenino'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiCreateUser = '/api/user_cliente';

  Future<dynamic> registrar(nombre, apellidos, dni, sexo, fecha, fechaAct,
      nickname, contrasena, email, telefono, ruc) async {
    try {
      // Parsear la fecha de nacimiento a DateTime
      DateTime fechaNacimiento = DateFormat('d/M/yyyy').parse(fecha);

      // Formatear la fecha como una cadena en el formato deseado (por ejemplo, 'yyyy-MM-dd')
      String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNacimiento);

      await http.post(Uri.parse(apiUrl + apiCreateUser),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "rol_id": 4,
            "nickname": nickname,
            "contrasena": contrasena,
            "email": email ?? "",
            "nombre": nombre,
            "apellidos": apellidos,
            "telefono": telefono,
            "ruc": ruc ?? "",
            "dni": dni,
            "fecha_nacimiento": fechaFormateada,
            "fecha_creacion_cuenta": fechaAct,
            "sexo": sexo
          }));
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final TabController _tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    DateTime tiempoActual = DateTime.now();
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITULOS
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10 * 0.013, left: 10 * 0.055),
                        //color:Colors.grey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text(
                                  "Me encantaría",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 0, 57, 103),
                                      fontSize: largoActual * 0.047,
                                      fontWeight: FontWeight.w300),
                                )),
                                Container(
                                    child: Text(
                                  "saber de ti",
                                  style: TextStyle(
                                      fontSize: largoActual * 0.047,
                                      color: Color.fromARGB(255, 0, 41, 72)),
                                )),
                              ],
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(right: anchoActual * 0.025),
                              height: (largoActual * 0.094) + 20,
                              width: (largoActual * 0.094) + 20,
                              child: Lottie.asset(
                                  'lib/imagenes/Animation - 1701877289450.json'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: largoActual * 0.027,
                      ),

                      // FORMULARIO
                      Container(
                        margin: EdgeInsets.only(left: anchoActual * 0.055),
                        padding: const EdgeInsets.all(8),
                        // height: 700,
                        width: anchoActual * 0.83,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 237, 210, 242),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(255, 2, 72, 129),
                            )),
                        //color:Colors.cyan,
                        child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nombres,
                                  decoration: InputDecoration(
                                    labelText: 'Nombres',
                                    hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _apellidos,
                                  decoration: InputDecoration(
                                    labelText: 'Apellidos',
                                    hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _dni,
                                  decoration: InputDecoration(
                                    labelText: 'DNI',
                                    hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                DropdownButtonFormField<String>(
                                  value: selectedSexo,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSexo = value;
                                    });
                                  },
                                  items: sexos.map((sexo) {
                                    return DropdownMenuItem<String>(
                                      value: sexo,
                                      child: Text(sexo),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    labelText: 'Sexo',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  readOnly: true,
                                  controller:
                                      _fechaController, // Usa el controlador de texto
                                  onTap: () async {
                                    // Abre el selector de fechas cuando se hace clic en el campo
                                    DateTime? fechaSeleccionada =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1970),
                                      lastDate: DateTime(2101),
                                    );

                                    if (fechaSeleccionada != null) {
                                      // Actualiza el valor del campo de texto con la fecha seleccionada
                                      _fechaController.text =
                                          "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
                                    }
                                  },
                                  keyboardType: TextInputType.datetime,
                                  style: TextStyle(
                                    fontSize: largoActual * 0.024,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Fecha de Nacimiento',
                                    // hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _username,
                                  decoration: InputDecoration(
                                    labelText: 'Usuario',
                                    hintText: 'Ingresa un usuario',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _password,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    hintText: 'Ingrese una contraseña',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      child: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email (opcional)',
                                    hintText: 'Ingresa su email',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _telefono,
                                  maxLength: 9,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Teléfono',
                                    hintText: 'Ingresa un usuario',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El campo es obligatorio';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _ruc,
                                  maxLength: 11,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'RUC (opcional)',
                                    hintText: 'Ingresa un usuario',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: largoActual * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: largoActual * 0.018,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),

                      // REGISTRAR
                      SizedBox(
                        height: largoActual * 0.02,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: anchoActual * 0.055),
                        height: largoActual * 0.081,
                        width: anchoActual * 0.42,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Gracias por registrar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 4, 80, 143)),
                                    ),
                                    content: Text(
                                      'Te esparamos!',
                                      style: TextStyle(
                                          fontSize: largoActual * 0.027,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          await registrar(
                                              _nombres.text,
                                              _apellidos.text,
                                              _dni.text,
                                              selectedSexo,
                                              _fechaController.text,
                                              tiempoActual,
                                              _username.text,
                                              _password.text,
                                              _email.text,
                                              _telefono.text,
                                              _ruc.text);
                                          print("registrado-....");
                                          /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login2()),
                                );*/ // Cierra el AlertDialog
                                        },
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Color.fromARGB(
                                                  255, 13, 58, 94)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text(
                            "Registrar",
                            style: TextStyle(
                                fontSize: largoActual * 0.027,
                                color: Colors.white),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 3, 66, 117))),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}
