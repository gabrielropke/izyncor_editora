import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil_visita/perfil_visita.dart';
import 'package:flutter/material.dart';

class dados_autor_post extends StatefulWidget {
  final String idUsuarioLogado;
  final String autorId;
  final String usernameAutor;
  final String idPostagem;
  final String legenda;
  final String titulo;
  final String imagemUrl;
  final Color corBotao;
  final Color corTexto;
  final String nome;
  final String perfilAutor;
  final String sobrenome;
  final String cadastro;
  final String hora;

  const dados_autor_post(
      {super.key,
      required this.idUsuarioLogado,
      required this.autorId,
      required this.usernameAutor,
      required this.idPostagem,
      required this.legenda,
      required this.titulo,
      required this.imagemUrl,
      required this.corBotao,
      required this.corTexto,
      required this.nome,
      required this.perfilAutor,
      required this.sobrenome,
      required this.cadastro,
      required this.hora});

  @override
  State<dados_autor_post> createState() => _dados_autor_postState();
}

class _dados_autor_postState extends State<dados_autor_post> {
  late List<Map<String, dynamic>> postagens;
  late String idUsuarioLogado;
  late String autorId;
  late String usernameAutor;
  late String idPostagem;
  late String legenda;
  late String titulo;
  late String imagemUrl;
  late Color corBotao;
  late Color corTexto;
  late String nome;
  late String perfilAutor;
  late String sobrenome;
  late String cadastro;
  late String hora;

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
    corTexto = widget.corTexto;
    nome = widget.nome;
    sobrenome = widget.sobrenome;
    cadastro = widget.cadastro;
    hora = widget.hora;
    perfilAutor = widget.perfilAutor;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
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
                      color: const Color.fromARGB(255, 202, 30, 82),
                      child: InkWell(
                        onTap: () {
                          void seguirUsuario(String titulo) {
                            CollectionReference novidadesCollection =
                                FirebaseFirestore.instance
                                    .collection('usuarios');

                            // Verificar se o idUsuarioLogado já existe na coleção de curtir
                            novidadesCollection
                                .doc(autorId)
                                .collection('seguidores')
                                .doc(idUsuarioLogado)
                                .get()
                                .then((doc) {
                              if (doc.exists) {
                                doc.reference.delete().then((_) {
                                  novidadesCollection.doc(autorId).update({
                                    'seguidores': FieldValue.increment(-1),
                                  });
                                });
                              } else {
                                Map<String, dynamic> seguidoresData = {
                                  'hora': DateTime.now().toString(),
                                  'uidusuario': idUsuarioLogado,
                                };

                                novidadesCollection
                                    .doc(autorId)
                                    .collection('seguidores')
                                    .doc(idUsuarioLogado)
                                    .set(seguidoresData)
                                    .then((_) {
                                  novidadesCollection.doc(autorId).update({
                                    'seguidores': FieldValue.increment(1),
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
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(autorId)
                                .collection('seguidores')
                                .doc(idUsuarioLogado)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || !snapshot.data!.exists) {
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
                                size: 16, // Ou qualquer outra cor desejada
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
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: corTexto,
                    fontSize: 16),
              ),
              const SizedBox(height: 3),
              Text(
                formatDataHora(hora),
                style: TextStyle(
                  fontSize: 12,
                  color: corTexto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
