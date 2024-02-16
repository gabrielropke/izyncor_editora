import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

// ignore: camel_case_types
class editar_perfil extends StatefulWidget {
  const editar_perfil({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _editar_perfilState createState() => _editar_perfilState();
}

// ignore: camel_case_types
class _editar_perfilState extends State<editar_perfil> {
  final StreamController<String> _streamNOME = StreamController<String>();
  final StreamController<String> _streamSOBRENOME = StreamController<String>();

  FirebaseStorage storage = FirebaseStorage.instance;
  XFile? _imagem;
  String? _idUsuarioLogado;
  bool subindoImagem = false;
  String urlImagemRecuperada = "";
  String nome = '';
  String sobrenome = '';

  TextEditingController controllerUsername = TextEditingController();
  TextEditingController controllerNome = TextEditingController();
  TextEditingController controllerSobrenome = TextEditingController();
  TextEditingController controllerBio = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerTelefone = TextEditingController();

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

  void showAlertCampoVazio() {
    QuickAlert.show(
      context: context,
      title: 'Hmm...',
      text: 'Alguns campos estão vazios...',
      cancelBtnText: 'Voltar',
      type: QuickAlertType.error,
    );
  }

  Future _recuperarImagem() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? imagemSelecionada =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      File imagemCortada = await cortarImagem(File(imagemSelecionada.path));
      setState(() {
        _imagem = XFile(imagemCortada.path);
        _uploadImagem();
        subindoImagem = true;
      });
    }
  }

  Future _uploadImagem() async {
    File file = File(_imagem!.path);
    Reference pastaRaiz = await storage.ref();
    Reference arquivo =
        await pastaRaiz.child("perfil").child(_idUsuarioLogado! + ".jpg");

    UploadTask task = arquivo.putFile(file);

    task.snapshotEvents.listen((TaskSnapshot storageEvent) {
      if (storageEvent.state == TaskState.running) {
        setState(() {
          subindoImagem = true;
        });
      } else if (storageEvent.state == TaskState.success) {
        setState(() {
          subindoImagem = false;
        });
      }
    });

    task.then((TaskSnapshot taskSnapshot) => _recuperarURLimagem(taskSnapshot));
  }

  Future _recuperarURLimagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();

    _atualizarURLimagemFirestore(url);

    setState(() {
      urlImagemRecuperada = url;
    });
  }

  _atualizarURLimagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"urlImagem": url};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
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
    _streamSOBRENOME.add(dados["sobrenome"]);

    if (dados["urlImagem"] != null) {
      setState(() {
        urlImagemRecuperada = dados["urlImagem"];
      });
    }
  }

  cortarImagem(File file) async {
    return await ImageCropper()
        .cropImage(sourcePath: file.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
    ]);
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
          nome = userData['nome'];
          sobrenome = userData['sobrenome'];
          controllerUsername.text = userData['username'];
          controllerNome.text = userData['nome'];
          controllerSobrenome.text = userData['sobrenome'];
          controllerBio.text = userData['biografia'];
          controllerEmail.text = userData['email'];
          controllerTelefone.text = userData['telefone'];
        });
      }
    }
  }

  void showAlertErroUsername() {
    QuickAlert.show(
        context: context,
        title: 'Hmmm...',
        text: 'Usuário já está em uso!',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertSucessoUsername() {
    QuickAlert.show(
        context: context,
        title: 'Boa!',
        text: 'Usuário está disponível para uso.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.success);
  }

  Future<bool> checkUserPermission(String username) async {
    final usersCollection = FirebaseFirestore.instance.collection('usuarios');
    final querySnapshot =
        await usersCollection.where('username', isEqualTo: username).get();

    return querySnapshot.docs.isNotEmpty;
  }

  atualizarDadosFirestore() {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      'username': controllerUsername.text,
      'nome': controllerNome.text,
      'sobrenome': controllerSobrenome.text,
      'email': controllerEmail.text,
      'biografia': controllerBio.text,
      'telefone': controllerTelefone.text,
    };
    db.collection('usuarios').doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  validarCampos() async {
    if (controllerNome.text.isEmpty) {
      setState(() {
        showAlertCampoVazio();
      });
      return; // Impede que o cadastro prossiga
    }

    if (controllerSobrenome.text.isEmpty) {
      setState(() {
        showAlertCampoVazio();
      });
      return; // Impede que o cadastro prossiga
    }

    // Verifica se o campo username está vazio
    if (controllerUsername.text.isEmpty) {
      setState(() {
        showAlertCampoVazio();
      });
      return; // Impede que o cadastro prossiga
    }

    // Verifica se o usuário já existe no banco de dados
    bool userExists = await checkUserPermission(controllerUsername.text);

    if (userExists) {
      setState(() {
        showAlertErroUsername();
      });
      return; // Impede que o cadastro prossiga
    }
    showAlert();
    }

  @override
  void initState() {
    _recuperarDadosUsuarioString();
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
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(64),
                            child: GestureDetector(
                              onTap: () async => await _recuperarImagem(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  // ignore: unnecessary_null_comparison
                                  image: urlImagemRecuperada != null
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(urlImagemRecuperada),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                // ignore: unnecessary_null_comparison
                                child: urlImagemRecuperada == null
                                    ? const Icon(Icons.person,
                                        size: 60, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      subindoImagem ? Container() : Container(),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async => await _recuperarImagem(),
                        child: Text(
                          '$nome $sobrenome',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async => await _recuperarImagem(),
                        child: const Text(
                          'Alterar imagem',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Container(
                color: Colors.white,
                height: 30,
                child: const Text('informações do perfil',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 58, 56, 56))),
              ),
              const Divider(),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: textos_widget(texto: 'Usuário'),
                  ),
                  const SizedBox(height: 5),
                  textfield_widget(
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      size: 20,
                      color: Color.fromARGB(255, 203, 197, 190),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: Color.fromARGB(255, 190, 23, 79),
                      ), // Ícone do botão
                      onPressed: () async {
                        String username = controllerUsername.text;

                        // Verifique se o campo está vazio
                        if (username.isEmpty) {
                          setState(() {
                            showAlertErroUsername(); // Exiba uma mensagem de campo vazio
                          });
                          return; // Impede que a função prossiga
                        }

                        // Verifique se o username contém caracteres especiais usando uma expressão regular
                        RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
                        if (!regex.hasMatch(username)) {
                          setState(() {
                            showAlertErroUsername(); // Exiba uma mensagem de caracteres especiais
                          });
                          return; // Impede que a função prossiga
                        }

                        // Agora, você pode continuar com a verificação de existência do usuário
                        bool userExists = await checkUserPermission(username);
                        if (userExists) {
                          // O usuário já existe, você pode exibir uma mensagem ou fazer algo aqui
                          setState(() {
                            showAlertErroUsername(); // Ou exibir uma mensagem de erro
                          });
                        } else {
                          // O usuário não existe, você pode exibir uma mensagem ou fazer algo aqui
                          setState(() {
                            showAlertSucessoUsername(); // Ou exibir uma mensagem de sucesso
                          });
                        }
                      },
                    ),
                    controller: controllerUsername,
                    keyboardType: TextInputType.name,
                    hintText: 'Digite seu segundo nome',
                    obscureText: false,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: textos_widget(texto: 'Primeiro nome'),
                  ),
                  const SizedBox(height: 5),
                  textfield_widget(
                    controller: controllerNome,
                    keyboardType: TextInputType.name,
                    hintText: 'Digite seu nome',
                    obscureText: false,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: textos_widget(texto: 'Segundo nome'),
                  ),
                  const SizedBox(height: 5),
                  textfield_widget(
                    controller: controllerSobrenome,
                    keyboardType: TextInputType.name,
                    hintText: 'Digite seu segundo nome',
                    obscureText: false,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: textos_widget(texto: 'Endereço de e-mail'),
                  ),
                  const SizedBox(height: 5),
                  textfield_widget(
                    controller: controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Digite seu e-mail',
                    obscureText: false,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: textos_widget(texto: 'Biografia'),
                  ),
                  const SizedBox(height: 5),
                  textfield_widget(
                    controller: controllerBio,
                    keyboardType: TextInputType.name,
                    maxLines: null,
                    maxLength: 5000,
                    hintText:
                        'Exemplo:\n🎉 Sua idade\n💻 Profissão\n🌍 Descendência',
                    obscureText: false,
                  )
                ],
              ),
              const SizedBox(height: 30),
              Container(
                color: Colors.white,
                height: 30,
                child: const Text('informações de contato',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 58, 56, 56))),
              ),
              const Divider(),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: textos_widget(texto: 'Telefone'),
                  ),
                  const SizedBox(height: 5),
                  textfield_widget(
                    controller: controllerTelefone,
                    keyboardType: TextInputType.phone,
                    hintText: 'Digite seu Telefone',
                    obscureText: false,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        validarCampos();
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
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class textos_widget extends StatelessWidget {
  const textos_widget({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
          fontWeight: FontWeight.w400, fontSize: 15, color: Colors.black87),
    );
  }
}
