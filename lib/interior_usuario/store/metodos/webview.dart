import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class mp_tela extends StatefulWidget {
  final String titulo;
  final String isbn;
  final String valor;
  final String nomeUsuario;
  final String emailUsuario;
  const mp_tela(
      {super.key,
      required this.titulo,
      required this.isbn,
      required this.valor,
      required this.nomeUsuario,
      required this.emailUsuario});

  @override
  State<mp_tela> createState() => _mp_telaState();
}

class _mp_telaState extends State<mp_tela> {
  String productionInitPoint = '';

  late String titulo;
  late String isbn;
  late String valor;
  late String nomeUsuario;
  late String emailUsuario;

  @override
  void initState() {
    super.initState();
    titulo = widget.titulo;
    isbn = widget.isbn;
    valor = widget.valor;
    nomeUsuario = widget.nomeUsuario;
    emailUsuario = widget.emailUsuario;
    _getCurrentUserUid();
    _loadProductionInitPoint();
  }

  Future<String?> _getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  Future<void> _loadProductionInitPoint() async {
    try {
      final apiUrl =
          'https://api-checkout-izyncor.onrender.com/generate_init_point';
      final productData = {
        'titulo': titulo,
        'isbn': isbn,
        'valor': valor,
        'uid': await _getCurrentUserUid(), // Obter o UID do usuário logado
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('init_point')) {
          setState(() {
            productionInitPoint = responseData['init_point'];
          });
        } else {
          throw Exception('Production init point not found in response data.');
        }
      } else {
        throw Exception('Failed to generate production init point.');
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            productionInitPoint.isNotEmpty // Check if the variable is not empty
                ? WebView(
                    initialUrl: productionInitPoint,
                    javascriptMode: JavascriptMode.unrestricted,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color.fromARGB(255, 231, 0, 89),
                            size: 50),
                        const Text('Aguenta as pontas aí!!',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                      ],
                    ),
                  ),
      ),
    );
  }
}
