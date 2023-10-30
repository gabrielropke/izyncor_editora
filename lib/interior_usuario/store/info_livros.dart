import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/store/comentarios/avalicaoes.dart';
import 'package:editora_izyncor_app/interior_usuario/store/sobre.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class info_livros extends StatefulWidget {
  final String titulo;
  final String autor;
  final String capa;
  final String background;
  final String sinopse;
  final String genero;
  final String isbn;
  final String valor;
  final String ilustradores;
  final String designers;
  final String idiomas;
  final String dimensoes;
  final String idades;
  final String editores;
  final String preparadores;
  final String revisores;
  final String impressoes;
  final String paginas;
  final String exemplo01;
  final String exemplo02;
  final String exemplo03;
  final String nomeUsuario;
  final String emailUsuario;
  const info_livros(
      {super.key,
      required this.titulo,
      required this.autor,
      required this.capa,
      required this.background,
      required this.sinopse,
      required this.genero,
      required this.isbn,
      required this.valor,
      required this.ilustradores,
      required this.designers,
      required this.idiomas,
      required this.dimensoes,
      required this.idades,
      required this.editores,
      required this.preparadores,
      required this.revisores,
      required this.impressoes,
      required this.paginas,
      required this.exemplo01,
      required this.exemplo02,
      required this.exemplo03,
      required this.nomeUsuario,
      required this.emailUsuario});

  @override
  State<info_livros> createState() => _info_livrosState();
}

class _info_livrosState extends State<info_livros> {
  StreamController<String> _streamNOME = StreamController<String>();
  ScrollController _scrollController = ScrollController();

  StreamController<int> _contadorStreamController = StreamController<int>();
  Stream<int> get contadorStream => _contadorStreamController.stream;

  String? _idUsuarioLogado;

  late String titulo;
  late String autor;
  late String capa;
  late String background;
  late String sinopse;
  late String genero;
  late String isbn;
  late String valor;
  late String ilustradores;
  late String designers;
  late String idiomas;
  late String dimensoes;
  late String idades;
  late String editores;
  late String preparadores;
  late String revisores;
  late String impressoes;
  late String paginas;
  late String exemplo01;
  late String exemplo02;
  late String exemplo03;
  late String nomeUsuario;
  late String emailUsuario;
  String sandboxInitPointUrl = '';

  int contador = 0;

  _recuperarDadosUsuarioString() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    _streamNOME.add(dados["nome"]);
  }

  void _aumentarContador() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    await db.collection("livros").doc(widget.isbn).update({
      "contador": FieldValue.increment(1),
    });
  }

  void _recuperarContador() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("livros").doc(widget.isbn).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      contador = data["contador"] ?? 0;
    }
  }

  void _recuperarContadorEmTempoReal() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<DocumentSnapshot> snapshotStream =
        db.collection("livros").doc(widget.isbn).snapshots();

    snapshotStream.listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int novoContador = data["contador"] ?? 0;
        _contadorStreamController.add(novoContador);
      }
    });
  }

  Future<void> addCarrinho() async {
    if (_idUsuarioLogado != null) {
      await FirebaseFirestore.instance
          .collection('carrinho')
          .doc(_idUsuarioLogado)
          .collection('meuslivros')
          .doc(isbn)
          .set({
        'idUsuario': _idUsuarioLogado,
        'isbn': isbn,
        'hora': DateTime.now().toString(),
        'titulo': titulo,
        'autor': autor,
        'capa': capa,
        'genero': genero,
        'valor': valor,
        'quantidade': 1,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    titulo = widget.titulo;
    autor = widget.autor;
    capa = widget.capa;
    background = widget.background;
    sinopse = widget.sinopse;
    genero = widget.genero;
    isbn = widget.isbn;
    valor = widget.valor;
    ilustradores = widget.ilustradores;
    designers = widget.designers;
    idiomas = widget.idiomas;
    dimensoes = widget.dimensoes;
    idades = widget.idades;
    editores = widget.editores;
    preparadores = widget.preparadores;
    revisores = widget.revisores;
    impressoes = widget.impressoes;
    paginas = widget.paginas;
    exemplo01 = widget.exemplo01;
    exemplo02 = widget.exemplo02;
    exemplo03 = widget.exemplo03;
    nomeUsuario = widget.nomeUsuario;
    emailUsuario = widget.emailUsuario;
    _recuperarDadosUsuarioString();
    _aumentarContador();
    _recuperarContador();
    _recuperarContadorEmTempoReal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration:
            const Duration(milliseconds: 2000), // Define a duração da animação
        curve: Curves
            .easeInOutCirc, // Define a curva de animação (pode ser ajustada conforme desejado)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(child: CachedNetworkImage(imageUrl: background)),
                      Padding(
                        padding: const EdgeInsets.only(top: 800),
                        child: Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(titulo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 32,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(Icons.menu_book_outlined),
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(autor,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 18,
                                        color: Color.fromARGB(
                                            255, 129, 129, 129))),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 190,
                                      child: Image.network(capa),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 130,
                                          height: 50,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          sobre_store(
                                                            exemplo01:
                                                                exemplo01,
                                                            exemplo02:
                                                                exemplo02,
                                                            exemplo03:
                                                                exemplo03,
                                                            titulo: titulo,
                                                            diretores: editores,
                                                            preparadores:
                                                                preparadores,
                                                            revisao: revisores,
                                                            ilustradores:
                                                                ilustradores,
                                                            designers:
                                                                designers,
                                                            impressao:
                                                                impressoes,
                                                            autor: autor,
                                                            capa: capa,
                                                            background:
                                                                background,
                                                            sinopse: sinopse,
                                                            genero: genero,
                                                            isbn: isbn,
                                                            valor: valor,
                                                            idiomas: idiomas,
                                                            dimensoes:
                                                                dimensoes,
                                                            idades: idades,
                                                            editores: editores,
                                                            revisores:
                                                                revisores,
                                                            impressoes:
                                                                impressoes,
                                                            paginas: paginas,
                                                          )));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: const Color.fromARGB(
                                                      255, 18, 30, 56)),
                                              child: const Center(
                                                child: Text(
                                                  'Sobre',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: 130,
                                          height: 50,
                                          child: GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return SingleChildScrollView(
                                                      child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Text(
                                                      sinopse,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                      textAlign:
                                                          TextAlign.justify,
                                                    ),
                                                  ));
                                                },
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: const Color.fromARGB(
                                                      255, 18, 30, 56)),
                                              child: const Center(
                                                  child: Text(
                                                'Sinopse',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              )),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        avaliacoes(
                                                          titulo: titulo,
                                                          isbn: isbn,
                                                        )));
                                          },
                                          child: SizedBox(
                                            width: 130,
                                            height: 50,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: const Color.fromARGB(
                                                      255, 18, 30, 56)),
                                              child: const Center(
                                                  child: Text(
                                                'Avaliações',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              )),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: () {},
                                          child: SizedBox(
                                            width: 130,
                                            height: 50,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: Color.fromARGB(
                                                      255, 162, 170, 187)),
                                              child: const Center(
                                                  child: Text(
                                                'E-book',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 241, 241, 241),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              )),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: 40,
                                        child: Image.asset(
                                            'assets/oculosicone.png')),
                                    const SizedBox(height: 5),
                                    StreamBuilder<int>(
                                      stream: contadorStream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          int contadorAtual =
                                              snapshot.data!;
                                          return Text("$contadorAtual");
                                        } else {
                                          return Text("...");
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 1,
                                          height: 130,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12))),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120,
                                        height: 130,
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('Gênero',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16)),
                                              const SizedBox(height: 20),
                                              const Icon(
                                                Icons.book,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                genero,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                          width: 1,
                                          height: 130,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12))),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120,
                                        height: 130,
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('Idioma',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16)),
                                              const SizedBox(height: 20),
                                              const Icon(
                                                Icons.language,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                idiomas,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                          width: 1,
                                          height: 130,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12))),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120,
                                        height: 130,
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('Dimensões',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16)),
                                              const SizedBox(height: 20),
                                              const Icon(
                                                Icons.app_registration_sharp,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                dimensoes,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                          width: 1,
                                          height: 130,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12))),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120,
                                        height: 130,
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('N° de páginas',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16)),
                                              const SizedBox(height: 20),
                                              const Icon(
                                                Icons
                                                    .format_list_numbered_rtl_sharp,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                paginas,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                          width: 1,
                                          height: 130,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12))),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 120,
                                        height: 130,
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text('Idade mínima',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 16)),
                                              const SizedBox(height: 20),
                                              const Icon(
                                                Icons.person_3_outlined,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                idades,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                          width: 1,
                                          height: 130,
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black12))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 100)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: SizedBox(
                    width: 260,
                    height: 60,
                    child: GestureDetector(
                      onTap: () async {
                        final ecos = Uri.parse('https://loja.izyncor.org/produto/ecos-de-melancolia/');
                        final caligem = Uri.parse('https://loja.izyncor.org/produto/caligem/');
                        final quintal = Uri.parse('https://loja.izyncor.org/produto/quintal-fantastico/');
                        if (titulo == 'Ecos de Melancolia' &&
                            await canLaunchUrl(ecos)) {
                          await launchUrl(ecos);
                        }
                        if (titulo == 'Caligem' &&
                            await canLaunchUrl(caligem)) {
                          await launchUrl(caligem);
                        }
                        if (titulo == 'Quintal Fantástico' &&
                            await canLaunchUrl(quintal)) {
                          await launchUrl(quintal);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            color: Color.fromARGB(255, 116, 139, 189)),
                        child: Center(
                          child: Text(
                            'Comprar por R\$ $valor',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}
