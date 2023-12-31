import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/configuracao/itens/base%20endere%C3%A7o.dart';
import 'package:editora_izyncor_app/model/endereco.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class enderecos_cadastro extends StatefulWidget {
  const enderecos_cadastro({Key? key}) : super(key: key);

  @override
  State<enderecos_cadastro> createState() => _enderecos_cadastroState();
}

class _enderecos_cadastroState extends State<enderecos_cadastro> {
  TextEditingController cepController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();
  TextEditingController ufController = TextEditingController();
  TextEditingController ruaController = TextEditingController();
  TextEditingController bairroController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController complementoController = TextEditingController();

  String? _idUsuarioLogado;

  String? valueChoose;
  List listItem = ['Minha casa', 'Escritório', 'Trabalho', 'Amigos'];

  recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
  }

  Future<Map<String, dynamic>> consultarCEP(String cep) async {
    var url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha na consulta do CEP.');
    }
  }

  @override
  void dispose() {
    cepController.dispose();
    cidadeController.dispose();
    ufController.dispose();
    ruaController.dispose();
    bairroController.dispose();
    valueChoose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cepController.addListener(() {
      String cep = cepController.text;
      if (cep.length == 8) {
        consultarCEP(cep).then((data) {
          setState(() {
            cidadeController.text = data['localidade'];
            ufController.text = data['uf'];
            ruaController.text = data['logradouro'];
            bairroController.text = data['bairro'];
            valueChoose = data['titulo'];
          });
        }).catchError((error) {
          print(error);
        });
      }
    });

    Future<void> showAlertRegistrado() async {
      await QuickAlert.show(
        context: context,
        title: 'Endereço cadastrado!',
        text: 'Seu endereço foi cadastrado com sucesso.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.success,
      );
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const base_endereco()),
      );
    }

    void showAlertErro() {
      QuickAlert.show(
          context: context,
          title: 'Atenção!',
          text: 'Preencha todos os dados.',
          confirmBtnText: 'Ok',
          type: QuickAlertType.error);
    }

    cadastrarEndereco(Endereco endereco) async {
      FirebaseFirestore db = FirebaseFirestore.instance;

      String cep = cepController.text;
      String uf = ufController.text;
      String cidade = cidadeController.text;
      String bairro = bairroController.text;
      String logradouro = ruaController.text;
      String numero = numeroController.text;
      String complemento = complementoController.text;
      String? titulo = valueChoose;

      // Verifica se algum dos campos está vazio
      if (cep.isEmpty ||
          uf.isEmpty ||
          cidade.isEmpty ||
          bairro.isEmpty ||
          logradouro.isEmpty ||
          numero.isEmpty ||
          titulo!.isEmpty) {
        // Exibe mensagem de erro
        showAlertErro();
      } else {
        // Todos os campos estão preenchidos, então envie os dados para o Firebase
        DocumentReference enderecoRef = await db
            .collection("enderecos")
            .doc(_idUsuarioLogado)
            .collection('meusenderecos')
            .add({
          'uidusuario': _idUsuarioLogado,
          'cep': cep,
          'uf': uf,
          'cidade': cidade,
          'bairro': bairro,
          'logradouro': logradouro,
          'numero': numero,
          'complemento': complemento,
          'titulo': valueChoose, // Add the selected value to Firebase
        });

        // O ID gerado para o documento pode ser acessado com enderecoRef.id
        String idEndereco = enderecoRef.id;

        // Você pode atualizar o documento com o ID gerado se for necessário
        await enderecoRef.update({'idEndereco': idEndereco});

        // Exibe mensagem de sucesso
        showAlertRegistrado();
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          foregroundColor: Colors.black,
          elevation: 0,
          leadingWidth: 26,
          backgroundColor: Colors.transparent,
          title: const Text('Cadastrar novo endereço'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'CEP',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black54),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SizedBox(
                                width: 240,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: cepController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          borderSide: const BorderSide(
                                              color: Colors.white)),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          32, 15, 32, 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'UF',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black54),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SizedBox(
                                width: 100,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: ufController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          borderSide: const BorderSide(
                                              color: Colors.white)),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          32, 15, 32, 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Cidade',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: cidadeController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 243, 243, 243),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                          color: Colors.white)),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(32, 15, 32, 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Bairro',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: bairroController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 243, 243, 243),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                          color: Colors.white)),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(32, 15, 32, 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'Logradouro',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black54),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SizedBox(
                                width: 240,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: ruaController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          borderSide: const BorderSide(
                                              color: Colors.white)),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          32, 15, 32, 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                'N°',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: Colors.black54),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: SizedBox(
                                width: 100,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextField(
                                    controller: numeroController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 243, 243, 243),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          borderSide: const BorderSide(
                                              color: Colors.white)),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          32, 15, 32, 16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Título',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Colors.black54),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 243, 243, 243),
                              borderRadius: BorderRadius.circular(13)),
                          child: DropdownButton(
                            hint: const Text('Ex: Minha casa'),
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
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Complemento | Referência',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: SizedBox(
                            width: double.infinity,
                            child: SizedBox(
                              width: double.infinity,
                              child: TextField(
                                controller: complementoController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 243, 243, 243),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                          color: Colors.white)),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(32, 15, 32, 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  cadastrarEndereco(Endereco());
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
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
