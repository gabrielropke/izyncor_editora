import 'package:editora_izyncor_app/api/firebase_api.dart';
import 'package:editora_izyncor_app/autenticacao/Login/tela_login_usuario.dart';
import 'package:editora_izyncor_app/widgets/notification_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAPI().initNotification();

  runApp(const MyApp());
}

// DEU CERTO A BRANCH
// DEU CERTO A BRANCH
// DEU CERTO A BRANCH
// DEU CERTO A BRANCH
// DEU CERTO A BRANCH

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Izyncor',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      debugShowCheckedModeBanner: false,
      home: const login(
        statusInicial: 0,
      ),
      routes: {
        NotificationScreen.route:(context) => const NotificationScreen()
      },
    );
  }
}
