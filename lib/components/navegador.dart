import 'package:flutter/material.dart';
import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/perfilcliente.dart';
import 'package:appsol_final/components/promos.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/components/productos.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BarraNavegacion extends StatefulWidget {
  final int indice;
  final int subIndice;
  const BarraNavegacion(
      {required this.indice, required this.subIndice, Key? key})
      : super(key: key);

  @override
  State<BarraNavegacion> createState() => _BarraNavegacion();
}

class _BarraNavegacion extends State<BarraNavegacion> {
  int indexSelecionado = 0;
  final screensHola = [
    const Hola2(),
    const Promos(),
    const Productos(),
    const Pedido(),
  ];

  final screensMiPerfil = [
    const PerfilCliente(),
  ];
  //TODO ESTO ES MIOOIOOO
  @override
  Widget build(BuildContext context) {
    int subIndex = widget.subIndice;
    final screens = [screensHola, screensMiPerfil];
    final items = <Widget>[
      const Icon(
        Icons.home_rounded,
        color: Colors.white,
      ),
      const Icon(Icons.person, color: Colors.white),
    ];
    print('------  INICIALIZADOOO ------------');
    print('------  INDICEEEE');
    print(indexSelecionado);
    print('------SUBINDICE');
    print(subIndex);

    //ESTAS TRES LINEASSSS SON DE LUIS >:p
    if (subIndex > screens[indexSelecionado].length - 1) {
      print('es mayor');
      subIndex = 0;
    }
    //SOLO UNA IDEA NADA DE CODIGO
    return Scaffold(
      body: screens[indexSelecionado][subIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: const Color.fromRGBO(0, 106, 252, 1.000),
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            subIndex = 0;
            indexSelecionado = index;
            print('------  onTAPP ------------');
            print('------  INDICEEEE');
            print(indexSelecionado);
            print('------SUBINDICE');
            print(subIndex);
          });
        },
        index: indexSelecionado,
        items: items,
      ),
    );
  }
}
