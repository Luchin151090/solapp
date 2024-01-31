/*import 'package:app_final/components/test/dise%C3%B1o.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class Presenta extends StatefulWidget {
  const Presenta({super.key});

  @override
  State<Presenta> createState() => _PresentaState();
}



class _PresentaState extends State<Presenta> {

@override
void initState(){
  //navegar al login despues de 3 segundos
  super.initState();
  Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login2()), // Reemplaza OtraVista con el nombre de tu vista destino
      );
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            
                            
                            Center(
                              child: Container(
                                height: 300,
                                width: 200,
                                child: Lottie.asset('lib/imagenes/redondito.json'),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 100,
                                height:300,
                                child: Image.asset('lib/imagenes/logo_sol.png'),
                              ),
                            ).animate()
                            .fade(duration: 1000.ms)
                            .slideY()
                            .then()
                            .shake(),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 100),
                        child: Text("Copyright \u00a9 COTECSA - 2024",
                        style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 9, 74, 126)),),
                      ).animate().fade(duration: 2000.ms),
                    ]))));
  }
}
*/