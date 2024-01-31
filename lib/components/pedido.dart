/*
import 'package:app_final/components/test/fin.dart';
import 'package:app_final/components/test/promos.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:app_final/components/test/productos.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class Pedido extends StatefulWidget {
  // ATRIBUTOS DE LA CLASE - datos inmutables con FINAL
  final List<Producto> seleccionados;
  final List<Promo> seleccionadosPromo;
  final double total;

  const Pedido({
    Key? key,
    required this.seleccionados,
    required this.seleccionadosPromo,
    required this.total,
  }) : super(key: key);

  @override
  State<Pedido> createState() => _PedidoState();
}

class _PedidoState extends State<Pedido> {
  int numero = 0;
  double express = 4.0;
  double totalVenta = 0.0;
  String tipoPedido = "";
  int lastPedido = 0;
  //POR AHORA EL CLIENTE ES MANUAL!!""

  int clienteId = 9;
  DateTime tiempoActual = DateTime.now();
String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidos = 'http://10.0.2.2:8004/api/pedido';
  String apiDetallePedido = 'http://10.0.2.2:8004/api/detallepedido';
  String apiLastPedido = 'http://10.0.2.2:8004/api/pedido_last';
  /*
  String apiPedidos = 'https://aguasolfinal-dev-qngg.2.us-1.fl0.io/api/pedido';
  String apiDetallePedido =
      'https://aguasolfinal-dev-qngg.2.us-1.fl0.io/api/detallepedido';
  String apiLastPedido =
      'https://aguasolfinal-dev-qngg.2.us-1.fl0.io/api/pedido_last';*/

  Future<dynamic> datosCreadoPedido(
      clienteId, fecha, montoTotal, tipo, estado) async {
    await http.post(Uri.parse(apiUrl+'/api/pedido'),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "subtotal": montoTotal.toDouble(),
          "descuento": null,
          "total": montoTotal.toDouble(),
          "fecha": fecha,
          "tipo": tipo,
          "estado": estado,
        }));
  }

  Future<dynamic> detallePedido(
      clienteId, productoId, cantidad, promoID) async {
    await http.post(Uri.parse(apiUrl+'/api/detallepedido'),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "producto_id": productoId,
          "cantidad": cantidad,
          "promocion_id": promoID
        }));
  }

  Future<void> crearPedidoyDetallePedido(tipo, monto) async {
    DateTime tiempoGMTPeru = tiempoActual.subtract(const Duration(hours: 10));
    await datosCreadoPedido(
        clienteId, tiempoGMTPeru.toString(), monto, tipo, "pendiente");
    print(tiempoGMTPeru.toString());
    print(tiempoActual.timeZoneName);
    print("creando detalles de pedidos----------");
    for (var i = 0; i < widget.seleccionados.length; i++) {
      print("longitud de seleccinados--------${widget.seleccionados.length}");
      print(i);
      print("est es la promocion ID---------");
      print(widget.seleccionados[i].promoID);
      await detallePedido(clienteId, widget.seleccionados[i].id,
          widget.seleccionados[i].cantidad, widget.seleccionados[i].promoID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    margin: const EdgeInsets.only(top: 0, left: 20),
                    // color:Colors.grey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          padding: const EdgeInsets.all(10),
                          height: 90,
                          width: 130,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('lib/imagenes/mañana.png')),
                              color: const Color.fromARGB(255, 24, 157, 104)),
                        ),
                        //Expanded(child: Container()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(right: 20),
                                //color: Colors.blue,
                                child: const Text(
                                  "Tu pedido",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 17, 62, 98),
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300),
                                )),
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: const Text(
                                "se agendó",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Color.fromARGB(255, 3, 39, 68)),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              child: const Text(
                                "aquí esta el detalle",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    height: 170,
                    decoration: BoxDecoration(
                        //color:Color.fromARGB(255, 83, 231, 147),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            width: 4,
                            color: const Color.fromARGB(255, 218, 222, 3))),
                    child: ListView.builder(
                        itemCount: widget.seleccionados.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            //padding: const EdgeInsets.all(2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.water_drop_outlined,
                                  color: Color.fromARGB(255, 2, 77, 138),
                                  size: 25,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 233,
                                  margin: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    "${widget.seleccionados[index].nombre}-${widget.seleccionados[index].descripcion}"
                                        .capitalize(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color.fromARGB(255, 1, 75, 135)),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    //color:Colors.grey,
                    height: 50,
                    child: Text(
                      "El total es de: S/.${widget.total}",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 70, 123),
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 20),
                      height: 40,
                      //color:Colors.grey,
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () async {
                                await crearPedidoyDetallePedido(
                                    "normal", widget.total);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Fin()),
                                );
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromARGB(255, 0, 68, 120))),
                              child: const Text(
                                "Listo !",
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 15),
                            width: 182,
                            child: const Text(
                              "Si lo pides después de la 1:00 P.M se agenda para mañana.",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 3, 39, 68)),
                            ),
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: const Text(
                      "Lo necesitas",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: const Text(
                      "YA ?",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(15)),
                          child: Lottie.asset('lib/imagenes/anim_13.json'),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          width: 240,
                          child: const Text(
                            "Por S/. 4.00 convierte tu pedido a Express y recíbelo ya!",
                            style: TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 3, 39, 68)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    height: 40,
                    //color:Colors.grey,
                    width: 160,
                    child: ElevatedButton(
                      onPressed: () async {
                        //POR AHORA EL CLIENTE ES MANUAL!!""

                        setState(() {
                          totalVenta = widget.total + express;
                        });

                        await crearPedidoyDetallePedido("express", totalVenta);

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Fin()),
                        );
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 219, 214, 214))),
                      child: const Text(
                        "Express >>",
                        style: TextStyle(
                            fontSize: 22,
                            color: Color.fromARGB(255, 2, 78, 140)),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
*/