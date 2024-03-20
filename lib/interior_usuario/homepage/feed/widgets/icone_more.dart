import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/denuncias/denunciar.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/processo_postagem/editar_postagem.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:flutter/material.dart';

class icone_more extends StatefulWidget {
  final String idUsuarioLogado;
  final String autorId;
  final String usernameAutor;
  final String idPostagem;
  final String legenda;
  final String titulo;
  final String imagemUrl;
  final Color corBotao;
  const icone_more(
      {super.key,
      required this.idUsuarioLogado,
      required this.autorId,
      required this.usernameAutor,
      required this.idPostagem,
      required this.legenda,
      required this.titulo,
      required this.imagemUrl,
      required this.corBotao});

  @override
  State<icone_more> createState() => _icone_moreState();
}

class _icone_moreState extends State<icone_more> {
  late List<Map<String, dynamic>> postagens;
  late String idUsuarioLogado;
  late String autorId;
  late String usernameAutor;
  late String idPostagem;
  late String legenda;
  late String titulo;
  late String imagemUrl;
  late Color corBotao;

  @override
  void initState() {
    super.initState();
    idUsuarioLogado = widget.idUsuarioLogado;
    autorId = widget.autorId;
    usernameAutor = widget.usernameAutor;
    idPostagem = widget.idPostagem;
    legenda = widget.legenda;
    titulo = widget.titulo;
    imagemUrl = widget.imagemUrl;
    corBotao = widget.corBotao;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          void verItem(BuildContext context) {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                      20.0), // Defina o raio para bordas arredondadas superiores
                ),
              ),
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
                    // ListTile(
                    //   leading: SizedBox(
                    //       width: 25, child: Image.asset('assets/copiar.png')),
                    //   title: const Text('Copiar url'),
                    //   onTap: () {
                    //     // Lógica de copiar URL
                    //     Navigator.pop(context);
                    //   },
                    // ),
                    if (idUsuarioLogado != autorId)
                      ListTile(
                        leading: SizedBox(
                            width: 30,
                            child: Image.asset('assets/denunciar_01.png')),
                        title: const Text(
                          'Denunciar',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.red),
                        ),
                        onTap: () {
                          // Lógica de copiar URL
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => denunciar(
                                        idPostagem: idPostagem,
                                        autor: autorId,
                                        nomeAutor: usernameAutor,
                                      )));
                        },
                      ),
                    Visibility(
                      visible: autorId == idUsuarioLogado,
                      child: ListTile(
                        leading: SizedBox(
                            width: 25,
                            child: Image.asset('assets/lixeira.png')),
                        title: const Text('Excluir'),
                        onTap: () async {
                          void excluirPost(String titulo) {
                            if (autorId == idUsuarioLogado) {
                              CollectionReference novidadesCollection =
                                  FirebaseFirestore.instance.collection('feed');

                              // Excluir o documento do Firestore
                              novidadesCollection.doc(idPostagem).delete();

                              FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(idUsuarioLogado)
                                  .update({
                                'postagens': FieldValue.increment(-1),
                              });

                              setState(() {
                                postagens.removeWhere((postagem) =>
                                    postagem['idPostagem'] ==
                                    postagem['idPostagem']);
                              });
                            }
                          }

                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const home_principal(indexPagina: 1)));
                          excluirPost(idPostagem);
                        },
                      ),
                    ),
                    Visibility(
                      visible: autorId == idUsuarioLogado,
                      child: ListTile(
                        leading: SizedBox(
                            width: 25,
                            child: Image.asset('assets/textos_02.png')),
                        title: const Text('Editar'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => editar_postagem(
                                        idPostagem: idPostagem,
                                        legenda: legenda,
                                        imagemPostagem: imagemUrl,
                                        titulo: titulo,
                                      )));
                        },
                      ),
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

          verItem(context);
        },
        child: Icon(Icons.more_horiz, color: corBotao, size: 26));
  }
}
