import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HolaConductor2 extends StatefulWidget {
  const HolaConductor2({super.key});

  @override
  State<HolaConductor2> createState() => _HolaConductor2State();
}

class _HolaConductor2State extends State<HolaConductor2> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    //mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(51.509364, -0.128928),
                                initialZoom: 9.2,
                              ),
                              children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                          ]))
                    ]))));
  }
}
