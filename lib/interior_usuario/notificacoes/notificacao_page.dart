import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/mensagens_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/postagens_individuais.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class notificacao_page extends StatefulWidget {
  const notificacao_page({super.key});

  @override
  State<notificacao_page> createState() => _notificacao_pageState();
}

class _notificacao_pageState extends State<notificacao_page> {
  FirebaseFirestore notificacoes = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;

  String nome = '';
  String sobrenome = '';

  void showAlertAtencao() {
    QuickAlert.show(
        context: context,
        title: 'Atenção',
        text: 'Deseja realmente excluir todas as notificações?',
        confirmBtnText: 'Sim',
        onConfirmBtnTap: () {
          excluirPostGeral();
          Navigator.pop(context);
        },
        type: QuickAlertType.error);
  }

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
      return 'Há ${difference.inMinutes} minutos';
    } else if (difference < Duration(days: 1)) {
      return 'Há ${difference.inHours} horas';
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

  Future<Map<String, String>?> recuperarDadosPerfilDestino(
      String idPerfil) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> perfilData =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(idPerfil)
              .get();

      if (perfilData.exists) {
        String nome = perfilData['nome'];
        String sobrenome = perfilData[
            'sobrenome']; // Assuming 'sobrenome' is a field in your Firestore document
        return {'nome': nome, 'sobrenome': sobrenome};
      } else {
        return null; // Return null if the document doesn't exist
      }
    } catch (e) {
      print('Error fetching data from Firestore: $e');
      return null;
    }
  }

  void selecionarItem(BuildContext context, String index) {
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
            ListTile(
              leading:
                  SizedBox(width: 25, child: Image.asset('assets/lixeira.png')),
              title: const Text('Excluir'),
              onTap: () {
                excluirPost(index);
                Navigator.pop(context);
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

  void excluirPost(String index) {
    if (idUsuarioLogado != null) {
      CollectionReference novidadesCollection =
          FirebaseFirestore.instance.collection('usuarios');

      // Excluir o documento do Firestore
      novidadesCollection
          .doc(idUsuarioLogado)
          .collection('notificacoes')
          .doc(index)
          .delete();
    }
  }

  void excluirPostGeral() {
    if (idUsuarioLogado != null) {
      CollectionReference notificacoesCollection =
          FirebaseFirestore.instance.collection('usuarios');

      CollectionReference notificacoesRef = notificacoesCollection
          .doc(idUsuarioLogado)
          .collection('notificacoes');

      notificacoesRef.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Notificações'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                showAlertAtencao();
              },
              child:
                  SizedBox(width: 22, child: Image.asset('assets/lixeira.png')),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: StreamBuilder(
          stream: notificacoes
              .collection('usuarios')
              .doc(idUsuarioLogado)
              .collection('notificacoes')
              .orderBy('hora', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var messages = snapshot.data!.docs;

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var username = messages[index].get('username');
                var mensagem = messages[index].get('mensagem');
                var perfil = messages[index].get('perfil');
                var postagem = messages[index].get('postagem');
                var hora = messages[index].get('hora');
                var idPerfil = messages[index].get('idUsuario');
                var idPostagem = messages[index].get('idPostagem');

                return Column(
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        selecionarItem(context, messages[index].id);
                      },
                      onTap: () async {
                        if (mensagem == 'enviou uma mensagem para você.') {
                          Map<String, String>? perfilInfo =
                              await recuperarDadosPerfilDestino(idPerfil);
                          if (perfilInfo != null) {
                            String nomePerfil = perfilInfo['nome']!;
                            String sobrenomePerfil = perfilInfo['sobrenome']!;

                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mensagens(
                                  uidPerfil: idPerfil,
                                  nome: nomePerfil,
                                  imagemPerfil: perfil,
                                  sobrenome: sobrenomePerfil,
                                ),
                              ),
                            );
                          } else {
                            print('Não encontrado: $idPerfil');
                          }
                        } else {
                          if (mensagem == 'curtiu sua publicação.') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => postagens_individuais(
                                    idPostagem: idPostagem,
                                    imagemPostagem: postagem),
                              ),
                            );
                          }
                        }
                      },
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            if (idPerfil == idUsuarioLogado) {
                              print('idUsuarioLogado');
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => perfil_visita(
                                          uidPerfil: idPerfil,
                                          nome: '',
                                          imagemPerfil: perfil,
                                          sobrenome: '',
                                          cadastro: '')));
                            }
                          },
                          child: ClipOval(
                            child: Container(
                              width: 45,
                              height: 45,
                              color: Colors.white,
                              child: CachedNetworkImage(
                                  imageUrl: perfil,
                                  fit: BoxFit
                                      .cover, // ajuste de acordo com suas necessidades
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                        color: Colors.white,
                                      ), // um indicador de carregamento
                                  errorWidget: (context, url, error) =>
                                      const SizedBox() // widget de erro
                                  ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text('@$username ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Text(formatDataHora(hora),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black38)),
                          ],
                        ),
                        subtitle: Text(mensagem,
                            style: const TextStyle(fontSize: 16)),
                        trailing: Column(
                          children: [
                            if (postagem == 'vazio') const Text(''),
                            if (postagem != 'vazio')
                              SizedBox(
                                width: 45,
                                height: 55,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                      imageUrl: postagem,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const SizedBox(),
                                      errorWidget: (context, url, error) =>
                                          const SizedBox()),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
