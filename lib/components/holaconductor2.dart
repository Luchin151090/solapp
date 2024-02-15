import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HolaConductor2 extends StatefulWidget {
  const HolaConductor2({super.key});

  @override
  State<HolaConductor2> createState() => _HolaConductor2State();
}

class _HolaConductor2State extends State<HolaConductor2> {
  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        //key: _scaffoldKey,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    height: largoActual,
                    width: anchoActual,
                    child: Stack(children: [
                      FlutterMap(
                          options: const MapOptions(
                            initialCenter: LatLng(-16.4055561, -71.5712185),
                            initialZoom: 9.2,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                          ]),
                      Positioned(
                        bottom:
                            16.0, // Ajusta la posición vertical según tus necesidades
                        right:
                            16.0, // Ajusta la posición horizontal según tus necesidades
                        child: Container(
                          height: 40,
                          width: 40,
                          child: FloatingActionButton(
                            onPressed: () async {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: '12345678',
                              ); // Acciones al hacer clic en el FloatingActionButton
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                print('no se puede llamar');
                              }
                            },
                            backgroundColor: Color.fromARGB(255, 53, 142, 80),
                            child: const Icon(Icons.call, color: Colors.white),
                          ),
                        ),
                      ),
                    ])))));
  }
}
