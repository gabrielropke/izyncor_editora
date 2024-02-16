import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/configuracao/itens/editar_endereco.dart';
import 'package:editora_izyncor_app/configuracao/itens/enderecos.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class base_endereco extends StatefulWidget {
  const base_endereco({Key? key});

  @override
  State<base_endereco> createState() => _base_enderecoState();
}

class _base_enderecoState extends State<base_endereco> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String? idUsuarioLogado;

  List<Map<String, dynamic>> enderecosCadastrados = [];

  Future<void> recuperarDadosUsuario() async {
    User? usuarioLogado = auth.currentUser;
    idUsuarioLogado = usuarioLogado?.uid;
  }

  Future<void> fetchEnderecos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('enderecos')
        .doc(idUsuarioLogado)
        .collection('meusenderecos')
        .get();
    List<Map<String, dynamic>> meusenderecosCadastrados = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> postagensData = {
        'bairro': doc.get('bairro'),
        'cep': doc.get('cep'),
        'cidade': doc.get('cidade'),
        'complemento': doc.get('complemento'),
        'idEndereco': doc.get('idEndereco'),
        'logradouro': doc.get('logradouro'),
        'numero': doc.get('numero'),
        'uf': doc.get('uf'),
        'uidusuario': doc.get('uidusuario'),
        'titulo': doc.get('titulo'),
      };

      meusenderecosCadastrados.add(postagensData);
    }

    setState(() {
      enderecosCadastrados = meusenderecosCadastrados;
    });
  }

  @override
  void initState() {
    super.initState();
    recuperarDadosUsuario();
    enderecosCadastrados = [];
    fetchEnderecos();
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
        title: const Text('Endereços'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const enderecos_cadastro()));
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.blue,
              ))
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('enderecos')
                .doc(idUsuarioLogado)
                .collection('meusenderecos')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text(
                  'Ocorreu um erro ao carregar os comentários',
                  style: TextStyle(fontSize: 16),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_outlined, color: Colors.black12, size: 82),
                      Text(
                        'Nenhuma endereço cadastrado',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black26,
                            fontSize: 16),
                      )
                    ],
                  ),);
              }
              return ListView.builder(
                  itemCount: enderecosCadastrados.length,
                  itemBuilder: (context, index) {
                    final meuEndereco = enderecosCadastrados[index];

                    return SingleChildScrollView(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.black12),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(width: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.pin_drop_outlined,
                                                        color: Colors.blue),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        meuEndereco[
                                                            'titulo'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                    const SizedBox(width: 5),
                                                    const Text(
                                                        '-',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                        meuEndereco[
                                                            'logradouro'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                    const Text(', ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 18)),
                                                    Text(meuEndereco['numero'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Text(meuEndereco['bairro'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black,
                                                        fontSize: 16)),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(meuEndereco['cidade'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                    const Text(' | ',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                    Text(meuEndereco['uf'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Colors.black,
                                                            fontSize: 16)),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(meuEndereco['cep'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black,
                                                        fontSize: 16)),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 50,
                            right: 10,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                editar_endereco(
                                                  cep: meuEndereco['cep'],
                                                  cidade: meuEndereco['cidade'],
                                                  uf: meuEndereco['uf'],
                                                  rua:
                                                      meuEndereco['logradouro'],
                                                  bairro: meuEndereco['bairro'],
                                                  numero: meuEndereco['numero'],
                                                  complemento: meuEndereco[
                                                      'complemento'],
                                                  idEndereco:
                                                      meuEndereco['idEndereco'], titulo: meuEndereco['titulo'],
                                                )));
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            width: 1, color: Colors.blue),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Center(
                                        child: Text(
                                      'Editar',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      void excluirEndereco() {
                                        CollectionReference meusEnderecos =
                                            FirebaseFirestore.instance
                                                .collection('enderecos')
                                                .doc(idUsuarioLogado)
                                                .collection('meusenderecos');

                                        // Excluir o documento do Firestore
                                        meusEnderecos
                                            .doc(meuEndereco['idEndereco'])
                                            .delete();
                                      }

                                      void showAlertDeletar() {
                                        QuickAlert.show(
                                            context: context,
                                            title: 'Atenção!',
                                            text:
                                                'Realmente deletaremos este endereço?',
                                            confirmBtnText: 'Sim',
                                            cancelBtnText: 'Não',
                                            onCancelBtnTap: () {
                                              Navigator.pop(context);
                                            },
                                            onConfirmBtnTap: () {
                                              excluirEndereco();
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const home_principal(indexPagina: 1,)));
                                            },
                                            type: QuickAlertType.warning);
                                      }

                                      showAlertDeletar();
                                    },
                                    icon: const Icon(Icons.delete)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
