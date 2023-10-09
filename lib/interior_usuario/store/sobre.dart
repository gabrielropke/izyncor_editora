import 'package:flutter/material.dart';

class sobre_store extends StatefulWidget {
  final String titulo;
  final String diretores;
  final String preparadores;
  final String revisao;
  final String ilustradores;
  final String designers;
  final String impressao;
  final String autor;
  final String capa;
  final String background;
  final String sinopse;
  final String genero;
  final String isbn;
  final String valor;
  final String idiomas;
  final String dimensoes;
  final String idades;
  final String editores;
  final String revisores;
  final String impressoes;
  final String paginas;
  final String exemplo01;
  final String exemplo02;
  final String exemplo03;
  const sobre_store(
      {super.key,
      required this.titulo,
      required this.diretores,
      required this.preparadores,
      required this.revisao,
      required this.ilustradores,
      required this.designers,
      required this.impressao,
      required this.autor,
      required this.capa,
      required this.background,
      required this.sinopse,
      required this.genero,
      required this.isbn,
      required this.valor,
      required this.idiomas,
      required this.dimensoes,
      required this.idades,
      required this.editores,
      required this.revisores,
      required this.impressoes,
      required this.paginas,
      required this.exemplo01,
      required this.exemplo02,
      required this.exemplo03});

  @override
  State<sobre_store> createState() => _sobre_storeState();
}

class _sobre_storeState extends State<sobre_store> {
  late String titulo;
  late String diretores;
  late String preparadores;
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
  late String revisores;
  late String impressoes;
  late String paginas;
  late String exemplo01;
  late String exemplo02;
  late String exemplo03;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titulo = widget.titulo;
    diretores = widget.diretores;
    preparadores = widget.preparadores;
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
    revisores = widget.revisores;
    impressoes = widget.impressoes;
    paginas = widget.paginas;
    exemplo01 = widget.exemplo01;
    exemplo02 = widget.exemplo02;
    exemplo03 = widget.exemplo03;
  }

  void _exibirImagemFullScreen(String urlImagem4) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Hero(
                tag: urlImagem4,
                child: Image.network(
                  capa,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  void _exibirImagemFullScreen2(String urlImagem2) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Hero(
                tag: urlImagem2,
                child: Image.network(
                  exemplo01,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  void _exibirImagemFullScreen3(String urlImagem3) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Hero(
                tag: urlImagem3,
                child: Image.network(
                  exemplo02,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  void _exibirImagemFullScreen4(String urlImagem4) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Hero(
                tag: urlImagem4,
                child: Image.network(
                  exemplo03,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 32,
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        title: Text(titulo),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(child: Image.asset('assets/logobanner2.png')),
                  const Text('Detalhes do produto',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 15),
                    child: Row(
                      children: [
                        const Text('Editores: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(diretores,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Preparação de texto: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(preparadores,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Revisão: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(revisores,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Ilustração: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(ilustradores,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Design: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(designers,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Impressão: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(impressoes,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Gênero: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(genero,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Idioma: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(idiomas,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Dimensão: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(dimensoes,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Número de páginas: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(paginas,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('Idade mínima: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(idades,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 5),
                    child: Row(
                      children: [
                        const Text('ISBN: ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '${isbn.substring(0, 3)}-${isbn.substring(3, 4)}-${isbn.substring(4, 8)}-${isbn.substring(8, 12)}-${isbn.substring(12)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _exibirImagemFullScreen(capa);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 170,
                                  child: Image.network(capa),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                _exibirImagemFullScreen2(exemplo01);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 255,
                                  child: Image.network(exemplo01),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                _exibirImagemFullScreen3(exemplo02);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 255,
                                  child: Image.network(exemplo02),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () {
                                _exibirImagemFullScreen4(exemplo03);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 255,
                                  child: Image.network(exemplo03),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 70,
                              child: Image.asset('assets/logoizyncor.png')),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Izyncor ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text('Editorial e Social Network ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic)),
                                  Text('LTDA')
                                ],
                              ),
                              SizedBox(height: 3),
                              Text('Rua Ásia, 138, Mariana-MG'),
                              SizedBox(height: 3),
                              Text('35422-412'),
                              SizedBox(height: 3),
                              Text('www.izyncor.org'),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
