import 'package:appsol_final/components/fin.dart';
import 'package:appsol_final/components/productos.dart';
import 'package:appsol_final/components/promos.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Pedido extends StatefulWidget {
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

  Future<dynamic> datosCreadoPedido(
      clienteId, fecha, montoTotal, tipo, estado) async {
    await http.post(Uri.parse(apiUrl + '/api/pedido'),
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
    await http.post(Uri.parse(apiUrl + '/api/detallepedido'),
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
      backgroundColor: Colors.white,
      bottomSheet: BottomSheet(
          backgroundColor: const Color.fromRGBO(88, 184, 249, 1.000),
          shadowColor: Colors.black,
          elevation: 10,
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return Expanded(
              child: Container(
                height: 100,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Total'),
                    SizedBox(
                      width: 400,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5),
                          minimumSize:
                              const MaterialStatePropertyAll(Size(350, 38)),
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromRGBO(0, 82, 164, 1.000)),
                        ),
                        child: const Text(
                          'Confirmar Pedido',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Tu pedido",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w400,
                            fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 225,
                      child: Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        margin: const EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        child: ListView.builder(
                            itemCount: widget.seleccionados.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(
                                    bottom: 10, left: 10, right: 10),
                                decoration: const BoxDecoration(
                                    //color: Colors.amber,
                                    border: Border(
                                  bottom: BorderSide(
                                      style: BorderStyle.solid,
                                      color: Colors.black26),
                                )),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                              image: DecorationImage(
                                                image: NetworkImage(widget
                                                    .seleccionados[index].foto),
                                                //fit: BoxFit.cover,
                                              )),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.seleccionados[index].nombre
                                                  .capitalize(),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromARGB(
                                                      255, 1, 75, 135)),
                                            ),
                                            Text(
                                              widget.seleccionados[index]
                                                  .descripcion
                                                  .capitalize(),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color.fromARGB(
                                                      255, 1, 75, 135)),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "S/. ${widget.seleccionados[index].precio}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 1, 75, 135)),
                                          ),
                                          Text(
                                            "Cant. ${widget.seleccionados[index].cantidad}",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 1, 75, 135)),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Cupones",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w400,
                            fontSize: 20),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 30),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                top: 10, bottom: 10, left: 25),
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(0),
                                image: const DecorationImage(
                                  image: AssetImage('lib/imagenes/cupon.png'),
                                  //fit: BoxFit.cover,
                                )),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 130,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ingresar cupón',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 1, 75, 135),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                              validator: (value) {},
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(5),
                              minimumSize:
                                  const MaterialStatePropertyAll(Size(40, 38)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(0, 82, 164, 1.000)),
                            ),
                            child: const Text(
                              'Validar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
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
                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Fin()),
                                  );*/
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
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300),
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

                          await crearPedidoyDetallePedido(
                              "express", totalVenta);

                          /* Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Fin()),
                          );*/
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
                ),
              ))),
    );
  }
}
