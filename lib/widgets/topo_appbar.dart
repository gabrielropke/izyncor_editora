import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/store/base_store.dart';
import 'package:editora_izyncor_app/widgets/alerta_izyncor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class topo_appbar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const topo_appbar({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  State<topo_appbar> createState() => _topo_appbarState();
}

class _topo_appbarState extends State<topo_appbar> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? idUsuarioLogado;
  String? nome;
  String urlImagem = '';
  late GlobalKey<ScaffoldState> scaffoldKey;

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .doc(idUsuarioLogado)
          .get();
      if (userData.exists) {
        setState(() {
          urlImagem = userData['urlImagem'];
          nome = userData['nome'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    scaffoldKey = widget.scaffoldKey;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            scaffoldKey.currentState?.openDrawer();
          },
          child: ClipOval(
            child: Container(
              width: 33,
              height: 33,
              color: Colors.white,
              child: CachedNetworkImage(
                imageUrl: urlImagem,
                fit: BoxFit.cover, // ajuste de acordo com suas necessidades
                placeholder: (context, url) => const CircularProgressIndicator(
                  color: Colors.white,
                ), // um indicador de carregamento
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.white,
                ), // widget de erro
              ),
            ),
          ),
        ),
        Image.asset(
          'assets/icone_centro.png',
          width: 35,
        ),
        GestureDetector(
          onTap: () {
            AlertasIzyncor.mostrarAlerta(context, 'Esta função estará disponível apenas no lançamento oficial do app.');
          },
          child: Image.asset(
            'assets/shop_01.png',
            width: 21,
          ),
        ),
      ],
    );
  }
}
