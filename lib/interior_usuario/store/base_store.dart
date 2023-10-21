import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/store/carrinho.dart';
import 'package:editora_izyncor_app/interior_usuario/store/info_livros.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class store extends StatefulWidget {
  const store({super.key});

  @override
  State<store> createState() => _storeState();
}

class _storeState extends State<store> {
  StreamController<String> _streamNOME = StreamController<String>();
  TextEditingController _searchController = TextEditingController();
  ValueNotifier<String> searchText = ValueNotifier<String>('');

  List<String> capaUrls = [];
  List<String> exemplo01 = [];
  List<String> exemplo02 = [];
  List<String> exemplo03 = [];
  List<String> titulos = [];
  List<String> valores = [];
  List<String> autores = [];
  List<String> background = [];
  List<String> sinopses = [];
  List<String> generos = [];
  List<String> isbns = [];
  List<String> ilustradores = [];
  List<String> designers = [];
  List<String> idiomas = [];
  List<String> dimensoes = [];
  List<String> idades = [];
  List<String> editores = [];
  List<String> preparadores = [];
  List<String> revisores = [];
  List<String> impressoes = [];
  List<String> paginas = [];

  late String nome;
  late String email;
  String? _idUsuarioLogado;

  List<String> listaGeneros = [
    'Ficção',
    'Folclore',
    'Terror',
    'Terror psicológico',
    'Horror',
    'Literatura',
  ];

  Future<void> capasUrl() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('livros')
          .get(); // Obtém todos os documentos da coleção 'livros'

      final List<String> urls = snapshot.docs
          .map((doc) => doc.get('capa') as String)
          .toList(); // Obtém os URLs das capas dos livros

      final List<String> exemplo01Livros = snapshot.docs
          .map((doc) => doc.get('exemplo01') as String)
          .toList(); // Obtém os URLs dos exemplos dos livros

      final List<String> exemplo02Livros = snapshot.docs
          .map((doc) => doc.get('exemplo02') as String)
          .toList(); // Obtém os URLs dos exemplos dos livros

      final List<String> exemplo03Livros = snapshot.docs
          .map((doc) => doc.get('exemplo03') as String)
          .toList(); // Obtém os URLs dos exemplos dos livros

      final List<String> backgroundLivros = snapshot.docs
          .map((doc) => doc.get('background') as String)
          .toList(); // Obtém os URLs dos background dos livros

      final List<String> titulosLivros = snapshot.docs
          .map((doc) => doc.get('titulo') as String)
          .toList(); // Obtém os títulos dos livros

      final List<String> valoresLivros = snapshot.docs
          .map((doc) => (doc.get('valor') as String).replaceAll('.', ','))
          .toList(); // Obtém os valores dos livros

      final List<String> autoresLivros =
          snapshot.docs.map((doc) => doc.get('autor') as String).toList();

      final List<String> sinopesLivros =
          snapshot.docs.map((doc) => doc.get('sinopse') as String).toList();

      final List<String> generosLivros =
          snapshot.docs.map((doc) => doc.get('genero') as String).toList();

      final List<String> isbnslivros =
          snapshot.docs.map((doc) => doc.get('isbn') as String).toList();

      final List<String> ilustradoresLivros = snapshot.docs
          .map((doc) => doc.get('ilustradores') as String)
          .toList();

      final List<String> designersLivros =
          snapshot.docs.map((doc) => doc.get('designers') as String).toList();

      final List<String> idiomasLivros =
          snapshot.docs.map((doc) => doc.get('idioma') as String).toList();

      final List<String> dimensoesLivros =
          snapshot.docs.map((doc) => doc.get('dimensao') as String).toList();

      final List<String> idadesLivros =
          snapshot.docs.map((doc) => doc.get('idademinima') as String).toList();

      final List<String> editoresLivros =
          snapshot.docs.map((doc) => doc.get('editores') as String).toList();

      final List<String> preparadoresLivros = snapshot.docs
          .map((doc) => doc.get('preparadores') as String)
          .toList();

      final List<String> revisoresLivros =
          snapshot.docs.map((doc) => doc.get('revisores') as String).toList();

      final List<String> impressoesLivros =
          snapshot.docs.map((doc) => doc.get('impressao') as String).toList();

      final List<String> paginasLivros =
          snapshot.docs.map((doc) => doc.get('paginas') as String).toList();

      setState(() {
        capaUrls = urls; // Atualiza a lista de URLs das capas dos livros
        titulos = titulosLivros; // Atualiza a lista de títulos dos livros
        valores = valoresLivros; // Atualiza a valores de títulos dos livros
        autores = autoresLivros; // Atualiza a autores de títulos dos livros
        background = backgroundLivros;
        sinopses = sinopesLivros;
        generos = generosLivros;
        isbns = isbnslivros;
        ilustradores = ilustradoresLivros;
        designers = designersLivros;
        dimensoes = dimensoesLivros;
        idiomas = idiomasLivros;
        idades = idadesLivros;
        editores = editoresLivros;
        preparadores = preparadoresLivros;
        revisores = revisoresLivros;
        impressoes = impressoesLivros;
        paginas = paginasLivros;
        exemplo01 = exemplo01Livros;
        exemplo02 = exemplo02Livros;
        exemplo03 = exemplo03Livros;
      });
    } catch (e) {
      print('Erro ao buscar os URLs das capas dos livros: $e');
    }
  }

  _recuperarDadosUsuarioString() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    _streamNOME.add(dados["nome"]);

    setState(() {
      nome = dados['nome'];
      email = dados['email'];
    });
  }

  @override
  void initState() {
    super.initState();
    capasUrl();
    _recuperarDadosUsuarioString();

    // Adicione um listener para monitorar as mudanças no texto de pesquisa
    searchText.addListener(() {
      setState(() {}); // Atualize o estado quando o texto de pesquisa mudar
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        centerTitle: false,
            title: Image.asset(
              'assets/izyncor.png',
              width: 100, // ajuste a largura conforme necessário
              height: 40, // ajuste a altura conforme necessário
            ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const carrinho())));
              },
              icon: const Icon(Icons.shopping_cart_outlined))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'O que está procurando?',
                          ),
                          onChanged: (text) {
                            searchText.value =
                                text; // Atualize o ValueNotifier com o texto de pesquisa
                          },
                        ),
                      ),
                    ),
                    // PopupMenuButton<String>(
                    //   icon: const Icon(Icons.filter_list_rounded),
                    //   itemBuilder: (BuildContext context) {
                    //     return listaGeneros.map((String genre) {
                    //       return PopupMenuItem<String>(
                    //         value: genre,
                    //         child: Text(genre),
                    //       );
                    //     }).toList();
                    //   },
                    //   onSelected: (String newValue) {
                    //     setState(() {
                    //       _searchController.text = newValue;
                    //     });
                    //   },
                    // )
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Wrap(
                      spacing: 3,
                      runSpacing: 10,
                      children: List.generate(capaUrls.length, (index) {
                        final title = titulos[index].toLowerCase();
                        final genero = generos[index].toLowerCase();
                        final searchQuery = searchText.value.toLowerCase();

                        // Check if the search query is empty or matches the book title
                        if (searchQuery.isEmpty ||
                            title.contains(searchQuery) ||
                            genero.contains(searchQuery)) {
                          return Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    info_livros(
                                                      emailUsuario:
                                                          email[index],
                                                      nomeUsuario: nome[index],
                                                      exemplo01:
                                                          exemplo01[index],
                                                      exemplo02:
                                                          exemplo02[index],
                                                      exemplo03:
                                                          exemplo03[index],
                                                      paginas: paginas[index],
                                                      valor: valores[index],
                                                      titulo: titulos[index],
                                                      autor: autores[index],
                                                      capa: capaUrls[index],
                                                      background:
                                                          background[index],
                                                      sinopse: sinopses[index],
                                                      genero: generos[index],
                                                      isbn: isbns[index],
                                                      ilustradores:
                                                          ilustradores[index],
                                                      designers:
                                                          designers[index],
                                                      idiomas: idiomas[index],
                                                      dimensoes:
                                                          dimensoes[index],
                                                      idades: idades[index],
                                                      editores: editores[index],
                                                      preparadores:
                                                          preparadores[index],
                                                      revisores:
                                                          revisores[index],
                                                      impressoes:
                                                          impressoes[index],
                                                    ))));
                                      },
                                      child: SizedBox(
                                        height: 210,
                                        child: CachedNetworkImage(
                                          imageUrl: capaUrls[index],
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image(image: imageProvider),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 170),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(32),
                                            bottomRight: Radius.circular(32),
                                          )),
                                      width: 60,
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          'R\$ ${valores[index]}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                                255, 201, 39, 80),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  titulos[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  autores[index],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color:
                                          Color.fromARGB(255, 172, 170, 170)),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Container(); // Return an empty container if book does not match search
                        }
                      }),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
