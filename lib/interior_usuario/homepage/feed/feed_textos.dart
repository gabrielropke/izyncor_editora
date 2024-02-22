import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/dados_autor_post.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_comentar.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_curtir.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_salvar.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/post_imagens.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_more.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/texto_editado.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:readmore/readmore.dart';

class FeedTextos extends StatefulWidget {
  const FeedTextos({super.key});

  @override
  State<FeedTextos> createState() => _FeedTextosState();
}

class _FeedTextosState extends State<FeedTextos> {
  FirebaseAuth auth = FirebaseAuth.instance;

  late List<Map<String, dynamic>> postagens;
  String? idUsuarioLogado;
  bool postagensCarregadas = false;

  recuperarDadosUsuario() {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  fetchFeed() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('feed').get();
    List<Map<String, dynamic>> novasPostagens = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> postagensData = {
        'imagemUrl': doc.get('imagemUrl'),
        'idPostagem': doc.get('idPostagem'),
        'autorId': doc.get('autorId'),
        'hora': doc.get('hora'),
        'curtidas': doc.get('curtidas'),
        'comentarios': doc.get('comentarios'),
        'legenda': doc.get('legenda'),
        'titulo': doc.get('titulo'),
        'editado': doc.get('editado'),
      };

      // Consulta para obter o nome do autor com base no 'autorId'
      DocumentSnapshot autorSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(doc.get('autorId'))
          .get();

      postagensData['nome'] = autorSnapshot.get('nome');
      postagensData['urlImagem'] = autorSnapshot.get('urlImagem');
      postagensData['sobrenome'] = autorSnapshot.get('sobrenome');
      postagensData['Cadastro'] = autorSnapshot.get('Cadastro');
      postagensData['seguidores'] = autorSnapshot.get('seguidores');
      postagensData['biografia'] = autorSnapshot.get('biografia');
      postagensData['username'] = autorSnapshot.get('username');

      novasPostagens.add(postagensData);
    }

    novasPostagens.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a['hora']);
      DateTime dateTimeB = DateTime.parse(b['hora']);
      return dateTimeB.compareTo(dateTimeA);
    });

    setState(() {
      postagens = novasPostagens;
    });
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    postagens = [];

    if (!postagensCarregadas) {
      // Chame fetchFeed() apenas na primeira vez que a tela for aberta
      fetchFeed();
      postagensCarregadas = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => fetchFeed(),
        child: FutureBuilder(
          // Consulta Firestore para verificar se a coleção "feed" está vazia
          future: FirebaseFirestore.instance.collection('feed').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Colors.white,
              ); // Mostra um indicador de carregamento enquanto consulta o Firestore
            } else if (snapshot.hasError) {
              return const Text("Erro ao carregar dados do Firestore");
            } else if (snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, color: Colors.black12, size: 82),
                    Text(
                      'Nenhuma postagem ainda... :(',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black26,
                          fontSize: 16),
                    )
                  ],
                ),
              ));
            } else {
              return ListView.builder(
                itemCount: postagens.length,
                itemBuilder: (context, index) {
                  var postagem = postagens[index];

                  return Visibility(
                    visible: postagem['imagemUrl'] != null &&
                        postagem['imagemUrl'] == 'vazio',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                      child: Column(
                        children: [
                          Column(
                            children: [
                              Visibility(
                                visible: postagem['imagemUrl'] != null &&
                                    postagem['imagemUrl'] == 'vazio',
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Row(
                                          children: [
                                            Text(
                                              postagem['titulo'],
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black),
                                            ),
                                            if (postagem['editado'] == 'sim')
                                              const Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  child: texto_editado(
                                                      corTexto:
                                                          Colors.black26)),
                                          ],
                                        ),
                                      ),
                                      icone_more(
                                        idUsuarioLogado: idUsuarioLogado!,
                                        autorId: postagem['autorId'],
                                        usernameAutor: postagem['username'],
                                        idPostagem: postagem['idPostagem'],
                                        legenda: postagem['legenda'],
                                        titulo: postagem['titulo'],
                                        imagemUrl: postagem['imagemUrl'],
                                        corBotao: Colors.black,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Visibility(
                                  visible: postagem['imagemUrl'] != null &&
                                      postagem['imagemUrl'] != 'vazio',
                                  child: Stack(
                                    children: [
                                      post_imagens(
                                          idUsuarioLogado: idUsuarioLogado!,
                                          autorId: postagem['autorId'],
                                          usernameAutor: postagem['username'],
                                          idPostagem: postagem['idPostagem'],
                                          legenda: postagem['legenda'],
                                          titulo: postagem['titulo'],
                                          imagemUrl: postagem['imagemUrl'],
                                          corBotao: Colors.white),
                                      if (postagem['editado'] == 'sim')
                                        const Positioned(
                                            top: 10,
                                            left: 10,
                                            child: texto_editado(
                                                corTexto: Colors.black26)),
                                      Positioned(
                                          top: 10,
                                          right: 10,
                                          child: icone_more(
                                            idUsuarioLogado: idUsuarioLogado!,
                                            autorId: postagem['autorId'],
                                            usernameAutor: postagem['username'],
                                            idPostagem: postagem['idPostagem'],
                                            legenda: postagem['legenda'],
                                            titulo: postagem['titulo'],
                                            imagemUrl: postagem['imagemUrl'],
                                            corBotao: Colors.white,
                                          )),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        child: Container(
                                          width: 400,
                                          height: 70,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 11,
                                          left: 11,
                                          child: dados_autor_post(
                                            idUsuarioLogado: idUsuarioLogado!,
                                            autorId: postagem['autorId'],
                                            usernameAutor: postagem['username'],
                                            idPostagem: postagem['idPostagem'],
                                            legenda: postagem['legenda'],
                                            titulo: postagem['titulo'],
                                            imagemUrl: postagem['imagemUrl'],
                                            corBotao: Colors.white,
                                            corTexto: Colors.white,
                                            nome: postagem['nome'],
                                            perfilAutor: postagem['urlImagem'],
                                            sobrenome: postagem['sobrenome'],
                                            cadastro: postagem['Cadastro'],
                                            hora: postagem['hora'],
                                          )),
                                      Positioned(
                                          bottom: 15,
                                          right: 0,
                                          child: Row(
                                            children: [
                                              icone_curtir(
                                                idUsuarioLogado:
                                                    idUsuarioLogado!,
                                                autorId: postagem['autorId'],
                                                usernameAutor:
                                                    postagem['username'],
                                                idPostagem:
                                                    postagem['idPostagem'],
                                                legenda: postagem['legenda'],
                                                titulo: postagem['titulo'],
                                                imagemUrl:
                                                    postagem['imagemUrl'],
                                                corBotao: Colors.white,
                                                corTexto: Colors.white,
                                                perfilAutor:
                                                    postagem['urlImagem'],
                                              ),
                                              icone_comentar(
                                                idUsuarioLogado:
                                                    idUsuarioLogado!,
                                                autorId: postagem['autorId'],
                                                usernameAutor:
                                                    postagem['username'],
                                                idPostagem:
                                                    postagem['idPostagem'],
                                                legenda: postagem['legenda'],
                                                titulo: postagem['titulo'],
                                                imagemUrl:
                                                    postagem['imagemUrl'],
                                                corBotao: Colors.white,
                                                corTexto: Colors.white,
                                              ),
                                              icone_salvar(
                                                idUsuarioLogado:
                                                    idUsuarioLogado!,
                                                autorId: postagem['autorId'],
                                                usernameAutor:
                                                    postagem['username'],
                                                idPostagem:
                                                    postagem['idPostagem'],
                                                legenda: postagem['legenda'],
                                                titulo: postagem['titulo'],
                                                imagemUrl:
                                                    postagem['imagemUrl'],
                                                corBotao: Colors.white,
                                                corTexto: Colors.white,
                                              ),
                                              const SizedBox(width: 15),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                              if (postagem['legenda'] != '')
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 15),
                                    child: ReadMoreText(
                                      postagem['legenda'],
                                      trimLines: 4,
                                      colorClickableText: Colors.blue,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'ver mais',
                                      trimExpandedText: ' ver menos',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              Visibility(
                                visible: postagem['imagemUrl'] != null &&
                                    postagem['imagemUrl'] == 'vazio',
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      dados_autor_post(
                                        idUsuarioLogado: idUsuarioLogado!,
                                        autorId: postagem['autorId'],
                                        usernameAutor: postagem['username'],
                                        idPostagem: postagem['idPostagem'],
                                        legenda: postagem['legenda'],
                                        titulo: postagem['titulo'],
                                        imagemUrl: postagem['imagemUrl'],
                                        corBotao: Colors.black,
                                        corTexto: Colors.black,
                                        nome: postagem['nome'],
                                        perfilAutor: postagem['urlImagem'],
                                        sobrenome: postagem['sobrenome'],
                                        cadastro: postagem['Cadastro'],
                                        hora: postagem['hora'],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              icone_curtir(
                                                  idUsuarioLogado:
                                                      idUsuarioLogado!,
                                                  autorId: postagem['autorId'],
                                                  usernameAutor:
                                                      postagem['username'],
                                                  idPostagem:
                                                      postagem['idPostagem'],
                                                  legenda: postagem['legenda'],
                                                  titulo: postagem['titulo'],
                                                  imagemUrl:
                                                      postagem['imagemUrl'],
                                                  corBotao:
                                                      const Color.fromARGB(
                                                          255, 70, 66, 66),
                                                  corTexto: Colors.black,
                                                  perfilAutor:
                                                      postagem['urlImagem'])
                                            ],
                                          ),
                                          icone_comentar(
                                            idUsuarioLogado: idUsuarioLogado!,
                                            autorId: postagem['autorId'],
                                            usernameAutor: postagem['username'],
                                            idPostagem: postagem['idPostagem'],
                                            legenda: postagem['legenda'],
                                            titulo: postagem['titulo'],
                                            imagemUrl: postagem['imagemUrl'],
                                            corBotao: const Color.fromARGB(
                                                255, 70, 66, 66),
                                            corTexto: Colors.black,
                                          ),
                                          const SizedBox(width: 5),
                                          icone_salvar(
                                            idUsuarioLogado: idUsuarioLogado!,
                                            autorId: postagem['autorId'],
                                            usernameAutor: postagem['username'],
                                            idPostagem: postagem['idPostagem'],
                                            legenda: postagem['legenda'],
                                            titulo: postagem['titulo'],
                                            imagemUrl: postagem['imagemUrl'],
                                            corBotao: const Color.fromARGB(
                                                255, 70, 66, 66),
                                            corTexto: Colors.black,
                                          ),
                                          const SizedBox(width: 15),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                color: Colors.black12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
