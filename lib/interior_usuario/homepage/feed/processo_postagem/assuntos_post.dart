import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class assuntos_postagem extends StatefulWidget {
  final String titulo;
  final String legenda;
  final File? imagem;
  const assuntos_postagem(
      {Key? key,
      required this.titulo,
      required this.legenda,
      required this.imagem})
      : super(key: key);

  @override
  State<assuntos_postagem> createState() => _assuntos_postagemState();
}

// ignore: camel_case_types
class _assuntos_postagemState extends State<assuntos_postagem> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<bool> selectedItems = List.generate(34, (index) => false);

  String? idUsuarioLogado;
  late String titulo;
  late String legenda;
  File? imagem;

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    idUsuarioLogado = usuarioLogado?.uid;
  }

  String _getContainerLabel(int index) {
    switch (index) {
      case 1:
        return 'Ficção Científica';
      case 2:
        return 'Fantasia';
      case 3:
        return 'Mistério/Thriller';
      case 4:
        return 'Romance';
      case 5:
        return 'Drama';
      case 6:
        return 'Aventura';
      case 7:
        return 'História Alternativa';
      case 8:
        return 'Distopia';
      case 9:
        return 'Não Ficção';
      case 10:
        return 'Ciência';
      case 11:
        return 'Autoajuda';
      case 12:
        return 'Mistério';
      case 13:
        return 'Suspense';
      case 14:
        return 'Terror';
      case 15:
        return 'Comédia';
      case 16:
        return 'História Real';
      case 17:
        return 'Romance Histórico';
      case 18:
        return 'Política';
      case 19:
        return 'Tecnologia';
      case 20:
        return 'Psicologia';
      case 21:
        return 'Didático';
      case 22:
        return 'Leitura Nacional';
      case 23:
        return 'Autores Nacionais';
      case 24:
        return 'Editoras';
      case 25:
        return 'Revisores de Texto';
      case 26:
        return 'Leitores críticos';
      case 27:
        return 'Mentores';
      case 28:
        return 'Preparadores de texto';
      case 29:
        return 'Editores';
      case 30:
        return 'Designer';
      case 31:
        return 'Capistas';
      case 32:
        return 'Ilustradores';
      case 33:
        return 'Influenciadores';
      case 34:
        return 'Thriller';
      default:
        return '';
    }
  }

  void enviarNotificacao() {
    CollectionReference usuariosCollection =
        FirebaseFirestore.instance.collection('usuarios');

    DocumentReference usuarioRef = usuariosCollection.doc(idUsuarioLogado);

    usuarioRef.collection('notificacoes').add({
      'username': 'izyncor',
      'idUsuario': idUsuarioLogado,
      'mensagem': 'Sua publicação foi finalizada 😉',
      'hora': DateTime.now().toString(),
      'postagem': 'postagem',
      'idPostagem': 'postagem',
      'perfil':
          'https://firebasestorage.googleapis.com/v0/b/izyncor-app-949df.appspot.com/o/perfil%2F0L0ZqCOLSZfxCpWRfOUOhT36yy23.jpg?alt=media&token=358048dd-7301-4134-8a2c-798e07ec215c',
    });
  }

  Future<void> publicarPostagem() async {
    // Gere um ID único para a postagem
    final String postId =
        FirebaseFirestore.instance.collection('feed').doc().id;

    if (imagem == null) {
      // Para postagens sem imagem
      await FirebaseFirestore.instance.collection('feed').doc(postId).set({
        'autorId': idUsuarioLogado,
        'legenda': legenda,
        'titulo': titulo,
        'imagemUrl': 'vazio',
        'hora': DateTime.now().toString(),
        'curtidas': 0,
        'comentarios': 0,
        'salvos': 0,
        'idPostagem': postId,
        'editado': ''
      });

      await FirebaseFirestore.instance
          .collection('backup_feed')
          .doc(postId)
          .set({
        'autorId': idUsuarioLogado,
        'legenda': legenda,
        'titulo': titulo,
        'imagemUrl': 'vazio',
        'hora': DateTime.now().toString(),
        'curtidas': 0,
        'comentarios': 0,
        'salvos': 0,
        'idPostagem': postId,
        'editado': ''
      });
    } else {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('imagens_postagens')
            .child(postId);
        final uploadTask = storageRef.putFile(imagem!);
        final TaskSnapshot downloadUrl = await uploadTask;

        final String imageUrl = await downloadUrl.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('feed').doc(postId).set({
          'autorId': idUsuarioLogado,
          'legenda': legenda,
          'titulo': '',
          'imagemUrl': imageUrl,
          'hora': DateTime.now().toString(),
          'curtidas': 0,
          'comentarios': 0,
          'salvos': 0,
          'idPostagem': postId,
          'editado': ''
        });

        await FirebaseFirestore.instance
            .collection('backup_feed')
            .doc(postId)
            .set({
          'autorId': idUsuarioLogado,
          'legenda': legenda,
          'titulo': '',
          'imagemUrl': imageUrl,
          'hora': DateTime.now().toString(),
          'curtidas': 0,
          'comentarios': 0,
          'salvos': 0,
          'idPostagem': postId,
          'editado': ''
        });
      } catch (error) {
        print('deu errado');
      }
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuarioLogado)
        .update({
      'postagens': FieldValue.increment(1),
    });

    List<String> selectedAssuntos = [];
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        selectedAssuntos.add(_getContainerLabel(i + 1));
      }
    }

    await FirebaseFirestore.instance
        .collection('feed')
        .doc(postId)
        .collection('assuntos')
        .doc('assuntos')
        .set({
      'assunto': selectedAssuntos,
    });

    enviarNotificacao();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: ((context) => const home_principal(
              indexPagina: 2,
            )),
      ),
    );
  }

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
    titulo = widget.titulo;
    legenda = widget.legenda;
    if (widget.imagem != null) {
      imagem = widget.imagem!;
    }
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
        title: const Text('Tópicos do post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                const Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Selecione os tópicos mais se aproximam da sua postagem',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 34,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedItems[index] = !selectedItems[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32.0),
                            border: selectedItems[index]
                                ? Border.all(width: 1, color: Colors.white)
                                : Border.all(width: 1, color: Colors.black12),
                            color: selectedItems[index]
                                ? const Color.fromARGB(255, 190, 37, 96)
                                : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              _getContainerLabel(index + 1),
                              style: selectedItems[index]
                                  ? const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)
                                  : const TextStyle(
                                      fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 5,
              child: GestureDetector(
                onTap: () {
                  publicarPostagem();
                },
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Text(
                      'Finalizar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
