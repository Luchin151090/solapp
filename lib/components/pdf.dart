import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';


class Pdf extends StatefulWidget {
  const Pdf({Key? key}) : super(key: key);

  @override
  State<Pdf> createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  String pathh = "";

  Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }

  Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/$name');
    print("----${dir.path}");

    await file.writeAsBytes(bytes);

    return file;
  }

  Future<File> _createPDF(String text) async {
    // imagenes
    final ByteData logoEmpresa =
        await rootBundle.load('lib/imagenes/logo_sol_tiny.png');
    Uint8List logoData = (logoEmpresa).buffer.asUint8List();

    final ByteData imagenPedido =
        await rootBundle.load('lib/imagenes/express.png');
    Uint8List finalPedido = (imagenPedido).buffer.asUint8List();

    print(".......dentro d create");
    final pdf = pw.Document();

   

    // SECCION 1
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:const pw.EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: 20
        ),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Titulos
              pw.Center(
                child:  pw.Text("Informe de ventas",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      )),
                
              ),

              // FECHA
              pw.Center(
                child: pw.Text(
                      "Del: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 20,
                      )),
                
              ),

              // DATOS PERSONALES
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                        //color: PdfColor.fromHex('#4B366A'),
                        padding: const pw.EdgeInsets.all(5),
                        decoration: pw.BoxDecoration(
                            borderRadius: pw.BorderRadius.circular(20)),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("Nombres: ",
                                  style: const pw.TextStyle(fontSize: 20)),
                              pw.Text("Apellidos: ",
                                  style: const pw.TextStyle(fontSize: 20)),
                              pw.Text("Dni: ",
                                  style: const pw.TextStyle(fontSize: 20)),
                              pw.Text("Cargo: Conductor",
                                  style: const pw.TextStyle(fontSize: 20))
                            ])),
                    pw.Container(
                        height: 100,
                        width: 100,
                        child: pw.Image(pw.MemoryImage(logoData)))
                  ]),
              pw.SizedBox(height: 5),


              // TITULO
              pw.Container(
                  child: pw.Text(
                      "1.- Detalle de pedidos entregados y pendientes"
                          .toUpperCase(),
                      style: pw.TextStyle(
                          fontSize: 15, fontWeight: pw.FontWeight.bold))),

              pw.SizedBox(
                height: 10,
              ),

              // INFORME
              pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 18),
                  child: pw.Table(border: pw.TableBorder.all(), children: [
                    // HEADER
                    pw.TableRow(children: [
                      pw.Text("Ruta",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Cliente",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Descuento",
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ]),
                    // DATA
                    pw.TableRow(children: [
                      pw.Text("data 1"),
                      pw.Text("data 2"),
                      pw.Text("data 3"),
                    ]),
                  ])),

             
              
            ],
          ),
        ],
      ),
    );

    // SECCION 2
    pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.only(top: 20, left: 10, right: 10),
    build: (context) => [
      // TITULO
      pw.Container(
        child: pw.Text(
          "2.- Vendidos por c/presentación".toUpperCase(),
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),

      pw.SizedBox(height: 10),

      // INFORME
      pw.Container(
        margin: pw.EdgeInsets.only(bottom: 18),
        child: pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // HEADER
            pw.TableRow(
              children: [
                pw.Text(
                  "Ruta",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Cliente",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Descuento",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            // DATA
            pw.TableRow(
              children: [
                pw.Text("data 1"),
                pw.Text("data 2"),
                pw.Text("data 3"),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);

// SECCION 3
pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin:const pw.EdgeInsets.only(top: 20, left: 10, right: 10),
    build: (context) => [
      // TITULO
      pw.Container(
        child: pw.Text(
          "3.- Filtrado de precios a distintos montos (para recarga)".toUpperCase(),
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),

      pw.SizedBox(height: 10),

      // INFORME
      pw.Container(
        margin: pw.EdgeInsets.only(bottom: 18),
        child: pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // HEADER
            pw.TableRow(
              children: [
                pw.Text(
                  "Ruta",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Cliente",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Descuento",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            // DATA
            pw.TableRow(
              children: [
                pw.Text("data 1"),
                pw.Text("data 2"),
                pw.Text("data 3"),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);

// SECCION 4
pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.only(top: 20, left: 10, right: 10),
    build: (context) => [
      // TITULO
      pw.Container(
        child: pw.Text(
          "4.- Filtrado de precios a distintos montos (para bidón) ".toUpperCase(),
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),

      pw.SizedBox(height: 10),

      // INFORME
      pw.Container(
        margin: pw.EdgeInsets.only(bottom: 18),
        child: pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // HEADER
            pw.TableRow(
              children: [
                pw.Text(
                  "Ruta",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Cliente",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Descuento",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            // DATA
            pw.TableRow(
              children: [
                pw.Text("data 1"),
                pw.Text("data 2"),
                pw.Text("data 3"),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);

pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.only(top: 20, left: 10, right: 10),
    build: (context) => [
      // TITULO
      pw.Container(
        child: pw.Text(
          "5.- Filtrado de pagos por efectivo y digital".toUpperCase(),
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
      ),

      pw.SizedBox(height: 10),

      // INFORME
      pw.Container(
        margin:const pw.EdgeInsets.only(bottom: 18),
        child: pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // HEADER
            pw.TableRow(
              children: [
                pw.Text(
                  "Ruta",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Cliente",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  "Descuento",
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            // DATA
            pw.TableRow(
              children: [
                pw.Text("data 1"),
                pw.Text("data 2"),
                pw.Text("data 3"),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
);

    // SECCION 4
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
          bottom: 20
        ),
        build: (context) => [
          pw.Container(
                  child: pw.Text(
                      "6.- Imágenes de los pedidos pagados vía digital"
                          .toUpperCase(),
                      style: pw.TextStyle(
                          fontSize: 15, fontWeight: pw.FontWeight.bold))),
              pw.Container(
                  child: pw.ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return pw.Center(
                      child: pw.Container(
                          margin: const pw.EdgeInsets.only(top: 10, bottom: 10),
                          height: 400,
                          width: 500,
                          child: pw.Image(pw.MemoryImage(finalPedido))));
                },
              ))
        ]
      )
    );

    return saveDocument(
        name:
            'informe_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
        pdf: pdf);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(children: [
            Container(
              child: const Text("s"),
            ),
            Container(
              child: Text("path ${pathh}"),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  final pdfFile = await _createPDF('Sample Text');

                  openFile(pdfFile);
                },
                child: Text("DESCARGAR"),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
