/*
import 'package:app_final/components/test/hola.dart';
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
                          color:Colors.black,fontWeight: FontWeight.w300,fontSize: 30),),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text("Llevar vida a tu HOGAR!",
                        style: TextStyle(fontSize: 30),),
                      ),
                       Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: const Text("con",
                        style: TextStyle(fontSize: 35),),
                      ),
                       Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            const Text("Agua Sol",
                            style: TextStyle(
                              fontSize: 50,
                              ),),
                              Container(
                                height: 100,
                                width: 100,
                                
                                child: Lottie.asset('lib/imagenes/arboles.json'))
                          ],
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        margin: const EdgeInsets.only(left:30),
                        //color: Colors.grey,
                        width: 100,
                        height: 100,
                        child: Image.asset('lib/imagenes/logo_sol_tiny.png').animate().fade(delay:1500.ms ).then().shake(),
                      ),
                      const SizedBox(height: 20,),
          
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        height: 60,
                        //color:Colors.grey,
                        width: 140,
                        child: ElevatedButton(onPressed: (){
                          Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Hola()),
                      );
                        },
                        
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 1, 34, 60))
                        ),
                         child:const Text("<< Menú",style: TextStyle(fontSize: 20,color:Colors.white),),
                         ),
          
                      ),
                      const SizedBox(height: 20,),
                      Expanded(
                        child: Container(
                          //color:Colors.grey,
                           width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height/1.75,
                          child: Image.asset('lib/imagenes/reparte.png'),
                        ),
                      ),
                      
          
                      
                    ])
              )),
        ));}}
 */