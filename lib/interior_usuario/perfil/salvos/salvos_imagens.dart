import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/postagens_individuais.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalvosImagensPage extends StatefulWidget {
  @override
  _SalvosImagensPageState createState() => _SalvosImagensPageState();
}

class _SalvosImagensPageState extends State<SalvosImagensPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(idUsuarioLogado)
            .collection('salvos')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var salvosPost = snapshot.data?.docs;

          if (salvosPost!.isEmpty) {
            return const Center(
              child: Text(
                'Nada por aqui...',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black26,
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
          }

          List<DocumentSnapshot> salvos = snapshot.data!.docs;

          List<Widget> imageWidgets = salvos.map((salvo) {
            Map<String, dynamic> data = salvo.data() as Map<String, dynamic>;
            String imageUrl = data['imagemUrl'];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => postagens_individuais(
                            idPostagem: data['idPostagem'],
                            imagemPostagem: imageUrl)));
              },
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      if (imageUrl != 'vazio')
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CachedNetworkImage(imageUrl: imageUrl),
                        ),
                    ],
                  )),
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(6.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: imageWidgets,
            ),
          );
        },
      ),
    );
  }
}
