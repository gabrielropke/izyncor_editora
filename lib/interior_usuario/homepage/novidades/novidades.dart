import 'package:cached_network_image/cached_network_image.dart';
import 'package:editora_izyncor_app/interior_usuario/homepage/novidades/comentarios_novidades.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:readmore/readmore.dart';

class novidades extends StatefulWidget {
  const novidades({Key? key}) : super(key: key);

  @override
  State<novidades> createState() => _novidadesState();
}

class _novidadesState extends State<novidades> {
  FirebaseAuth auth = FirebaseAuth.instance;

  late List<Map<String, dynamic>> novidades;
  String? _idUsuarioLogado;

  double iconSize = 24.0;
  Color iconColor = Colors.white;

  recuperarDadosUsuario() {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      _idUsuarioLogado = usuarioLogado.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    novidades = [];
    fetchNovidades();
  }

  void fetchNovidades() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('novidades').get();
    List<Map<String, dynamic>> novasNovidades = [];

    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> novidadeData = {
        'imagem': doc.get('imagem'),
        'titulo': doc.get('titulo'),
        'subtitulo': doc.get('subtitulo'),
        'descricao': doc.get('descricao'),
        'hora': doc.get('hora'),
        'curtidas': doc.get('curtidas'),
        'comentarios': doc.get('comentarios'),
      };
      novasNovidades.add(novidadeData);
    });

    novasNovidades.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a['hora']);
      DateTime dateTimeB = DateTime.parse(b['hora']);
      return dateTimeB.compareTo(dateTimeA);
    });

    setState(() {
      novidades = novasNovidades;
    });
  }

  String formatDataHora(String dateTimeString) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.parse(dateTimeString);
    Duration difference = now.difference(dateTime);

    if (difference < Duration(minutes: 1)) {
      return 'Agora mesmo';
    } else if (difference < Duration(hours: 1)) {
      return 'Há ${difference.inMinutes} minutos';
    } else if (difference < Duration(days: 1)) {
      return 'Há ${difference.inHours} horas';
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

  void enviarCurtida(String titulo) {
    if (_idUsuarioLogado != null) {
      CollectionReference novidadesCollection =
          FirebaseFirestore.instance.collection('novidades');

      // Verificar se o _idUsuarioLogado já existe na coleção de curtir
      novidadesCollection
          .doc(titulo)
          .collection('curtir')
          .doc(_idUsuarioLogado)
          .get()
          .then((doc) {
        if (doc.exists) {
          // O usuário já curtiu, então remova a curtida
          doc.reference.delete().then((_) {
            // Atualize o campo 'curtidas' na novidade (reduza em 1)
            novidadesCollection.doc(titulo).update({
              'curtidas':
                  FieldValue.increment(-1), // Reduz o contador de curtidas em 1
            });
          });
        } else {
          // O usuário ainda não curtiu, adicione a curtida
          Map<String, dynamic> curtidaData = {
            'hora': DateTime.now().toString(),
            'uidusuario': _idUsuarioLogado,
          };

          // Adicione a curtida na coleção 'curtir' da novidade
          novidadesCollection
              .doc(titulo)
              .collection('curtir')
              .doc(_idUsuarioLogado)
              .set(curtidaData)
              .then((_) {
            // Atualize o campo 'curtidas' na novidade (aumente em 1)
            novidadesCollection.doc(titulo).update({
              'curtidas':
                  FieldValue.increment(1), // Incrementa o contador de curtidas
            });
          });
        }
      });
    }
  }

  void opcoesPost(BuildContext context, int index) {
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
          children: [
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
              leading: const Icon(
                Icons.warning_rounded,
                color: Colors.black54,
              ),
              title: const Text('Denunciar'),
              onTap: () {
                // Lógica de copiar URL
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: novidades.length,
        itemBuilder: (context, index) {
          var novidade = novidades[index];

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onDoubleTap: () {
                          enviarCurtida(novidade['titulo']);
                        },
                        child: CachedNetworkImage(
                          imageUrl: novidade['imagem'],
                        ),
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    opcoesPost(context, index);
                                  },
                                  child: const Icon(Icons.more_horiz,
                                      color: Colors.white, size: 26)),
                              const SizedBox(width: 10),
                              const Icon(Icons.share_rounded,
                                  color: Colors.white)
                            ],
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
                        bottom: 15,
                        right: 15,
                        child: Row(
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    enviarCurtida(novidade['titulo']);
                                  },
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('novidades')
                                        .doc(novidade['titulo'])
                                        .collection('curtir')
                                        .doc(_idUsuarioLogado)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          !snapshot.data!.exists) {
                                        // Se não houver dados (usuário não curtiu), mostre o ícone de coração vazio
                                        return SizedBox(
                                            width: 22,
                                            child: Image.asset(
                                                'assets/curtir_03.png'));
                                      }

                                      // Se houver dados (usuário já curtiu), mostre o ícone de coração cheio
                                      return SizedBox(
                                          width: 22,
                                          child: Image.asset(
                                              'assets/curtir_02.png'));
                                    },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('novidades')
                                      .doc(novidade[
                                          'titulo']) // Use o título como ID do documento
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text(
                                        '0', // Ou qualquer outro valor padrão
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      );
                                    }

                                    final curtidas =
                                        snapshot.data!.get('curtidas');
                                    return Text(
                                      '$curtidas',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: ((context) =>
                                            comentarios_novidades(
                                                titulo: novidade['titulo'])),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                      width: 22,
                                      child:
                                          Image.asset('assets/comment_04.png')),
                                ),
                                const SizedBox(height: 5),
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('novidades')
                                      .doc(novidade[
                                          'titulo']) // Use o título como ID do documento
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text(
                                        '0', // Ou qualquer outro valor padrão
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      );
                                    }

                                    final comentarios =
                                        snapshot.data!.get('comentarios');
                                    return Text(
                                      '$comentarios',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              novidade['titulo'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              novidade['subtitulo'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 5),
                    child: ReadMoreText(
                      novidade['descricao'],
                      trimLines: 2,
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
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      formatDataHora(novidade['hora']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.black12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
