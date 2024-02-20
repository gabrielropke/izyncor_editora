import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/autenticacao/Login/tela_login_usuario.dart';
import 'package:editora_izyncor_app/configuracao/assuntos/assuntos_selecao.dart';
import 'package:editora_izyncor_app/configuracao/itens/relatar_problema.dart';
import 'package:editora_izyncor_app/configuracao/itens/sobre.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/curtidas/scroll_curtidas.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/editar/configuracoes.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/editar/editar_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/meu_perfil.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/salvos/scroll_salvos.dart';
import 'package:editora_izyncor_app/widgets/drawer/lista_widget_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class drawer_widget extends StatefulWidget {
  const drawer_widget({super.key});

  @override
  State<drawer_widget> createState() => _drawer_widgetState();
}

class _drawer_widgetState extends State<drawer_widget> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? idUsuarioLogado;
  String? nome;
  String? sobrenome;
  String? username;
  String urlImagem = '';

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
          sobrenome = userData['sobrenome'];
          username = userData['username'];
        });
      }
    }
  }

  _deslogarUsuario() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: ((context) => const login(
                  statusInicial: 1,
                ))),
        (Route<dynamic> route) => false);
  }

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'ATENÇÃO',
        text: 'Deseja realmente sair da conta?',
        confirmBtnText: 'Sair',
        type: QuickAlertType.warning,
        onConfirmBtnTap: () {
          _deslogarUsuario();
        });
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    decoration: const BoxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipOval(
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.white,
                                child: CachedNetworkImage(
                                  imageUrl: urlImagem,
                                  fit: BoxFit
                                      .cover, // ajuste de acordo com suas necessidades
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(
                                    color: Colors.white,
                                  ), // um indicador de carregamento
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                  ), // widget de erro
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.wb_sunny_outlined,
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '$nome $sobrenome',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@$username',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black38),
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const perfil()));
                        },
                        child: const lista_widgets_drawer(
                            icone_drawer: 'assets/perfil4_icon.png',
                            titulo_drawer: 'Perfil'),
                      ),
                      // const SizedBox(height: 10),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) =>
                      //                 const HomePage_seguindo()));
                      //   },
                      //   child: const lista_widgets_drawer(
                      //       icone_drawer: 'assets/seguindo3_icone.png',
                      //       titulo_drawer: 'Seguindo'),
                      // ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const assuntos_selecao()));
                        },
                        child: const lista_widgets_drawer(
                            icone_drawer: 'assets/assuntos05_icone.png',
                            titulo_drawer: 'Assuntos'),
                      ),
                      // const SizedBox(height: 10),
                      // const lista_widgets_drawer(
                      //     icone_drawer: 'assets/ranking01_icone.png',
                      //     titulo_drawer: 'Ranking'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ScrollSalvos()));
                        },
                        child: const lista_widgets_drawer(
                            icone_drawer: 'assets/salvar01_icone.png',
                            titulo_drawer: 'Salvos'),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ScrollCurtidas()));
                        },
                        child: const lista_widgets_drawer(
                            icone_drawer: 'assets/salvos2_icone.png',
                            titulo_drawer: 'Curtidas'),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const editar_perfil()));
                        },
                        child: const SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Configurações do perfil',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromARGB(255, 58, 56, 56))),
                              Icon(Icons.keyboard_arrow_right_rounded)
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const configuracoes()));
                        },
                        child: const SizedBox(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Minha conta',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromARGB(255, 58, 56, 56))),
                              Icon(Icons.keyboard_arrow_right_rounded)
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const sobre()));
                            },
                            icon: SizedBox(
                              width: 23,
                              child: Image.asset('assets/info2_icone.png'),
                            )),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const relatar_problema()));
                          },
                          icon: SizedBox(
                            width: 20,
                            child: Image.asset('assets/relatar2_icone.png'),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        showAlert();
                      },
                      icon: SizedBox(
                        width: 24,
                        child: Image.asset(
                          'assets/sair3_icone.png',
                          color: const Color.fromARGB(255, 194, 24, 80),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
