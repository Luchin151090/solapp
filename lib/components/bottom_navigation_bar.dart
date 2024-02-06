import 'package:flutter/material.dart';
import 'package:appsol_final/components/hola.dart';
import 'package:appsol_final/components/promos.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/components/productos.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BarraNavegacion extends StatefulWidget {
  const BarraNavegacion({Key? key}) : super(key: key);
  @override
  _BarraNavegacion createState() => _BarraNavegacion();
}

class _BarraNavegacion extends State<BarraNavegacion> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int indexSelecionado = 0;
  int numeroProductos = 0;
  final screens = [
    Hola2(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.home_rounded,
        color: Colors.white,
      ),
      Badge(
        largeSize: 13,
        //cambiar de color
        backgroundColor: Colors.grey,
        label: Text("$numeroProductos", style: const TextStyle(fontSize: 9)),
        child: const Icon(
          Icons.shopping_cart_rounded,
          color: Colors.white,
        ),
      ),
      const Icon(Icons.person, color: Colors.white)
    ];

    return Scaffold(
      //extendBody: true,
      body: screens[indexSelecionado],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: const Color.fromRGBO(0, 106, 252, 1.000),
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            indexSelecionado = index;
          });
          final navigationState = navigationKey.currentState!;
          navigationState.setPage(index);
        },
        index: indexSelecionado,
        items: items,
      ),
    );
  }
}
