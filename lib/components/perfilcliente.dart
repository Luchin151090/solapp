import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({Key? key}) : super(key: key);
  @override
  _PerfilCliente createState() => _PerfilCliente();
}

class _PerfilCliente extends State<PerfilCliente> {
  //Color colorLetra = Color.fromARGB(255, 1, 75, 135);
  Color colorLetra = Colors.black;
  //Color colorTitulos = Color.fromARGB(255, 1, 42, 76);
  Color colorTitulos = Colors.black;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Row(
              children: [
                //FOTO DEL CLIENTE
                Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 218, 218, 218),
                      borderRadius: BorderRadius.circular(40)),
                  height: 70,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    //poner un if por aqui por si es hombre o mujer
                    child: Icon(
                      Icons.man_2_rounded,
                      color: colorTitulos,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Nombre
                    Text(
                      '${userProvider.user?.nombre} ${userProvider.user?.apellidos}',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: colorTitulos),
                    ),
                    //Correo
                    Text(
                      '${userProvider.user?.codigocliente}',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: colorTitulos),
                    ),
                    //Numero
                    Text(
                      '${userProvider.user?.suscripcion}',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: colorTitulos),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //CARD DE INFO PERSONAL
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    elevation: 8,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 3, bottom: 10),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.person_2_outlined,
                              color: colorLetra,
                              size: 45,
                            ),
                          ),
                          Text(
                            'Info. Pesonal',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    )),
                //CARD DE MEMBRESOL
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    elevation: 8,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.beach_access_outlined,
                              size: 45,
                              color: colorLetra,
                            ),
                          ),
                          Text(
                            ' Membre Sol ',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    )),
                //CARD DE CUPONES
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    surfaceTintColor: Colors.white,
                    color: Colors.white,
                    elevation: 8,
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.discount_outlined,
                              color: colorLetra,
                              size: 45,
                            ),
                          ),
                          Text(
                            '    Cupones    ',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          //BILLETERA SOL
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20),
            child: Text(
              "Billetera Sol",
              style: TextStyle(
                  color: colorTitulos,
                  fontWeight: FontWeight.w600,
                  fontSize: 17),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            height: 150,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                surfaceTintColor: Colors.white,
                color: Colors.white,
                elevation: 8,
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 40, right: 40, bottom: 10, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /** SARITA =) YA ESTA EL END POINT DE SALDO SERA QU LO PRUEBS  */
                          Text(
                            'S/. 30.00',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w700,
                                fontSize: 35),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 25),
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              //color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Lottie.asset('lib/imagenes/billetera3.json'),
                          ),
                        ],
                      ),
                      Text(
                        'Retiralo hasta el: 05/03/2024',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ),
          //CONFIGURACION
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20),
            child: Text(
              "Configuración",
              style: TextStyle(
                  color: colorTitulos,
                  fontWeight: FontWeight.w600,
                  fontSize: 17),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(8),
                surfaceTintColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255)),
                minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: colorLetra,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: colorLetra,
                  )
                ],
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(8),
                surfaceTintColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255)),
                minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 25,
                        color: colorLetra,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Libro de reclamaciones',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: colorLetra,
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(8),
                surfaceTintColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255)),
                minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 255, 255, 255)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 25,
                        color: colorLetra,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Registra tu tienda',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: colorLetra,
                  )
                ],
              ),
            ),
          ),
        ]),
      )),
    );
  }
}
