import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class enviar_denuncia extends StatefulWidget {
  final String idPostagem;
  final String motivo;
  final String autor;
  final String nomeAutor;
  const enviar_denuncia(
      {super.key,
      required this.idPostagem,
      required this.motivo,
      required this.autor,
      required this.nomeAutor});

  @override
  State<enviar_denuncia> createState() => _enviar_denunciaState();
}

class _enviar_denunciaState extends State<enviar_denuncia> {

  TextEditingController legendaController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  late String idPostagem;
  late String motivo;
  late String autor;
  late String nomeAutor;
  String? idUsuarioLogado;

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      idUsuarioLogado = usuarioLogado.uid;
    }
  }

  void showAlertSucesso() {
    QuickAlert.show(
        context: context,
        title: 'Denúncia enviada',
        text: 'Obrigado por colaborar com a limpeza de nossa rede!',
        confirmBtnText: 'Ok',
        onConfirmBtnTap: () {
          enviarDenuncia();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const home_principal(indexPagina: 1,)));
        },
        type: QuickAlertType.success);
  }

  Future<void> enviarDenuncia() async {

    String legenda = legendaController.text;

    final postagemRef =
        FirebaseFirestore.instance.collection('denuncias').doc();
    await postagemRef.set({
      'autorId': autor,
      'idAutorDenuncia': idUsuarioLogado,
      'usuarioDenunciado': nomeAutor,
      'postagemId': idPostagem,
      'motivoDenuncia': motivo,
      'legenda': legenda,
      'hora': DateTime.now().toString(),
    });

    await postagemRef.update({'idDenuncia': postagemRef.id});
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    idPostagem = widget.idPostagem;
    motivo = widget.motivo;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: SizedBox(
                      width: 200, child: Image.asset('assets/izyncor.png')),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.center,
                child: Text('Agradecemos pela denúncia',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'izyncor é extremamente grata pelo aviso! Sua denúncia permanecerá anônima, a menos que seja referente a direitos autorais!',
                  style: TextStyle(color: Colors.black38),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text('Denúncia sobre: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('@$nomeAutor',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Motivo: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(motivo,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400)),
                ],
              ),
              const SizedBox(height: 25),
              if (motivo == 'Outros')
                TextField(
                  controller: legendaController,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    label: const Text('Descrição'),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black26)),
                    contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
                    hintText: "Descreva sobre sua denúncia...",
                    hintStyle: const TextStyle(
                        color: Colors.black45,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              if (motivo == 'Outros') const SizedBox(height: 40),
              if (motivo != 'Outros') const SizedBox(height: 300),
              Column(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Clique abaixo para enviar sua denúncia.',
                      style: TextStyle(color: Colors.black38),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Divider(
                    color: Colors.black12,
                  ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: () {
                      showAlertSucesso();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 28, 131, 216),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text(
                          'Enviar denúncia',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
