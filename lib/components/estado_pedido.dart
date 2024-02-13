import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class EstadoPedido extends StatefulWidget {
  const EstadoPedido({Key? key}) : super(key: key);
  @override
  State<EstadoPedido> createState() => _EstadoPedido();
}

class _EstadoPedido extends State<EstadoPedido> with TickerProviderStateMixin {
  //Color colorLetra = Color.fromARGB(255, 1, 75, 135);
  Color colorLetra = Colors.black;
  //Color colorTitulos = Color.fromARGB(255, 1, 42, 76);
  Color colorTitulos = Colors.black;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  Future<dynamic> getUbicaciones(clienteID) async {
    print("1) get ubicaciones---------");
    print("$apiUrl/api/ubicacion/$clienteID");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de get ubicaciones---------");
        var data = json.decode(res.body);
        List<UbicacionModel> tempUbicacion = data.map<UbicacionModel>((mapa) {
          return UbicacionModel(
            id: mapa['id'],
            latitud: mapa['latitud'].toDouble(),
            longitud: mapa['longitud'].toDouble(),
            direccion: mapa['direccion'],
            clienteID: mapa['cliente_id'],
            clienteNrID: null,
            distrito: mapa['distrito'],
          );
        }).toList();
        setState(() {
          listUbicacionesObjetos = tempUbicacion;
          print(listUbicacionesObjetos);
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final TabController tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        backgroundColor: Colors.white,
      ),*/
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: largoActual * 0.070,
            width: anchoActual,
            decoration: BoxDecoration(
                color: Color.fromARGB(129, 192, 192, 192),
                borderRadius: BorderRadius.circular(20)),
            child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                controller: tabController,
                //indicatorWeight: 10,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromRGBO(0, 82, 164, 0.8),
                ),
                labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: largoActual * 0.020,
                    fontWeight: FontWeight
                        .w500), // Ajusta el tamaño del texto de la pestaña seleccionada
                unselectedLabelStyle: TextStyle(
                    fontSize: largoActual * 0.019, fontWeight: FontWeight.w300),
                //labelColor: colorLetra,
                unselectedLabelColor: colorLetra,
                indicatorColor: const Color.fromRGBO(83, 176, 68, 1.000),
                tabs: const [
                  Tab(
                    text: "Pendientes",
                    icon: Icon(
                      Icons.assignment_rounded,
                      size: 20,
                    ),
                    iconMargin: EdgeInsets.only(bottom: 1),
                  ),
                  Tab(
                    text: "Entregados",
                    icon: Icon(
                      Icons.assignment_turned_in_rounded,
                      size: 20,
                    ),
                    iconMargin: EdgeInsets.only(bottom: 1),
                  ),
                ]),
          ),
          Container(
            margin: EdgeInsets.only(
              top: largoActual * 0.013,
            ),
            height: largoActual / 2.13,
            width: double.maxFinite,
            child: TabBarView(
              controller: tabController,
              children: [
                ListView.builder(
                    controller: scrollController1,
                    scrollDirection: Axis.vertical,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BarraNavegacion(
                                      indice: 0,
                                      subIndice: 1,
                                    )
                                ),
                          );*/
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: anchoActual * 0.028),
                          height: anchoActual * 0.83,
                          width: anchoActual * 0.83,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 71, 106, 133),
                              borderRadius: BorderRadius.circular(30),
                              image: const DecorationImage(
                                image: AssetImage('lib/imagenes/bodegon.png'),
                                fit: BoxFit.cover,
                              )),
                        ),
                      );
                    }),
                ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController2,
                    itemCount: listProducto.length,
                    itemBuilder: (context, index) {
                      Producto producto = listProducto[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BarraNavegacion(
                                      indice: 0,
                                      subIndice: 2,
                                    )
                                //const Productos()
                                ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: anchoActual * 0.028),
                          height: anchoActual * 0.83,
                          width: anchoActual * 0.83,
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 75, 108, 134),
                              borderRadius: BorderRadius.circular(50),
                              image: DecorationImage(
                                image: NetworkImage(producto.foto),
                                fit: BoxFit.cover,
                              )),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ]),
      )),
    );
  }
}
