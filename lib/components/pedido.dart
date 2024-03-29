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
  //EL AHORRO ES IGUAL A 4 SOLES POR CADA BIDON NUEVO
  double ahorro = 0.0;
  double totalVenta = 0.0;
  double totalProvider = 0.0;
  double tamanoTitulos = 0.0;
  double tamanoTitulosDialogs = 0.0;
  double tamanoContenidoDialogs = 0.0;
  List<dynamic> seleccionadosTodos = [];
  List<Producto> seleccionadosProvider = [];
  List<Promo> selecciondosPromosProvider = [];
  String tipoPedido = "normal";
  TextEditingController notas = TextEditingController();
  TextEditingController _cupon = TextEditingController();
  String notasParaConductor = '';
  int lastPedido = 0;
  Color color = Colors.white;
  Color colorTitulos = const Color.fromARGB(255, 1, 42, 76);
  Color colorContenido = const Color.fromARGB(255, 1, 75, 135);
  Color colorCupon = Colors.white;
  Color colorDireccion = const Color.fromRGBO(234, 51, 98, 1.000);
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;
  //POR AHORA EL CLIENTE ES MANUAL!!""
  String direccion = 'Av. Las Flores 137 - Cayma';
  String mensajeCodigoExpirado = "";
  DateTime tiempoActual = DateTime.now();
  late DateTime tiempoPeru;
  int ubicacionSelectID = 0;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String codigoverify = '/api/code_cliente';
  String apiPedido = '/api/pedido';
  String apiDetallePedido = '/api/detallepedido';
  bool existe = false;
  bool buscandoCodigo = false;
  bool hayBidon = false;
  int cantidadBidones = 0;
  String? fechaLimiteString = '';
  DateTime fechaLimite = DateTime.now();
  DateTime fechaLimiteCliente = DateTime.now();

  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      print('es string');
      return DateTime.parse(fecha);
    } else {
      print('no es string');
      return DateTime.now();
    }
  }

  Future<dynamic> datosCreadoPedido(
      clienteId,
      fecha,
      subtotal,
      descuento,
      montoTotal,
      cantidadBidon,
      tipo,
      estado,
      notas,
      codigo,
      ubicacionID) async {
    print("-----------------------creandoPEDIDOO");
    await http.post(Uri.parse(apiUrl + apiPedido),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "subtotal": subtotal.toDouble(),
          "descuento": descuento.toDouble(),
          "total": montoTotal.toDouble(),
          "fecha": fecha,
          "tipo": tipo,
          "estado": estado,
          "ubicacion_id": ubicacionID,
          "codigo": codigo,
          "cantidad_bidones": cantidadBidon,
          "observacion": notas
        }));
  }

  Future<dynamic> detallePedido(
      clienteId, productoId, cantidad, promoID) async {
    await http.post(Uri.parse(apiUrl + apiDetallePedido),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "producto_id": productoId,
          "cantidad": cantidad,
          "promocion_id": promoID
        }));
  }

  Future<void> crearPedidoyDetallePedido(clienteID, tipo, subtotal, monto,
      descuento, seleccionados, notas, codigo, cantidadBidon) async {
    DateTime tiempoGMTPeru = tiempoActual.subtract(const Duration(hours: 0));
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });

    await datosCreadoPedido(
        clienteID,
        tiempoGMTPeru.toString(),
        subtotal,
        descuento,
        monto,
        cantidadBidon,
        tipo,
        "pendiente",
        notas,
        codigo,
        ubicacionSelectID);
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
        totalVenta = totalProvider + envio - ahorro;
        cantCarrito = pedido.cantidadProd;
        seleccionadosProvider = pedido.seleccionados;
        selecciondosPromosProvider = pedido.seleccionadosPromo;
        for (var i = 0; i < seleccionadosProvider.length; i++) {
          if (seleccionadosProvider[i].promoID == null) {
            seleccionadosTodos.add(seleccionadosProvider[i]);
          }
        }
        for (var i = 0; i < seleccionadosTodos.length; i++) {
          //si hay un bidon nuevo en los productos de la lista, solo productos
          //no promociones
          if (seleccionadosTodos[i].id == 4) {
            setState(() {
              hayBidon = true;
              cantidadBidones = seleccionadosTodos[i].cantidad;
            });
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
      limpiarVariables();
    }
  }

  void esUbicacion(UbicacionModel? ubicacion) {
    if (ubicacion is UbicacionModel) {
      print('ES UBIIIII');
      setState(() {
        ubicacionSelectID = ubicacion.id;
        direccion = ubicacion.direccion;
        colorDireccion = const Color.fromARGB(255, 1, 75, 135);
      });
    } else {
      print('no es ubi');
      setState(() {
        ubicacionSelectID = 0;
        direccion = "Seleccione una dirección, por favor";
      });
    }
  }

  Future<dynamic> cuponExist(cupon) async {
    print('entro a cupon Exists');
    var res = await http.post(Uri.parse(apiUrl + codigoverify),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({"codigo": cupon}));
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          existe = data['existe'];
          fechaLimiteString = data['fecha_creacion_cuenta'];
          print('CORRIO EL COSO');
          print(existe);
        });
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  void codigoPersonalVigente(String fecha) {
    fechaLimiteCliente = mesyAnio(fecha).add(const Duration(days: (30 * 3)));
    if (fechaLimiteCliente.day >= DateTime.now().day &&
        fechaLimiteCliente.month >= DateTime.now().month &&
        fechaLimiteCliente.year >= DateTime.now().year) {
      setState(() {
        mensajeCodigoExpirado =
            'Pero puedes compartir tu codigo con tus amigos para recibir beneficios ;D';
      });
    } else {
      setState(() {
        mensajeCodigoExpirado =
            'Pero puedes compartir la aplicacion con tus amigos, para recibir descuentos con sus codigos ;D';
      });
    }
  }

  void limpiarVariables() {
    setState(() {
      totalProvider = 0;
      seleccionadosProvider = [];
      selecciondosPromosProvider = [];
      seleccionadosTodos = [];
      cantCarrito = 0;
      hayBidon = false;
      cantidadBidones = 0;
      colorCantidadCarrito = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final pedidoProvider = context.watch<PedidoProvider>();
    final userProvider = context.watch<UserProvider>();
    final ubicacionProvider = context.watch<UbicacionProvider>();
    fechaLimiteCliente = mesyAnio(userProvider.user?.fechaCreacionCuenta);
    esUbicacion(ubicacionProvider.ubicacion);
    tamanoTitulos = largoActual * 0.021;
    tamanoTitulosDialogs = largoActual * 0.021;
    tamanoContenidoDialogs = largoActual * 0.018;

    setState(() {
      seleccionadosTodos = [];
    });
    esVacio(pedidoProvider.pedido);
    print("SELECCIONADOS TODOS");
    print(seleccionadosTodos);
    if (totalProvider != 0) {
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
                            onPressed: totalProvider > 0.0 &&
                                    ubicacionSelectID != 0
                                ? () async {
                                    await crearPedidoyDetallePedido(
                                        userProvider.user?.id,
                                        tipoPedido,
                                        totalProvider,
                                        totalVenta,
                                        ahorro,
                                        seleccionadosProvider,
                                        notas.text,
                                        _cupon.text,
                                        cantidadBidones);
                                    limpiarVariables();
                                    pedidoMio = PedidoModel(
                                        seleccionados: seleccionadosProvider,
                                        seleccionadosPromo:
                                            selecciondosPromosProvider,
                                        cantidadProd: cantCarrito,
                                        total: totalProvider);
                                    // ignore: use_build_context_synchronously
                                    Provider.of<PedidoProvider>(context,
                                            listen: false)
                                        .updatePedido(pedidoMio);
                                    // ignore: use_build_context_synchronously
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
                                  color:
                                      const Color.fromRGBO(0, 106, 252, 1.000),
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
                    limpiarVariables();
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
                              color: colorTitulos,
                              fontWeight: FontWeight.w600,
                              fontSize: tamanoTitulos),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                                    fontSize:
                                                        largoActual * 0.019,
                                                    color: colorContenido),
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
                                                      color: colorContenido),
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
                                                  color: colorContenido),
                                            ),
                                            Text(
                                              "Cant. ${seleccionadosTodos[index].cantidad}",
                                              style: TextStyle(
                                                  fontSize: largoActual * 0.018,
                                                  color: colorContenido),
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
                              color: colorTitulos,
                              fontWeight: FontWeight.w600,
                              fontSize: tamanoTitulos),
                        ),
                      ),
                      Card(
                        surfaceTintColor: colorCupon,
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
                                    color: colorContenido),
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
                              width: anchoActual * 0.01,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  buscandoCodigo = true;
                                });
                                await cuponExist(_cupon.text);
                                setState(() {
                                  fechaLimite = mesyAnio(fechaLimiteString)
                                      .add(const Duration(days: (30 * 3)));
                                  ;
                                });
                                print(fechaLimite);
                                if (existe) {
                                  //EXISTE EL CODIGO
                                  print("codigo válido");
                                  if (fechaLimite.day <= DateTime.now().day &&
                                      fechaLimite.month <=
                                          DateTime.now().month &&
                                      fechaLimite.year <= DateTime.now().year) {
                                    print("el codigo ya expiro");
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            title: Text(
                                              'El código que estas usando ya expiró :(',
                                              style: TextStyle(
                                                  fontSize:
                                                      tamanoTitulosDialogs),
                                            ),
                                            content: Text(
                                              'Pero todavìa puedes compartir tu codigo con tus amigos para recibir beneficios',
                                              style: TextStyle(
                                                  fontSize:
                                                      tamanoContenidoDialogs),
                                            ),
                                          );
                                        });
                                  } else {
                                    print('el codigo esta vigentee');
                                    if (hayBidon) {
                                      //SI HAY BIDONES NUEVOS EN LA LISTA DE PRODUCTOS
                                      print('hay bidones nuevos');
                                      setState(() {
                                        buscandoCodigo = false;
                                        colorCupon = const Color.fromRGBO(
                                            255, 0, 93, 1.000);
                                        ahorro = 4.0 * cantidadBidones;
                                        totalVenta =
                                            envio + totalProvider - ahorro;
                                      });
                                    } else {
                                      print('no hay bidones');
                                      setState(() {
                                        buscandoCodigo = false;
                                        colorCupon = Colors.white;
                                      });
                                      // ignore: use_build_context_synchronously
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              surfaceTintColor: Colors.white,
                                              title: Text(
                                                'Este codigo solo es valido para compras de Bidones Nuevos',
                                                style: TextStyle(
                                                    fontSize:
                                                        tamanoTitulosDialogs),
                                              ),
                                              content: Text(
                                                'Agrega un bidón nuevo a tu carrito para acceder a tu descuento ;)',
                                                style: TextStyle(
                                                    fontSize:
                                                        tamanoContenidoDialogs),
                                              ),
                                            );
                                          });
                                      //PONER SEÑAL DE QUE EL CODIGO SOLO EL VALIDO
                                      //DESUCENTO EN BIDONES NUEVOS
                                    }
                                  }
                                } else {
                                  //PONER UNA SEÑAL DE
                                  //QUE EL CODIGO NO EXISTE
                                  print("no existe el codigo");
                                  setState(() {
                                    buscandoCodigo = false;
                                    colorCupon = Colors.white;
                                  });
                                  // ignore: use_build_context_synchronously
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          title: Text(
                                            'El codigo que ingresaste no existe :(',
                                            style: TextStyle(
                                                fontSize: tamanoTitulosDialogs),
                                          ),
                                          content: Text(
                                            'Pruba ',
                                            style: TextStyle(
                                                fontSize:
                                                    tamanoContenidoDialogs),
                                          ),
                                        );
                                      });
                                }
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(5),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.247, largoActual * 0.052)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(255, 0, 93, 1.000)),
                              ),
                              child: buscandoCodigo
                                  ? SizedBox(
                                      height: largoActual * 0.02,
                                      width: largoActual * 0.02,
                                      child: const CircularProgressIndicator(
                                        color: Color.fromRGBO(253, 253, 253, 1),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
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
                              color: colorTitulos,
                              fontWeight: FontWeight.w600,
                              fontSize: tamanoTitulos),
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
                                        color: colorContenido),
                                  ),
                                  Text(
                                    'GRATIS',
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorContenido),
                                  ),
                                  Text(
                                    "Si lo pides después de la 1:00 P.M se agenda para mañana.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorContenido),
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
                                      .subtract(const Duration(hours: 0));
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
                                  if (tiempoPeru.hour <= 16) {
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
                                  totalVenta = totalProvider + envio - ahorro;
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
                                        color: colorContenido),
                                  ),
                                  Text('+ S/. 4.00',
                                      style: TextStyle(
                                          fontSize: largoActual * 0.013,
                                          color: colorContenido)),
                                  Text(
                                    "Recive tu producto más rapido y disfrútalo lo antes posible",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: largoActual * 0.013,
                                        color: colorContenido),
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
                          "A esta dirección enviaremos el pedido",
                          style: TextStyle(
                              color: colorTitulos,
                              fontWeight: FontWeight.w600,
                              fontSize: tamanoTitulos),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: anchoActual * 0.62,
                                    child: Text(
                                      direccion,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: largoActual * 0.017,
                                          color: colorDireccion),
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
                                    child:
                                        Lottie.asset('lib/imagenes/ubi4.json'),
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
                              color: colorTitulos,
                              fontWeight: FontWeight.w600,
                              fontSize: tamanoTitulos),
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
                            cursorColor:
                                const Color.fromRGBO(0, 106, 252, 1.000),
                            enableInteractiveSelection: false,
                            style: TextStyle(
                                fontSize: largoActual * 0.018,
                                color: colorContenido),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  'Ej. Casa con porton azúl, tocar tercer piso',
                              hintStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 195, 195, 195),
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
                              color: colorTitulos,
                              fontWeight: FontWeight.w600,
                              fontSize: tamanoTitulos),
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
                                          color: colorContenido),
                                    ),
                                    Text(
                                      'S/.$totalProvider',
                                      style: TextStyle(
                                          fontSize: largoActual * (13 / 736),
                                          fontWeight: FontWeight.w500,
                                          color: colorContenido),
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
                                          color: colorContenido),
                                    ),
                                    Text(
                                      'S/.$envio',
                                      style: TextStyle(
                                          fontSize: largoActual * (13 / 736),
                                          fontWeight: FontWeight.w500,
                                          color: colorContenido),
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
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          toolbarHeight: largoActual * 0.08,
        ),
        body: SafeArea(
            child: Center(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 0),
                height: largoActual * 0.9,
                width: anchoActual * 0.9,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Lottie.asset('lib/imagenes/carritovacio.json'),
              ),
              Positioned(
                  top: anchoActual *
                      0.6, // Ajusta la posición vertical según tus necesidades
                  left: anchoActual * 0.25,
                  child: Text(
                    'Tu carrito esta vacío',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 1, 42, 76),
                        fontWeight: FontWeight.w600,
                        fontSize: largoActual * 0.023),
                  )),
            ],
          ),
        )),
      );
    }
  }
}
