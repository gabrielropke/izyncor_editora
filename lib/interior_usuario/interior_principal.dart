import 'dart:async';
import 'dart:convert';
import 'package:editora_izyncor_app/configuracao/tela_config.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/feed.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/novidades/novidades.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class principal extends StatefulWidget {
  const principal({super.key});

  @override
  State<principal> createState() => _principalState();
}

class _principalState extends State<principal> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _idUsuarioLogado;
  String? nome;

  void _subirCompras() async {
    String name = 'Teste enviado';
    int age = int.tryParse('23') ?? 0;

    if (name.isNotEmpty && age > 0) {
      try {
        await _firestore.collection('teste').add({
          'name': name,
          'age': age,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Data saved successfully!');
      } catch (e) {
        print('Error saving data: $e');
      }
    } else {
      print('Invalid data');
    }
  }

  Future<void> checkPurchaseStatus(String paymentId) async {
    try {
      final apiUrl =
          'https://api-checkout-izyncor.onrender.com/check_purchase_status/1317029473';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'];
        final message = responseData['message'];

        print('Status da compra: $status');
        print('Mensagem: $message');
      } else {
        throw Exception('Failed to check purchase status.');
      }
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }

  _recuperarDadosUsuarioString() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    nome = dados['nome'];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuarioString();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            foregroundColor: Colors.black,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Image.asset(
              'assets/izyncor.png',
              width: 100, // ajuste a largura conforme necessário
              height: 40, // ajuste a altura conforme necessário
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const home_config())));
                },
                icon: const Icon(
                  Icons.settings_suggest_rounded,
                  color: Colors.black,
                ),
              )
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 244, 244, 243),
                      borderRadius: BorderRadius.circular(2)),
                  child: TabBar(
                      indicator: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 244, 244, 243),
                            width: 3),
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      labelColor: Color.fromARGB(255, 0, 0, 0),
                      unselectedLabelColor: Color.fromARGB(255, 211, 207, 207),
                      tabs: const [
                        Tab(
                          child: Text(
                            'Feed',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Novidades',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ]),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Expanded(
                child: TabBarView(children: [
                  feed(),
                  novidades(),
                ]),
              )
            ],
          ),
        ));
  }
}
