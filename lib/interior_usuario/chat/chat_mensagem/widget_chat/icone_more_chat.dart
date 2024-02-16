import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/denuncias/denunciar.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:flutter/material.dart';

class icone_more_chat extends StatelessWidget {
  const icone_more_chat(
      {super.key,
      required this.idUsuarioLogado,
      required this.idUsuarioDestino,
      required this.imagemPerfil,
      required this.usernameDestino});

  final String idUsuarioLogado;
  final String idUsuarioDestino;
  final String imagemPerfil;
  final String usernameDestino;

  void apagarConversa() async {
    var colecaoParaApagar = FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioLogado)
        .collection(idUsuarioDestino);

    var documentosParaApagar = await colecaoParaApagar.get();

    for (var documento in documentosParaApagar.docs) {
      await colecaoParaApagar.doc(documento.id).delete();
    }
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(idUsuarioLogado)
        .delete();
  }

  void icone_selecao(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        top: Radius.circular(20.0),
      )),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            ListTile(
              title: const Text('Ver perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => perfil_visita(
                            uidPerfil: idUsuarioDestino,
                            nome: 'nome',
                            imagemPerfil: imagemPerfil,
                            sobrenome: 'sobrenome',
                            cadastro: 'cadastro')));
              },
            ),
            ListTile(
              title: const Text('Denunciar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => denunciar(
                            idPostagem: 'perfil',
                            autor: idUsuarioDestino,
                            nomeAutor: usernameDestino)));
              },
            ),
            ListTile(
              title: const Text('Bloquear'),
              onTap: () {
                print('id: $idUsuarioDestino');
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              title: const Text('Limpar conversa'),
              onTap: () {
                Navigator.pop(context);
                apagarConversa();
              },
            ),
            if (Platform.isIOS)
              const SizedBox(
                width: double.infinity,
                height: 40,
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          icone_selecao(context);
        },
        child: const Padding(
          padding: EdgeInsets.only(right: 15),
          child: Icon(Icons.more_horiz, color: Colors.black, size: 26),
        ));
  }
}
