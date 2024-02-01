
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Asistencia extends StatefulWidget {
  const Asistencia({super.key});

  @override
  State<Asistencia> createState() => _AsistenciaState();
}

class _AsistenciaState extends State<Asistencia> {

  Future<void> _launchPhone() async {
    const phoneNumber = 'tel:955372038'; // Reemplaza esto con el número de teléfono real

    try {
      if (await canLaunchUrlString(phoneNumber)) {
        await launchUrlString(phoneNumber);
      } else {
        throw 'No se pudo abrir el marcador de teléfono';
      }
    } catch (e) {
      throw 'Error al intentar abrir el marcador de teléfono: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text("Ancho X largo: ${anchoActual}x ${largoActual.toStringAsFixed(2)}"),
                Container(
                  margin: const EdgeInsets.only(top: 20,left: 20,bottom: 0),
                  child: Text("Estamos aquí",
                  style: TextStyle(fontSize: 40,color: const Color.fromARGB(255, 2, 73, 132)),),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text("para ayudarte",style: TextStyle(fontSize: 30),),
                ),
                 
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text("Llámanos a este número ",style: TextStyle(fontSize: 30),),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20,top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: TextButton(onPressed: (){
                          print("s");
                           _launchPhone();
                        }, child:const Text("955372038",
                        style: TextStyle(fontSize: 30,color:Color.fromARGB(255, 6, 57, 100)),)
                        ).animate().fade(delay: 000.ms).shake(),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 40),
                        width: 200,
                        height: 200,
                        child: Lottie.asset('lib/imagenes/callcenter.json'),
                      )
                    ],
                  )
                ),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(top: 80,left: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.amber
                    ),
                    child: Image.asset('lib/imagenes/logo_sol_tiny.png')
                  ),
                ),
              ]
            )
          )
        )
      
    );
  }
}