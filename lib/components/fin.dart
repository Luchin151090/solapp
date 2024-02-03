/*
import 'package:appsol_final/components/hola.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          onPopInvoked: (bool didPop){
            if(didPop){
              return;
            }
          },
          child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        //color:Colors.grey,
                        margin: const EdgeInsets.only(top: 0,left: 20),
                        child:const Text("Gracias por",
                        style: TextStyle(
                          color:Colors.black,fontWeight: FontWeight.w300,fontSize: largoActual * 0.04),),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text("Llevar vida a tu HOGAR!",
                        style: TextStyle(fontSize: largoActual * 0.04),),
                      ),
                       Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text("con",
                        style: TextStyle(fontSize: largoActual * 0.047),),
                      ),
                       Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Text("Agua Sol",
                            style: TextStyle(
                              fontSize: largoActual * 0.068,
                              ),),
                              Container(
                                height: largoActual * 0.13,
                                width: largoActual * 0.13,
                                
                                child: Lottie.asset('lib/imagenes/arboles.json'))
                          ],
                        ),
                      ),
                      SizedBox(height: largoActual * 0.027,),
                      Container(
                        margin: const EdgeInsets.only(left:30),
                        //color: Colors.grey,
                        width: largoActual * 0.13,
                        height: largoActual * 0.13,
                        child: Image.asset('lib/imagenes/logo_sol_tiny.png').animate().fade(delay:1500.ms ).then().shake(),
                      ),
                      SizedBox(height: largoActual * 0.027,),
          
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        height: largoActual * 0.081,
                        //color:Colors.grey,
                        width: anchoActual * 0.39,
                        child: ElevatedButton(onPressed: (){
                          Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Hola()),
                      );
                        },
                        
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 1, 34, 60))
                        ),
                         child:const Text("<< Menú",style: TextStyle(fontSize: largoActual * 0.027,color:Colors.white),),
                         ),
          
                      ),
                      SizedBox(height: largoActual * 0.027,),
                      Expanded(
                        child: Container(
                          //color:Colors.grey,
                           width: anchoActual,
                          height: largoActual/1.75,
                          child: Image.asset('lib/imagenes/reparte.png'),
                        ),
                      ),
                      
          
                      
                    ])
              )),
        ));}}
 */