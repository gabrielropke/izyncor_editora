import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/chat_mensagem/mensagens.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/feed/widgets/postagens_individuais.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class NotiMensagem extends StatefulWidget {
  const NotiMensagem({super.key});

  @override
  State<NotiMensagem> createState() => _NotiMensagemState();
}

class _NotiMensagemState extends State<NotiMensagem> {
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

  void selecionarItem(BuildContext context, String index, String status) {
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
            if (status == 'novo')
              ListTile(
                leading:
                    SizedBox(width: 25, child: Image.asset('assets/view.png')),
                title: const Text('Marcar como visto'),
                onTap: () {
                  Navigator.pop(context);
                  setarVisualizada(index);
                },
              ),
            if (status == 'visto')
              ListTile(
                leading: SizedBox(
                    width: 25, child: Image.asset('assets/view_not.png')),
                title: const Text('Marcar como não visto'),
                onTap: () {
                  Navigator.pop(context);
                  setarNaoVisualizada(index);
                },
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

  void selecionarGeral(BuildContext context) {
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
                  SizedBox(width: 25, child: Image.asset('assets/view.png')),
              title: const Text('Marcar todas como visto'),
              onTap: () {
                Navigator.pop(context);
                setarTodasVisualizada();
              },
            ),
            ListTile(
              leading: SizedBox(
                  width: 25, child: Image.asset('assets/view_not.png')),
              title: const Text('Marcar todas como não visto'),
              onTap: () {
                Navigator.pop(context);
                setarTodasNaoVisualizada();
              },
            ),
            ListTile(
              leading:
                  SizedBox(width: 25, child: Image.asset('assets/lixeira.png')),
              title: const Text('Excluir'),
              onTap: () {
                Navigator.pop(context);
                showAlertAtencao();
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

  void setarVisualizada(String index) async {
    try {
      CollectionReference usuariosCollection =
          FirebaseFirestore.instance.collection('usuarios');

      DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioLogado);

      await usuarioRef.collection('notificacoes').doc(index).update({
        'status': 'visto',
      });

      print('Status atualizado com sucesso para "visto"');
    } catch (e) {
      print('Erro ao atualizar o status: $e');
    }
  }

  void setarTodasVisualizada() async {
    try {
      CollectionReference usuariosCollection =
          FirebaseFirestore.instance.collection('usuarios');

      DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioLogado);

      QuerySnapshot notificacoesSnapshot =
          await usuarioRef.collection('notificacoes').get();

      for (QueryDocumentSnapshot doc in notificacoesSnapshot.docs) {
        await doc.reference.update({
          'status': 'visto',
        });
      }

      print(
          'Status atualizado com sucesso para "visto" para todas as notificações');
    } catch (e) {
      print('Erro ao atualizar o status: $e');
    }
  }

  void setarTodasNaoVisualizada() async {
    try {
      CollectionReference usuariosCollection =
          FirebaseFirestore.instance.collection('usuarios');

      DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioLogado);

      QuerySnapshot notificacoesSnapshot =
          await usuarioRef.collection('notificacoes').get();

      for (QueryDocumentSnapshot doc in notificacoesSnapshot.docs) {
        await doc.reference.update({
          'status': 'novo',
        });
      }

      print(
          'Status atualizado com sucesso para "visto" para todas as notificações');
    } catch (e) {
      print('Erro ao atualizar o status: $e');
    }
  }

  void setarNaoVisualizada(String index) async {
    try {
      CollectionReference usuariosCollection =
          FirebaseFirestore.instance.collection('usuarios');

      DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioLogado);

      await usuarioRef.collection('notificacoes').doc(index).update({
        'status': 'novo',
      });

      print('Status atualizado com sucesso para "visto"');
    } catch (e) {
      print('Erro ao atualizar o status: $e');
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
      backgroundColor: Colors.white,
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

            if (messages.isEmpty) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 100,
                      color: Colors.black12,
                    ),
                  ),
                  Text(
                    'Nada por enquanto...',
                    style: TextStyle(
                        fontSize: 26,
                        color: Colors.black26,
                        fontWeight: FontWeight.w300),
                  )
                ],
              );
            }

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
                var status = messages[index].get('status');

                return Visibility(
                  visible: idPostagem == 'mensagem',
                  child: Column(
                    children: [
                      GestureDetector(
                        onDoubleTap: () {
                          setarVisualizada(messages[index].id);
                        },
                        onLongPress: () {
                          selecionarItem(context, messages[index].id, status);
                        },
                        onTap: () async {
                          if (mensagem == 'enviou uma mensagem para você.') {
                            Map<String, String>? perfilInfo =
                                await recuperarDadosPerfilDestino(idPerfil);
                            if (perfilInfo != null) {
                              // String nomePerfil = perfilInfo['nome']!;
                              // String sobrenomePerfil = perfilInfo['sobrenome']!;
                  
                              setarVisualizada(messages[index].id);
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MensagemPage(
                                        idUsuarioDestino: idPerfil)),
                              );
                            } else {
                              print('Não encontrado: $idPerfil');
                            }
                          } else {
                            if (mensagem == 'curtiu sua publicação.') {
                              setarVisualizada(messages[index].id);
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
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                border: status == 'novo'
                                    ? Border.all(
                                        width: 2,
                                        color: const Color.fromARGB(
                                            255, 212, 18, 99))
                                    : null,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: perfil,
                                  fit: BoxFit.cover,
                                  width: 45,
                                  height: 45,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const SizedBox(),
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
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: status == 'visto'
                                          ? Colors.black38
                                          : const Color.fromARGB(
                                              255, 212, 18, 99))),
                              if (status == 'novo') const SizedBox(width: 15),
                              if (status == 'novo')
                                SizedBox(
                                  width: 15,
                                  child: Image.asset('assets/icone_sino_01.png',
                                      color:
                                          const Color.fromARGB(255, 212, 18, 99)),
                                ),
                            ],
                          ),
                          subtitle: Text(mensagem,
                              style: const TextStyle(fontSize: 16)),
                          // trailing: Column(
                          //   children: [
                          //     if (postagem == 'vazio') const Text(''),
                          //     if (postagem != 'vazio')
                          //       SizedBox(
                          //         width: 45,
                          //         height: 40,
                          //         child: ClipRRect(
                          //           borderRadius: BorderRadius.circular(10),
                          //           child: CachedNetworkImage(
                          //               imageUrl: postagem,
                          //               fit: BoxFit.cover,
                          //               placeholder: (context, url) =>
                          //                   const SizedBox(),
                          //               errorWidget: (context, url, error) =>
                          //                   const SizedBox()),
                          //         ),
                          //       ),
                          //   ],
                          // ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
