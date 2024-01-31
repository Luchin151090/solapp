/*
import 'dart:convert';
import 'package:app_final/components/test/dise%C3%B1o.dart';
import 'package:intl/intl.dart';

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
  String apiCreateUser = 'http://10.0.2.2:8004/api/user_cliente';

  Future<dynamic> registrar(nombre, apellidos, dni, sexo, fecha, nickname,contrasena, email, telefono, ruc) async {
    try {
      // Parsear la fecha de nacimiento a DateTime
    DateTime fechaNacimiento = DateFormat('d/M/yyyy').parse(fecha);

    // Formatear la fecha como una cadena en el formato deseado (por ejemplo, 'yyyy-MM-dd')
    String fechaFormateada = DateFormat('yyyy-MM-dd').format(fechaNacimiento);

      await http.post(Uri.parse(apiCreateUser),
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
            "sexo": sexo
          }));
    } catch (e) {
      throw Exception('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //final TabController _tabController = TabController(length: 2, vsync: this);

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
                        margin: const EdgeInsets.only(top: 10, left: 20),
                        //color:Colors.grey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    child: const Text(
                                  "Me encantaría",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 0, 57, 103),
                                      fontSize: 35,
                                      fontWeight: FontWeight.w300),
                                )),
                                Container(
                                    child: const Text(
                                  "saber de ti",
                                  style: TextStyle(
                                      fontSize: 35,
                                      color: Color.fromARGB(255, 0, 41, 72)),
                                )),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 50),
                              height: 100,
                              width: 100,
                              child: Lottie.asset(
                                  'lib/imagenes/Animation - 1701877289450.json'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      // FORMULARIO
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        padding: const EdgeInsets.all(8),
                        // height: 700,
                        width: 300,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha de Nacimiento',
                                    // hintText: 'Ingrese sus apellidos',
                                    isDense: true,
                                    labelStyle: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                    labelStyle: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
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
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 55, 99),
                                    ),
                                    hintStyle: TextStyle(
                                      fontSize: 13.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),

                      // REGISTRAR
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        height: 60,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: ()  {
                            if (_formKey.currentState!.validate()) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Gracias por registrar',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 4, 80, 143)),
                                      ),
                                      content: const Text(
                                        'Te esparamos!',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () async{
                                            await registrar(
                                  _nombres.text,
                                  _apellidos.text,
                                  _dni.text,
                                  selectedSexo,
                                  _fechaController.text,
                                  _username.text,
                                  _password.text,
                                  _email.text,
                                  _telefono.text,
                                  _ruc.text);
                              print("registrado-....");
                                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login2()),
                                ); // Cierra el AlertDialog
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
                              
                            }
                          },
                          child: Text(
                            "Registrar",
                            style: TextStyle(fontSize: 20, color: Colors.white),
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

*/