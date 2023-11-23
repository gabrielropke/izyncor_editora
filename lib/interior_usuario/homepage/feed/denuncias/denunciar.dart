import 'package:editora_izyncor_app/interior_usuario/homepage/feed/denuncias/enviar_denuncia.dart';
import 'package:flutter/material.dart';

class denunciar extends StatefulWidget {
  final String idPostagem;
  final String autor;
  final String nomeAutor;
  const denunciar(
      {super.key,
      required this.idPostagem,
      required this.autor,
      required this.nomeAutor});

  @override
  State<denunciar> createState() => _denunciarState();
}

class _denunciarState extends State<denunciar> {
  late String idPostagem;
  late String autor;
  late String nomeAutor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    idPostagem = widget.idPostagem;
    autor = widget.autor;
    nomeAutor = widget.nomeAutor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Denunciar'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agradecemos por nos avisar!',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              const SizedBox(height: 15),
              const Text('Porque está realizando esta denúncia?',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
              const SizedBox(height: 20),
              const Text(
                  'Sua denúncia é tratada de forma completamente anônima, e sua identidade não será revelada em nenhum momento. Agradecemos por agir em prol de nossa comunidade e nos ajudar a manter um ambiente seguro para todos os usuários.',
                  style: TextStyle(color: Colors.black38)),
              const SizedBox(height: 35),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Assédio',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Assédio',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Abuso infantil',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Abuso infantil',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Violência ou discurso de ódio',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Violência ou discurso de ódio',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Desinformação',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Desinformação',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Abuso de animais',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Abuso de animais',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Violação de direitos autorais',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Violação de direitos autorais',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Nudez ou atividade sexual',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Nudez ou atividade sexual',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Intimidação',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Intimidação',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Suicídio ou auto-mutilação',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Suicídio ou auto-mutilação',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Organizações perigosas',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Organizações perigosas',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Fraude ou golpe',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Fraude ou golpe',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enviar_denuncia(
                                idPostagem: idPostagem,
                                motivo: 'Outros',
                                autor: autor,
                                nomeAutor: nomeAutor,
                              )));
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.white,
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Outros',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16)),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.black12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
