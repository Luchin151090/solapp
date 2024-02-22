import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/promocion_model.dart';
import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/components/fin.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appsol_final/provider/user_provider.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class Pedido extends StatefulWidget {
  const Pedido({Key? key}) : super(key: key);
  @override
  State<Pedido> createState() => _PedidoState();
}

class _PedidoState extends State<Pedido> {
  late PedidoModel pedidoMio;
  bool light0 = false;
  int numero = 0;
  double envio = 0.0;
  double ahorro = 0.0;
  double totalVenta = 0.0;
  double totalProvider = 0.0;
  List<dynamic> seleccionadosTodos = [];
  List<Producto> seleccionadosProvider = [];
  List<Promo> selecciondosPromosProvider = [];
  String tipoPedido = "normal";
  TextEditingController notas = TextEditingController();
  TextEditingController _cupon = TextEditingController();
  String notasParaConductor = '';
  int lastPedido = 0;
  Color color = Colors.white;
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  //POR AHORA EL CLIENTE ES MANUAL!!""
  String direccion = 'Av. Las Flores 137 - Cayma';
  DateTime tiempoActual = DateTime.now();
  late DateTime tiempoPeru;
  int ubicacionSelectID = 0;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String codigoverify = '/api/code_cliente';

  Future<dynamic> datosCreadoPedido(
      clienteId, fecha, montoTotal, tipo, estado, notas, ubicacionID) async {
    print("-----------------------creandoPEDIDOO");
    await http.post(Uri.parse(apiUrl + '/api/pedido'),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "subtotal": montoTotal.toDouble(),
          "descuento": 0,
          "total": montoTotal.toDouble(),
          "fecha": fecha,
          "tipo": tipo,
          "estado": estado,
          "ubicacion_id": ubicacionID,
          "observacion": notas
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

  Future<void> crearPedidoyDetallePedido(
      clienteID, tipo, monto, seleccionados, notas) async {
    DateTime tiempoGMTPeru = tiempoActual.subtract(const Duration(hours: 5));
    await datosCreadoPedido(clienteID, tiempoActual.toString(), monto, tipo,
        "pendiente", notas, ubicacionSelectID);
    print(tiempoGMTPeru.toString());
    print(tiempoActual.timeZoneName);
    print("creando detalles de pedidos----------");
    for (var i = 0; i < seleccionados.length; i++) {
      print("longitud de seleccinados--------${seleccionados.length}");
      print(i);
      print("est es la promocion ID---------");
      print(seleccionados[i].promoID);
      await detallePedido(clienteID, seleccionados[i].id,
          seleccionados[i].cantidad, seleccionados[i].promoID);
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      print('ES PEDIDOOO');
      setState(() {
        totalProvider = pedido.total;
        print(totalProvider);
        totalVenta = totalProvider + envio;
        cantCarrito = pedido.cantidadProd;
        seleccionadosProvider = pedido.seleccionados;
        selecciondosPromosProvider = pedido.seleccionadosPromo;
        for (var i = 0; i < seleccionadosProvider.length; i++) {
          if (seleccionadosProvider[i].promoID == null) {
            seleccionadosTodos.add(seleccionadosProvider[i]);
          }
        }
        for (var i = 0; i < selecciondosPromosProvider.length; i++) {
          seleccionadosTodos.add(selecciondosPromosProvider[i]);
        }
        if (pedido.cantidadProd > 0) {
          setState(() {
            colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
          });
        } else {
          setState(() {
            colorCantidadCarrito = Colors.grey;
          });
        }
      });
    } else {
      print('no es pedido');
      setState(() {
        totalProvider = 0;
        seleccionadosProvider = [];
        selecciondosPromosProvider = [];
        seleccionadosTodos = [];
        cantCarrito = 0;
        colorCantidadCarrito = Colors.grey;
      });
    }
  }

  void esUbicacion(UbicacionModel? ubicacion) {
    if (ubicacion is UbicacionModel) {
      print('ES UBIIIII');
      setState(() {
        ubicacionSelectID = ubicacion.id;
        direccion = ubicacion.direccion;
      });
    } else {
      print('no es ubi');
      setState(() {
        ubicacionSelectID = 0;
        direccion = "";
      });
    }
  }
  Future <dynamic> cuponExist(cupon)async{
    var res = await http.post(Uri.parse(apiUrl+codigoverify),
    headers: {"Content-type":"application/json"},
    body: jsonEncode({
      "codigo":cupon
    }));
    try{
      if(res.statusCode==200){
        bool data = json.decode(res.body);
        return data;
      }
      
    }catch(e){
      throw Exception("$e");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final pedidoProvider = context.watch<PedidoProvider>();
    final userProvider = context.watch<UserProvider>();
    final ubicacionProvider = context.watch<UbicacionProvider>();
    esUbicacion(ubicacionProvider.ubicacion);
    setState(() {
      seleccionadosTodos = [];
    });
    esVacio(pedidoProvider.pedido);
    print("SELECCIONADOS TODOS");
    print(seleccionadosTodos);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: BottomSheet(
          backgroundColor: const Color.fromRGBO(0, 106, 252, 1.000),
          shadowColor: Colors.black,
          elevation: 10,
          enableDrag: false,
          onClosing: () {},
          builder: (context) {
            return SizedBox(
              height: largoActual * 0.16,
              child: Container(
                margin: EdgeInsets.only(
                    top: largoActual * 0.02,
                    bottom: largoActual * 0.013,
                    left: anchoActual * 0.069,
                    right: anchoActual * 0.069),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: largoActual * (17 / 736)),
                        ),
                        Text(
                          'S/.$totalVenta',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: largoActual * (17 / 736)),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: largoActual * (8 / 736)),
                      child: SizedBox(
                        width: anchoActual * (400 / 360),
                        child: ElevatedButton(
                          onPressed:
                              totalProvider > 0.0 && ubicacionSelectID != 0
                                  ? () async {
                                      await crearPedidoyDetallePedido(
                                          userProvider.user?.id,
                                          tipoPedido,
                                          totalVenta,
                                          seleccionadosProvider,
                                          notas.text);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Fin()),
                                      );
                                    }
                                  : null,
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            surfaceTintColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            minimumSize: MaterialStatePropertyAll(Size(
                                anchoActual * (350 / 360),
                                largoActual * (38 / 736))),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                          ),
                          child: Text(
                            'Confirmar Pedido',
                            style: TextStyle(
                                color: const Color.fromRGBO(0, 106, 252, 1.000),
                                fontSize: largoActual * (14 / 736),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        toolbarHeight: largoActual * 0.08,
        actions: [
          Container(
            margin: EdgeInsets.only(
                top: largoActual * 0.018, right: anchoActual * 0.045),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(50)),
            height: largoActual * 0.059,
            width: largoActual * 0.059,
            child: Badge(
              largeSize: 18,
              backgroundColor: colorCantidadCarrito,
              label: Text(cantCarrito.toString(),
                  style: const TextStyle(fontSize: 12)),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    totalProvider = 0;
                    seleccionadosTodos = [];
                    seleccionadosProvider = [];
                    selecciondosPromosProvider = [];
                    cantCarrito = 0;
                  });
                  pedidoMio = PedidoModel(
                      seleccionados: seleccionadosProvider,
                      seleccionadosPromo: selecciondosPromosProvider,
                      cantidadProd: cantCarrito,
                      total: totalProvider);
                  Provider.of<PedidoProvider>(context, listen: false)
                      .updatePedido(pedidoMio);
                },
                icon: const Icon(Icons.delete_rounded),
                color: const Color.fromRGBO(0, 106, 252, 1.000),
                iconSize: largoActual * 0.035,
              ).animate().shakeY(
                    duration: Duration(milliseconds: 300),
                  ),
            ),
          ),
        ],
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
                      margin: EdgeInsets.only(
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.055),
                      child: Text(
                        "Tu pedido",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: largoActual * 0.023),
                      ),
                    ),
                    SizedBox(
                      height: largoActual * 0.24,
                      child: Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        margin: EdgeInsets.only(
                            top: largoActual * 0.0068,
                            bottom: largoActual * 0.013,
                            left: anchoActual * 0.028,
                            right: anchoActual * 0.028),
                        child: ListView.builder(
                            itemCount: seleccionadosTodos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                    bottom: largoActual * 0.0068,
                                    left: anchoActual * 0.028,
                                    right: anchoActual * 0.028),
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
                                          margin: EdgeInsets.only(
                                              left: anchoActual * 0.028),
                                          height: largoActual * 0.064,
                                          width: anchoActual * 0.13,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    seleccionadosTodos[index]
                                                        .foto),
                                                //fit: BoxFit.cover,
                                              )),
                                        ),
                                        SizedBox(
                                          width: anchoActual * 0.028,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              seleccionadosTodos[index]
                                                  .nombre
                                                  .toString()
                                                  .capitalize(),
                                              style: TextStyle(
                                                  fontSize: largoActual * 0.019,
                                                  color: const Color.fromARGB(
                                                      255, 1, 75, 135)),
                                            ),
                                            SizedBox(
                                              width: anchoActual * 0.45,
                                              child: Text(
                                                seleccionadosTodos[index]
                                                    .descripcion
                                                    .toString()
                                                    .capitalize(),
                                                style: TextStyle(
                                                    fontSize:
                                                        largoActual * 0.015,
                                                    color: const Color.fromARGB(
                                                        255, 1, 75, 135)),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          right: anchoActual * 0.028),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            height: largoActual * 0.0054,
                                          ),
                                          Text(
                                            "S/. ${seleccionadosTodos[index].precio}",
                                            style: TextStyle(
                                                fontSize: largoActual * 0.018,
                                                color: const Color.fromARGB(
                                                    255, 1, 75, 135)),
                                          ),
                                          Text(
                                            "Cant. ${seleccionadosTodos[index].cantidad}",
                                            style: TextStyle(
                                                fontSize: largoActual * 0.018,
                                                color: const Color.fromARGB(
                                                    255, 1, 75, 135)),
                                          ),
                                          SizedBox(
                                            height: largoActual * 0.0081,
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
                      margin: EdgeInsets.only(
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.055),
                      child: Text(
                        "Cupones",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: largoActual * 0.023),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.only(
                          left: anchoActual * 0.028,
                          right: anchoActual * 0.028,
                          bottom: largoActual * 0.013),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: largoActual * 0.0068,
                                bottom: largoActual * 0.0068,
                                left: anchoActual * 0.069),
                            height: largoActual * 0.065,
                            width: anchoActual * 0.13,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Lottie.asset('lib/imagenes/cupon4.json'),
                          ),
                          SizedBox(
                            width: anchoActual * 0.03,
                          ),
                          SizedBox(
                            width: anchoActual * 0.36,
                            child: TextFormField(
                              controller: _cupon,
                              cursorColor:
                                  const Color.fromRGBO(0, 106, 252, 1.000),
                              enableInteractiveSelection: false,
                              style: TextStyle(
                                  fontSize: largoActual * 0.018,
                                  color: const Color.fromARGB(255, 1, 75, 135)),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ingresar cupón',
                                hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 195, 195, 195),
                                    fontSize: largoActual * 0.018,
                                    fontWeight: FontWeight.w400),
                              ),
                              /*validator: (value) {

                              },*/
                            ),
                          ),
                          SizedBox(
                            width: anchoActual * 0.03,
                          ),
                          ElevatedButton(
                            onPressed: ()async {
                              // LOGICA PARA VALIDAR  62 ELEVADO A LA 5TA
                              bool existe = await cuponExist(_cupon);
                              if(existe) //true
                              {
                                print("codigo válido");
                              }
                              else{
                                print("no existe el codigo");
                              }
                              
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(5),
                              minimumSize: MaterialStatePropertyAll(Size(
                                  anchoActual * 0.247, largoActual * 0.052)),
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(255, 0, 93, 1.000)),
                            ),
                            child: Text(
                              'Validar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: largoActual * 0.018,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //TIPO DE ENVIO
                    Container(
                      margin: EdgeInsets.only(
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.055),
                      child: Text(
                        "Tipo de envio",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: largoActual * 0.023),
                      ),
                    ),
                    Card(
                      surfaceTintColor: color,
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.only(
                          left: anchoActual * 0.028,
                          right: anchoActual * 0.028,
                          bottom: largoActual * 0.013),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: anchoActual * 0.28,
                            margin: EdgeInsets.only(
                                left: anchoActual * 0.042,
                                right: anchoActual * 0.042,
                                top: largoActual * 0.013,
                                bottom: largoActual * 0.013),
                            child: Column(
                              children: [
                                Text(
                                  'Normal',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.019,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 1, 75, 135)),
                                ),
                                Text(
                                  'GRATIS',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.013,
                                      color: const Color.fromARGB(
                                          255, 1, 75, 135)),
                                ),
                                Text(
                                  "Si lo pides después de la 1:00 P.M se agenda para mañana.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: largoActual * 0.013,
                                      color: const Color.fromARGB(
                                          255, 1, 75, 135)),
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
                                tiempoPeru = tiempoActual;
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
                                  print('son menos de las 16');
                                  setState(() {
                                    tipoPedido = 'express';
                                    color = const Color.fromRGBO(
                                        120, 251, 99, 1.000);
                                    envio = 4;
                                    print(tipoPedido);
                                    print(envio);
                                  });
                                } else {
                                  print('son mas de las 16');
                                  setState(() {
                                    tipoPedido = 'normal';
                                    light0 = false;
                                    color = Colors.white;
                                    envio = 0;
                                  });
                                }
                              }

                              setState(() {
                                totalVenta = totalProvider + envio;
                                print(totalVenta);
                              });
                            },
                          ),
                          Container(
                            width: anchoActual * 0.28,
                            margin: EdgeInsets.only(
                                left: anchoActual * 0.028,
                                right: anchoActual * 0.028,
                                top: largoActual * 0.013,
                                bottom: largoActual * 0.013),
                            child: Column(
                              children: [
                                Text(
                                  'Express',
                                  style: TextStyle(
                                      fontSize: largoActual * 0.019,
                                      fontWeight: FontWeight.w500,
                                      color: const Color.fromARGB(
                                          255, 1, 75, 135)),
                                ),
                                Text('+ S/. 4.00',
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: const Color.fromARGB(
                                            255, 1, 75, 135))),
                                Text(
                                  "Recive tu producto más rapido y disfrútalo lo antes posible",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: largoActual * 0.013,
                                      color: const Color.fromARGB(
                                          255, 1, 75, 135)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //DIRECCION DE ENVIO
                    Container(
                      margin: EdgeInsets.only(
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.055),
                      child: Text(
                        "Direccion",
                        style: TextStyle(
                            color: Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: largoActual * 0.023),
                      ),
                    ),
                    Card(
                        surfaceTintColor: Colors.white,
                        color: Colors.white,
                        elevation: 8,
                        margin: EdgeInsets.only(
                            left: anchoActual * 0.028,
                            right: anchoActual * 0.028,
                            bottom: largoActual * 0.013),
                        child: Container(
                            //height: largoActual * 0.2,
                            margin: EdgeInsets.only(
                                left: anchoActual * 0.055,
                                right: anchoActual * 0.055,
                                top: largoActual * 0.0068,
                                bottom: largoActual * 0.0068),
                            //AQUI SE PONDRA LA DIRECCION QUE ELIGIO EL CLIENTE
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: anchoActual * 0.62,
                                  child: Text(
                                    direccion,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.017,
                                        color: const Color.fromARGB(
                                            255, 1, 75, 135)),
                                  ),
                                ),
                                SizedBox(
                                  width: anchoActual * 0.013,
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: largoActual * 0.0013,
                                    bottom: largoActual * 0.0013,
                                  ),
                                  height: largoActual * 0.061,
                                  width: largoActual * 0.061,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Lottie.asset('lib/imagenes/ubi4.json'),
                                ),
                              ],
                            ))),
                    //NOTAS PARA EL REPARTIDOR
                    Container(
                      margin: EdgeInsets.only(
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.055),
                      child: Text(
                        "Notas para el repartidor",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: largoActual * 0.023),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.only(
                          left: anchoActual * 0.028,
                          right: anchoActual * 0.028,
                          bottom: anchoActual * 0.013),
                      child: Container(
                        margin: EdgeInsets.only(
                            left: anchoActual * 0.055,
                            right: anchoActual * 0.055,
                            bottom: largoActual * 0.0068),
                        child: TextFormField(
                          controller: notas,
                          cursorColor: const Color.fromRGBO(0, 106, 252, 1.000),
                          enableInteractiveSelection: false,
                          style: TextStyle(
                              fontSize: largoActual * 0.018,
                              color: const Color.fromARGB(255, 1, 75, 135)),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Ej. Casa con porton azúl, tocar tercer piso',
                            hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 195, 195, 195),
                                fontSize: largoActual * 0.018,
                                fontWeight: FontWeight.w400),
                          ),
                          /*validator: (value) {

                          },*/
                        ),
                      ),
                    ),
                    //RESUMEN
                    Container(
                      margin: EdgeInsets.only(
                          bottom: largoActual * 0.013,
                          left: anchoActual * 0.055),
                      child: Text(
                        "Resumen de Pedido",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 1, 42, 76),
                            fontWeight: FontWeight.w600,
                            fontSize: largoActual * 0.023),
                      ),
                    ),
                    Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.only(
                        left: anchoActual * (10 / 360),
                        right: anchoActual * (10 / 360),
                        bottom: largoActual * (10 / 736),
                      ),
                      child: Container(
                          margin: EdgeInsets.only(
                              left: anchoActual * (20 / 360),
                              right: anchoActual * (20 / 360),
                              bottom: largoActual * (8 / 736),
                              top: largoActual * (8 / 736)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Productos',
                                    style: TextStyle(
                                        fontSize: largoActual * (13 / 736),
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromARGB(
                                            255, 1, 75, 135)),
                                  ),
                                  Text(
                                    'S/.$totalProvider',
                                    style: TextStyle(
                                        fontSize: largoActual * (13 / 736),
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromARGB(
                                            255, 1, 75, 135)),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Envio',
                                    style: TextStyle(
                                        fontSize: largoActual * (13 / 736),
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromARGB(
                                            255, 1, 75, 135)),
                                  ),
                                  Text(
                                    'S/.$envio',
                                    style: TextStyle(
                                        fontSize: largoActual * (13 / 736),
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromARGB(
                                            255, 1, 75, 135)),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ahorro',
                                    style: TextStyle(
                                        fontSize: largoActual * (13 / 736),
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromRGBO(
                                            234, 51, 98, 1.000)),
                                  ),
                                  Text(
                                    'S/.$ahorro',
                                    style: TextStyle(
                                        fontSize: largoActual * (13 / 736),
                                        fontWeight: FontWeight.w500,
                                        color: const Color.fromRGBO(
                                            234, 51, 98, 1.000)),
                                  )
                                ],
                              )
                            ],
                          )),
                    ),
                    SizedBox(
                      height: largoActual * (95 / 630),
                    ),
                  ],
                ),
              ))),
    );
  }
}
