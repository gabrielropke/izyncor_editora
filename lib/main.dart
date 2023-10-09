import 'package:editora_izyncor_app/autenticacao/Login/tela_login_usuario.dart';
import 'package:editora_izyncor_app/model/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDOnVICN0s5Tq7zcYjxcLGacTuzqRqQK_4',
          appId: '1:809408569788:android:ab33c74d2a5a1eebfc0bb9',
          messagingSenderId: '809408569788',
          projectId: 'izyncor-app-949df'));

  await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blueGrey),
        debugShowCheckedModeBanner: false,
        home: login());
  }
}
