//import 'package:appsol_final/components/fin.dart';
import 'package:appsol_final/components/productos.dart';
import 'package:appsol_final/components/promos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  bool light0 = false;
  int numero = 0;
  double envio = 0.0;
  double ahorro = 0.0;
  double totalVenta = 0.0;
  String tipoPedido = "normal";
  int lastPedido = 0;
  Color color = Colors.white;
  //POR AHORA EL CLIENTE ES MANUAL!!""
  int clienteId = 1;
  String direccion = 'Av. Las Flores 137 - Cayma';
  DateTime tiempoActual = DateTime.now();
  late DateTime tiempoPeru;
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
    DateTime tiempoGMTPeru = tiempoActual.subtract(const Duration(hours: 5));
    await datosCreadoPedido(
        clienteId, tiempoActual.toString(), monto, tipo, "pendiente");
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
          backgroundColor: const Color.fromRGBO(0, 106, 252, 1.000),
          shadowColor: Colors.black,
          elevation: 10,
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return Expanded(
              child: SizedBox(
                height: 100,
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 15, bottom: 10, left: 25, right: 25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                          ),
                          Text(
                            'S/.$totalVenta',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 400,
                        child: ElevatedButton(
                          onPressed: () async {
                            await crearPedidoyDetallePedido(
                                tipoPedido, totalVenta);
                            /* Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Fin()),
                            );*/
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            minimumSize:
                                const MaterialStatePropertyAll(Size(350, 38)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                          ),
                          child: const Text(
                            'Confirmar Pedido',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 106, 252, 1.000),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    //TU PEDIDO
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Tu pedido",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        margin: const EdgeInsets.only(
                            top: 5, bottom: 10, left: 10, right: 10),
                        child: ListView.builder(
                            itemCount: widget.seleccionados.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(
                                    bottom: 5, left: 10, right: 10),
                                decoration: const BoxDecoration(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          height: 47,
                                          width: 47,
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
                                                  fontSize: 14,
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
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            "S/. ${widget.seleccionados[index].precio}",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                    255, 1, 75, 135)),
                                          ),
                                          Text(
                                            "Cant. ${widget.seleccionados[index].cantidad}",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color.fromARGB(
                                                    255, 1, 75, 135)),
                                          ),
                                          SizedBox(
                                            height: 6,
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
                    //CUPONES
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Cupones",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                top: 5, bottom: 5, left: 25),
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Lottie.asset('lib/imagenes/cupon4.json'),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          SizedBox(
                            width: 130,
                            child: TextFormField(
                              cursorColor:
                                  const Color.fromRGBO(0, 106, 252, 1.000),
                              enableInteractiveSelection: false,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 1, 75, 135)),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ingresar cupón',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 195, 195, 195),
                                    fontSize: 13,
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
                                  const Color.fromRGBO(255, 0, 93, 1.000)),
                            ),
                            child: const Text(
                              'Validar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //TIPO DE ENVIO
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Tipo de envio",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                    Card(
                      surfaceTintColor: color,
                      color: Colors.white,
                      elevation: 8,
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(
                                left: 15, right: 15, top: 10, bottom: 10),
                            child: Column(
                              children: [
                                const Text(
                                  'Normal',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ),
                                const Text(
                                  'GRATIS',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ),
                                const Text(
                                  "Si lo pides después de la 1:00 P.M se agenda para mañana.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ).animate().shake(),
                              ],
                            ),
                          ),
                          Switch(
                            activeColor:
                                const Color.fromRGBO(120, 251, 99, 1.000),
                            inactiveTrackColor:
                                const Color.fromARGB(255, 226, 226, 226),
                            inactiveThumbColor:
                                const Color.fromARGB(255, 174, 174, 174),
                            trackOutlineWidth:
                                const MaterialStatePropertyAll(0),
                            trackOutlineColor: const MaterialStatePropertyAll(
                                Colors.transparent),
                            value: light0,
                            onChanged: (bool value) {
                              setState(() {
                                light0 = value;
                                tiempoPeru = tiempoActual
                                    .subtract(const Duration(hours: 5));
                                print(value);
                                print('hora acrtual ${tiempoPeru.hour}');
                              });
                              if (light0 == false) {
                                //ES NORMAL
                                setState(() {
                                  color = Colors.white;
                                  tipoPedido = 'normal';
                                  envio = 0;
                                  print(tipoPedido);
                                  print(envio);
                                });
                              } else {
                                //ES EXPRESS
                                if (tiempoActual.hour <= 16) {
                                  print('son mas de las 16');
                                  setState(() {
                                    tipoPedido = 'normal';
                                    light0 = false;
                                    color = Colors.white;
                                    envio = 0;
                                  });
                                } else {
                                  print('son menos de las 16');
                                  setState(() {
                                    tipoPedido = 'express';
                                    color = const Color.fromRGBO(
                                        120, 251, 99, 1.000);
                                    envio = 4;
                                    print(tipoPedido);
                                    print(envio);
                                  });
                                }
                              }

                              setState(() {
                                totalVenta = widget.total + envio;
                                print(totalVenta);
                              });
                            },
                          ),
                          Container(
                            width: 120,
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: const Column(
                              children: [
                                Text(
                                  'Express',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ),
                                Text('+ S/. 4.00',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            Color.fromARGB(255, 1, 75, 135))),
                                Text(
                                  "Recive tu producto más rapido, solo hasta las 4:00 P.M.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //DIRECCION DE ENVIO
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Direccion",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                    Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 10),
                        child: Container(
                            margin: const EdgeInsets.only(
                                left: 20, right: 20, top: 5, bottom: 5),
                            //AQUI SE PONDRA LA DIRECCION QUE ELIGIO EL CLIENTE
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  direccion,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 1, bottom: 1, left: 25),
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(0),
                                    /*image: const DecorationImage(

                                  image: AssetImage('lib/imagenes/cupon.png'),
                                  //fit: BoxFit.cover,
                                )*/
                                  ),
                                  child: Lottie.asset('lib/imagenes/ubi4.json'),
                                ),
                              ],
                            ))),
                    //NOTAS PARA EL REPARTIDOR
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Notas para el repartidor",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 5),
                        child: TextFormField(
                          cursorColor: const Color.fromRGBO(0, 106, 252, 1.000),
                          enableInteractiveSelection: false,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 1, 75, 135)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Ej. Casa con porton azúl, tocar tercer piso',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 195, 195, 195),
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                          validator: (value) {},
                        ),
                      ),
                    ),
                    //RESUMEN
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, left: 20),
                      child: const Text(
                        "Resumen de Pedido",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 10,
                      ),
                      child: Container(
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 8, top: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Productos',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 1, 75, 135)),
                                  ),
                                  Text(
                                    'S/.${widget.total}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 1, 75, 135)),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Envio',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 1, 75, 135)),
                                  ),
                                  Text(
                                    'S/.$envio',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 1, 75, 135)),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Ahorro',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromRGBO(234, 51, 98, 1.000)),
                                  ),
                                  Text(
                                    'S/.$ahorro',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Color.fromRGBO(234, 51, 98, 1.000)),
                                  )
                                ],
                              )
                            ],
                          )),
                    ),
                    const SizedBox(
                      height: 95,
                    ),
                  ],
                ),
              ))),
    );
  }
}
