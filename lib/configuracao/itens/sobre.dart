import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class sobre extends StatefulWidget {
  const sobre({Key? key});

  @override
  State<sobre> createState() => _sobreState();
}

class _sobreState extends State<sobre> {
  ScrollController _scrollController = ScrollController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;
  String urlImagem = '';
  String nome = '';
  String sobrenome = '';
  String cadastro = '';
  String biografia = '';

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
          nome = userData['nome'];
          sobrenome = userData['sobrenome'];
          cadastro = userData['Cadastro'];
          urlImagem = userData['urlImagem'];
          biografia = userData['biografia'];
        });
      }
    }
  }

  void item01(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Excelência Literária e Cultural',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          width: double.infinity,
                          height: 1,
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Buscamos constantemente a excelência literária em todas as nossas publicações, mantendo altos padrões de qualidade editorial, escrita, design e produção. Valorizamos e promovemos a diversidade de vozes e perspectivas, garantindo que nossos livros representem diferentes culturas, experiências e identidades. Celebramos a autenticidade literária, apoiando e publicando obras que despertam emoções, desafiam convenções e ampliam os limites da criatividade. Acreditamos que nossos livros são verdadeiras obras de arte literárias, enriquecendo a vida dos leitores e oferecendo experiências únicas.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        );
      },
    );
  }

  void item02(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Resp. Social e Acesso ao Conhecimento',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          width: double.infinity,
                          height: 1,
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Comprometemo-nos a ter uma atuação responsável, promovendo a sustentabilidade, transparência, respeito aos direitos autorais e ações que impactem positivamente a sociedade. Acreditamos no poder transformador do conhecimento e nos esforçamos para torná-lo acessível a todos, valorizando a democratização da leitura e da educação. Mantemos altos padrões éticos e morais, garantindo a precisão, liberdade de expressão, respeito aos direitos autorais e privacidade dos autores e leitores. Nossa missão é criar um impacto positivo na sociedade, compartilhando conhecimento, enriquecendo a cultura e promovendo o acesso igualitário à leitura.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        );
      },
    );
  }

  void item03(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Inovação Literária e Experiências',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          width: double.infinity,
                          height: 1,
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Buscamos constantemente inovar na literatura, explorando novas formas de contar histórias, desafiar convenções e envolver os leitores em experiências literárias significativas. Valorizamos a excelência editorial, garantindo a qualidade em todas as nossas publicações. Buscamos promover a diversidade de vozes e perspectivas, criando obras autênticas que ressoam emocionalmente e estimulam o pensamento crítico. Nosso compromisso é oferecer uma ampla gama de experiências literárias enriquecedoras, que inspirem, entretenham e transformem a vida dos leitores. Através de nossa abordagem inovadora, queremos impulsionar o avanço da literatura e seu impacto na sociedade.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();

    // Delay for 2 seconds and then scroll to the bottom
    Future.delayed(Duration(seconds: 1), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 60), // 10 seconds duration for scrolling
        curve: Curves.linear, // You can choose a different curve if needed
      );
    });
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
        title: const Text('Sobre Izyncor'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                  child: Image.asset(
                "assets/logo_izyncor01.png",
              )),
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 15),
                child: Text('Editorial e Social Network L&T Izyncor',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Estamos dedicados a criar pontes entre autores a leitores, fomentando literatura e se tornando verdadeiras aventuras para os amantes dos livros.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
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
                              decoration:
                                  const BoxDecoration(color: Colors.black12))),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        height: 130,
                        child: Container(
                          color: Colors.white,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+25',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 26),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Conteúdos exclusivos',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
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
                              decoration:
                                  const BoxDecoration(color: Colors.black12))),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        height: 130,
                        child: Container(
                          color: Colors.white,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+10',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 26),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Projetos em andamento',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
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
                              decoration:
                                  const BoxDecoration(color: Colors.black12))),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 120,
                        height: 130,
                        child: Container(
                          color: Colors.white,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '+3',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 26),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Livros\npublicados',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
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
                              decoration:
                                  const BoxDecoration(color: Colors.black12))),
                      SizedBox(
                          width: 1,
                          height: 130,
                          child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black12))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Bem-vindo(a) à Izyncor, onde conectamos escritores e leitores com obras literárias que transcendem a imaginação. Valorizamos a diversidade e promovemos diálogos enriquecedores entre culturas. Com excelência editorial, criamos obras de arte literária em parceria com talentosos escritores, revisores e designers apaixonados. Comprometidos com responsabilidade social e sustentabilidade, adotamos práticas sustentáveis e incentivamos causas sociais e ambientais. Explore conosco o poder da palavra escrita em histórias cativantes. Aventure-se em um mundo de possibilidades da Izyncor, onde a qualidade e a beleza dos livros são incomparáveis.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(
                      child: Image.asset('assets/foto_thais.png', width: 60)),
                  const SizedBox(width: 15),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thais Mesquita',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 23),
                      ),
                      Text(
                        'Fundadora & Dir Editorial',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                      child: Image.asset('assets/foto_leandro.png', width: 60)),
                  const SizedBox(width: 15),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leandro Chagas',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 23),
                      ),
                      Text(
                        'Fundador & CEO',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  item01(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Excelência Literária e Cultural',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.add_box_outlined,
                          color: Color.fromARGB(255, 196, 27, 83),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              GestureDetector(
                onTap: () {
                  item02(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Resp. Social e Acesso ao Conhecimento',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.add_box_outlined,
                          color: Color.fromARGB(255, 196, 27, 83),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              GestureDetector(
                onTap: () {
                  item03(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Inovação Literária e Experiências',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.add_box_outlined,
                          color: Color.fromARGB(255, 196, 27, 83),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 60),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Quem somos?',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
              const Text(
                'Boas-vindas à lzyncor, um mundo de possibilidades. Juntos, mergulharemos nas páginas da imaginação para experienciar histórias cativantes e transformadoras. Somos apaixonados por literatura e estamos comprometidos em oferecer obras de qualidade, exclusivas e originais. Para isso, nos dispomos a busca ativa por autores talentosos e obras que desafiam os limites da imaginação. Queremos levar nossos leitores a explorar novos mundos, experimentar emoções intensas e experienciar aventuras inesquecíveis.\nPara nossa estante, adotamos gêneros literários que conversam entre si. Vivenciaremos os romances emocionantes e perseguiremos investigações instigantes ao nos aventurarmos das lendárias montanhas fantásticas até os abismos escuros e aterrorizantes. Seja caçar criaturas míticas, escapar de seres horrendos, encontrar o par perfeito para si ou descobrir o paradeiro de um super assassino, izyncor terá a aventura certa para você. Estamos empenhados em criar um universo literário diversificado, que ultrapassa fronteiras e conecta pessoas por meio das palavras.\nEm Izyncor trabalhamos cada livro com cuidado para oferecer um material personalizado e que encante desde o primeiro contato. No momento que bater o olho em um dos nossos produtos, você saberá: É de Izyncor. Faça o teste, nossos livros já podem ser encontrados em diversas livrarias físicas em todo o Brasil, além de nossa loja online, claro!\nAcreditamos no poder transformador da leitura. Em Izyncor, convidamos você a embarcar em uma jornada literária emocionante, onde a imaginação ganha vida e as palavras têm o poder de encantar. Explore nosso mundo de possibilidades e faça parte dessa aventura conosco!\nEm Izyncor temos um propósito fundamental: Ser a ponte entre escritores e leitores dos mais variados tipos e gostos, promovendo conexão e cultura com não apenas histórias, mas obras de arte. Trilhamos uma jornada de incentivo à criatividade e pensamento crítico, para assim fortalecer a identidade cultural e fomentar a empatia e compreensão mútua.\nDesejamos trilhar uma rota para nos tornarmos referência em qualidade editorial e valor literário. Queremos construir um catálogo diversificado, exclusivo e com qualidade, estabelecendo-nos como uma marca que valoriza o relacionamento com os autores e leitores. Nesse caminho, buscamos expandir para novos mercados, investir em tecnologia e inovação, e ser uma força impulsionadora na transformação do setor editorial.\nSabemos que ao longo do caminho, muitas coisas ficam para trás, mas tenha certeza que três valores nunca deixarão de fazer parte do nosso caminhar.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),
              const Text(
                'Existimos Para Conectar Pessoas, Sendo A Ponte Entre Autores E Leitores De Todos Os Tipos!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
