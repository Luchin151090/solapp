import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:lottie/lottie.dart';

class Fin extends StatefulWidget {
  const Fin({super.key});

  @override
  State<Fin> createState() => _FinState();
}

class _FinState extends State<Fin> {
  @override
  Widget build(BuildContext context) {
    //final TabController _tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          //color:Colors.grey,
                          margin: const EdgeInsets.only(top: 0, left: 20),
                          child: Text(
                            "Gracias por",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: largoActual * 0.04),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: Text(
                            "Llevar vida a tu HOGAR!",
                            style: TextStyle(fontSize: largoActual * 0.04),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: Text(
                            "con",
                            style: TextStyle(fontSize: largoActual * 0.047),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Text(
                                "Agua Sol",
                                style: TextStyle(
                                  fontSize: largoActual * 0.068,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: largoActual * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Stack(alignment: Alignment.center, children: [
                            Lottie.asset(
                              'lib/imagenes/check10.json',
                              height: anchoActual * 1,
                            ),
                            Lottie.asset(
                              'lib/imagenes/check3.json',
                              height: anchoActual * 1,
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: largoActual * 0.027,
                        ),
                        SizedBox(
                          height: largoActual * 0.027,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          height: largoActual * 0.081,
                          //color:Colors.grey,
                          width: anchoActual * 0.39,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const BarraNavegacion(
                                          indice: 0,
                                          subIndice: 0,
                                        )
                                    //const Promos()
                                    ),
                              );
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000))),
                            child: Text(
                              "Menú",
                              style: TextStyle(
                                  fontSize: largoActual * 0.027,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.027,
                        ),
                      ]))),
        ));
  }
}
