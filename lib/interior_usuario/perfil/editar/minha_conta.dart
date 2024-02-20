import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

// ignore: camel_case_types
class minha_conta extends StatefulWidget {
  const minha_conta({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _minha_contaState createState() => _minha_contaState();
}

// ignore: camel_case_types
class _minha_contaState extends State<minha_conta> {
  final TextEditingController controllerNome = TextEditingController(text: "");
  final TextEditingController controllerRG = TextEditingController(text: "");
  final TextEditingController controllerCPF = TextEditingController(text: "");
  final TextEditingController controllerProfissao =
      TextEditingController(text: "");
  String? _idUsuarioLogado;

  String? valueChoose;
  List listItem = ['Solteiro(a)', 'Casado(a)', 'Divorciado(a)', 'Viúvo(a)'];
  String? valueEscolaridade;
  List listEscolaridade = [
    'Fundamental completo',
    'Fundamental incompleto',
    'Médio completo',
    'Médio incompleto',
    'Superior completo',
    'Superior incompleto',
  ];

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'ATENÇÃO',
        text: 'Deseja prosseguir com a alteração?',
        confirmBtnText: 'Sim',
        cancelBtnText: 'Não',
        type: QuickAlertType.confirm,
        onConfirmBtnTap: () async {
          atualizarDadosFirestore();
          Navigator.pop(context);
          Navigator.pop(context);
        });
  }

  atualizarDadosFirestore() {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      'nomeCompleto': controllerNome.text,
      'rg': controllerRG.text,
      'cpf': controllerCPF.text,
      'profissao': controllerProfissao.text,
      'estadoCivil': valueChoose,
      'escolaridade': valueEscolaridade
    };
    db.collection('usuarios').doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  Future<void> recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado != null) {
      _idUsuarioLogado = usuarioLogado.uid;
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .doc(_idUsuarioLogado)
          .get();
      if (userData.exists) {
        setState(() {
          controllerNome.text = userData['nomeCompleto'];
          controllerRG.text = userData['rg'];
          controllerCPF.text = userData['cpf'];
          controllerProfissao.text = userData['profissao'];
          valueChoose = userData["estadoCivil"] ?? "";
          valueEscolaridade = userData["escolaridade"] ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    valueChoose;
    valueEscolaridade;
    super.dispose();
  }

  @override
  void initState() {
    recuperarDadosUsuario();
    super.initState();
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
        title: const Text('Minha conta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 30,
                child: const Text('informações pessoais',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 58, 56, 56))),
              ),
              const Divider(),
              const SizedBox(height: 20),
              container_widget(
                  titulo: 'Nome completo',
                  controller: controllerNome,
                  keyboardType: TextInputType.name,
                  hintText: 'Digite seu nome completo'),
              const SizedBox(height: 20),
              container_widget(
                  titulo: 'RG',
                  controller: controllerRG,
                  keyboardType: TextInputType.number,
                  hintText: 'Digite seu RG'),
              const SizedBox(height: 20),
              container_widget(
                  titulo: 'CPF',
                  controller: controllerCPF,
                  keyboardType: TextInputType.number,
                  hintText: 'Digite seu CPF'),
              const SizedBox(height: 20),
              container_widget(
                  titulo: 'Profissão principal',
                  controller: controllerProfissao,
                  keyboardType: TextInputType.name,
                  hintText: 'Digite sua principal profissão'),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      'Estado civil',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 243, 243),
                        borderRadius: BorderRadius.circular(13)),
                    child: DropdownButton(
                      hint: const Text('Selecione uma das opções'),
                      icon: const Icon(Icons.arrow_drop_down_outlined),
                      isExpanded: true,
                      value: valueChoose,
                      onChanged: (newValue) {
                        setState(() {
                          valueChoose = newValue as String?;
                        });
                      },
                      items: listItem.map((valueItem) {
                        return DropdownMenuItem(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      'Escolaridade',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 243, 243),
                        borderRadius: BorderRadius.circular(13)),
                    child: DropdownButton(
                      hint: const Text('Selecione uma das opções'),
                      icon: const Icon(Icons.arrow_drop_down_outlined),
                      isExpanded: true,
                      value: valueEscolaridade,
                      onChanged: (newValue) {
                        setState(() {
                          valueEscolaridade = newValue as String?;
                        });
                      },
                      items: listEscolaridade.map((valueItem) {
                        return DropdownMenuItem(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showAlert();
                      },
                      child: Container(
                        width: 110,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Center(
                            child: Text(
                          'Salvar',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class container_widget extends StatelessWidget {
  const container_widget(
      {super.key,
      required this.titulo,
      required this.controller,
      required this.keyboardType,
      required this.hintText});

  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            titulo,
            style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Colors.black87),
          ),
        ),
        const SizedBox(height: 5),
        textfield_widget(
          controller: controller,
          keyboardType: keyboardType,
          hintText: hintText,
          obscureText: false,
        )
      ],
    );
  }
}
