import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/comentarios/listview_comentarios.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/dados_autor_post.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_comentar.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_curtir.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_more.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/icone_salvar.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/post_imagens.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/texto_editado.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class postagens_individuais extends StatefulWidget {
  final String idPostagem;
  final String imagemPostagem;
  const postagens_individuais(
      {super.key, required this.idPostagem, required this.imagemPostagem});

  @override
  State<postagens_individuais> createState() => _postagens_individuaisState();
}

class _postagens_individuaisState extends State<postagens_individuais> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late String idPostagem;
  late String imagemPostagem;
  String perfilAutor = '';
  String hora = '';
  String username = '';
  String legenda = '';
  String titulo = '';
  String editado = '';
  String nome = '';
  String autorId = '';
  String sobrenome = '';
  String cadastro = '';
  String? idUsuarioLogado;

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
          // nome = userData['nome'];
        });
      }
    }
  }

  String formatDataHora(String dateTimeString) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.parse(dateTimeString);
    Duration difference = now.difference(dateTime);

    if (difference < Duration(minutes: 1)) {
      return 'Agora mesmo';
    } else if (difference < Duration(minutes: 2)) {
      return 'Há ${difference.inMinutes} minuto';
    } else if (difference < Duration(hours: 1)) {
      int minutes = difference.inMinutes;
      return 'Há $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else if (difference < Duration(days: 1)) {
      int hours = difference.inHours;
      return 'Há $hours ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference < Duration(days: 2)) {
      return 'Há ${difference.inDays} dia';
    } else if (difference < Duration(days: 30)) {
      return 'Há ${difference.inDays} dias';
    } else if (difference < Duration(days: 365)) {
      int months = difference.inDays ~/ 30;
      return 'Há $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      int years = difference.inDays ~/ 365;
      return 'Há $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  void carregarDadosPostagem() {
    FirebaseFirestore.instance
        .collection('feed')
        .doc(idPostagem)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          hora = doc.data()?['hora'] ?? '';
          autorId = doc.data()?['autorId'] ?? '';
          legenda = doc.data()?['legenda'] ?? '';
          titulo = doc.data()?['titulo'] ?? '';
          editado = doc.data()?['editado'] ?? '';
        });

        // Agora, vamos buscar o nome do autor usando o autorId
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(autorId)
            .get()
            .then((usuarioDoc) {
          if (usuarioDoc.exists) {
            setState(() {
              // Adicione a linha a seguir para atribuir o valor de 'nome'
              nome = usuarioDoc.data()?['nome'] ?? '';
              sobrenome = usuarioDoc.data()?['sobrenome'] ?? '';
              cadastro = usuarioDoc.data()?['Cadastro'] ?? '';
              username = usuarioDoc.data()?['username'] ?? '';
              perfilAutor = usuarioDoc.data()?['urlImagem'] ?? '';
            });
          }
        }).catchError((error) {
          print('Erro ao carregar os dados do usuário: $error');
        });
      }
    }).catchError((error) {
      print('Erro ao carregar os dados: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    idPostagem = widget.idPostagem;
    imagemPostagem = widget.imagemPostagem;
    recuperarDadosUsuario();
    carregarDadosPostagem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: Text('Postagens de $nome'),
      ),
      body: perfilAutor.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Visibility(
                  visible: imagemPostagem != 'vazio',
                  child: Stack(
                    children: [
                      post_imagens(
                          idUsuarioLogado: idUsuarioLogado!,
                          autorId: autorId,
                          usernameAutor: username,
                          idPostagem: idPostagem,
                          legenda: legenda,
                          titulo: titulo,
                          imagemUrl: imagemPostagem,
                          corBotao: Colors.white),
                      if (editado == 'sim')
                        const Positioned(
                            top: 10,
                            left: 10,
                            child: texto_editado(corTexto: Colors.black26)),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: icone_more(
                            idUsuarioLogado: idUsuarioLogado!,
                            autorId: autorId,
                            usernameAutor: username,
                            idPostagem: idPostagem,
                            legenda: legenda,
                            titulo: titulo,
                            imagemUrl: imagemPostagem,
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
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (autorId == idUsuarioLogado) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                const perfil()),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: ((context) =>
                                                perfil_visita(
                                                  uidPerfil: autorId,
                                                  nome: nome,
                                                  imagemPerfil: perfilAutor,
                                                  sobrenome: sobrenome,
                                                  cadastro: cadastro,
                                                )),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: perfilAutor,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: autorId != idUsuarioLogado,
                                    child: Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipOval(
                                          child: Material(
                                            color: const Color.fromARGB(
                                                255, 202, 30, 82),
                                            child: InkWell(
                                              onTap: () {
                                                void seguirUsuario(
                                                    String titulo) {
                                                  CollectionReference
                                                      novidadesCollection =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'usuarios');

                                                  // Verificar se o idUsuarioLogado já existe na coleção de curtir
                                                  novidadesCollection
                                                      .doc(autorId)
                                                      .collection('seguidores')
                                                      .doc(idUsuarioLogado)
                                                      .get()
                                                      .then((doc) {
                                                    if (doc.exists) {
                                                      doc.reference
                                                          .delete()
                                                          .then((_) {
                                                        novidadesCollection
                                                            .doc(autorId)
                                                            .update({
                                                          'seguidores':
                                                              FieldValue
                                                                  .increment(
                                                                      -1),
                                                        });
                                                      });
                                                    } else {
                                                      Map<String, dynamic>
                                                          seguidoresData = {
                                                        'hora': DateTime.now()
                                                            .toString(),
                                                        'uidusuario':
                                                            idUsuarioLogado,
                                                      };

                                                      novidadesCollection
                                                          .doc(autorId)
                                                          .collection(
                                                              'seguidores')
                                                          .doc(idUsuarioLogado)
                                                          .set(seguidoresData)
                                                          .then((_) {
                                                        novidadesCollection
                                                            .doc(autorId)
                                                            .update({
                                                          'seguidores':
                                                              FieldValue
                                                                  .increment(1),
                                                        });
                                                      });
                                                    }
                                                  });
                                                }

                                                seguirUsuario(autorId);
                                              },
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: StreamBuilder<
                                                    DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('usuarios')
                                                      .doc(autorId)
                                                      .collection('seguidores')
                                                      .doc(idUsuarioLogado)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData ||
                                                        !snapshot
                                                            .data!.exists) {
                                                      // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                                      return const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 16,
                                                      );
                                                    }

                                                    // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                                    return const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size:
                                                          16, // Ou qualquer outra cor desejada
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  if (autorId == idUsuarioLogado) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) => const perfil()),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) => perfil_visita(
                                              uidPerfil: autorId,
                                              nome: nome,
                                              imagemPerfil: perfilAutor,
                                              sobrenome: sobrenome,
                                              cadastro: cadastro,
                                            )),
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      nome,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      formatDataHora(hora),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Positioned(
                          bottom: 15,
                          right: 0,
                          child: Row(
                            children: [
                              icone_curtir(
                                idUsuarioLogado: idUsuarioLogado!,
                                autorId: autorId,
                                usernameAutor: username,
                                idPostagem: idPostagem,
                                legenda: legenda,
                                titulo: titulo,
                                imagemUrl: imagemPostagem,
                                corBotao: Colors.white,
                                corTexto: Colors.white,
                                perfilAutor: perfilAutor,
                              ),
                              icone_comentar(
                                idUsuarioLogado: idUsuarioLogado!,
                                autorId: autorId,
                                usernameAutor: username,
                                idPostagem: idPostagem,
                                legenda: legenda,
                                titulo: titulo,
                                imagemUrl: imagemPostagem,
                                corBotao: Colors.white,
                                corTexto: Colors.white,
                              ),
                              icone_salvar(
                                idUsuarioLogado: idUsuarioLogado!,
                                autorId: autorId,
                                usernameAutor: username,
                                idPostagem: idPostagem,
                                legenda: legenda,
                                titulo: titulo,
                                imagemUrl: imagemPostagem,
                                corBotao: Colors.white,
                                corTexto: Colors.white,
                              ),
                              const SizedBox(width: 15),
                            ],
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                      visible: imagemPostagem == 'vazio',
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        titulo,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                      if (editado == 'sim')
                                        const Positioned(
                                            top: 10,
                                            left: 10,
                                            child: texto_editado(
                                                corTexto: Colors.black26)),
                                    ],
                                  ),
                                ),
                                icone_more(
                                  idUsuarioLogado: idUsuarioLogado!,
                                  autorId: autorId,
                                  usernameAutor: username,
                                  idPostagem: idPostagem,
                                  legenda: legenda,
                                  titulo: titulo,
                                  imagemUrl: imagemPostagem,
                                  corBotao: Colors.black,
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, left: 15),
                              child: ReadMoreText(
                                legenda,
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
                            visible: imagemPostagem == 'vazio',
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  dados_autor_post(
                                    idUsuarioLogado: idUsuarioLogado!,
                                    autorId: autorId,
                                    usernameAutor: username,
                                    idPostagem: idPostagem,
                                    legenda: legenda,
                                    titulo: titulo,
                                    imagemUrl: imagemPostagem,
                                    corBotao: Colors.black,
                                    corTexto: Colors.black,
                                    nome: nome,
                                    perfilAutor: perfilAutor,
                                    sobrenome: sobrenome,
                                    cadastro: cadastro,
                                    hora: hora,
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          icone_curtir(
                                              idUsuarioLogado: idUsuarioLogado!,
                                              autorId: autorId,
                                              usernameAutor: username,
                                              idPostagem: idPostagem,
                                              legenda: legenda,
                                              titulo: titulo,
                                              imagemUrl: imagemPostagem,
                                              corBotao: const Color.fromARGB(
                                                  255, 70, 66, 66),
                                              corTexto: Colors.black,
                                              perfilAutor: perfilAutor)
                                        ],
                                      ),
                                      icone_comentar(
                                        idUsuarioLogado: idUsuarioLogado!,
                                        autorId: autorId,
                                        usernameAutor: username,
                                        idPostagem: idPostagem,
                                        legenda: legenda,
                                        titulo: titulo,
                                        imagemUrl: imagemPostagem,
                                        corBotao:
                                            const Color.fromARGB(255, 70, 66, 66),
                                        corTexto: Colors.black,
                                      ),
                                      const SizedBox(width: 5),
                                      icone_salvar(
                                        idUsuarioLogado: idUsuarioLogado!,
                                        autorId: autorId,
                                        usernameAutor: username,
                                        idPostagem: idPostagem,
                                        legenda: legenda,
                                        titulo: titulo,
                                        imagemUrl: imagemPostagem,
                                        corBotao:
                                            const Color.fromARGB(255, 70, 66, 66),
                                        corTexto: Colors.black,
                                      ),
                                      const SizedBox(width: 15),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(),
                        ],
                      )),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: listview_comentarios(idPostagem: idPostagem),
                ))
              ],
            ),
    );
  }
}
