import 'package:appsol_final/components/holaconductor.dart';
import 'package:appsol_final/components/holaconductor2.dart';
import 'package:appsol_final/components/login.dart';
import 'package:appsol_final/components/pdf.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
// Importa el paquete permission_handler



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
    // Inicializa permission_handler solicitando los permisos necesarios
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => UserProvider(),
    
      child: MaterialApp(
      //title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Pdf(),
    ) ,
    );
   
  }
}
