import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
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
  final TextEditingController _controllerNOME = TextEditingController(text: "");
  final TextEditingController _controllerUSERNAME = TextEditingController(text: "");
  final TextEditingController _controllerSOBRENOME = TextEditingController(text: "");
  final TextEditingController _controllerEMAIL = TextEditingController(text: "");
  final TextEditingController _controllerBIO = TextEditingController(text: "");

  final StreamController<String> _streamNOME = StreamController<String>();
  final StreamController<String> _streamSOBRENOME = StreamController<String>();

  FirebaseStorage storage = FirebaseStorage.instance;
  XFile? _imagem;
  String? _idUsuarioLogado;
  bool subindoImagem = false;
  String urlImagemRecuperada = "";
  String nome = '';
  String sobrenome = '';

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'ATENÇÃO',
        text: 'Deseja prosseguir com a alteração?',
        confirmBtnText: 'Confirmar',
        cancelBtnText: 'Cancelar',
        type: QuickAlertType.confirm,
        onConfirmBtnTap: () async {
          _atualizarNomeFirestore();
          _atualizarSobrenomeFirestore();
          _atualizarEmailFirestore();
          _atualizarBioFirestore();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: ((context) => const home_principal())));
        });
  }

  Future _recuperarImagem(String origemImagem) async {
    final ImagePicker _picker = ImagePicker();
    XFile? imagemSelecionada;

    if (origemImagem == "camera") {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);
    } else if (origemImagem == "galeria") {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);
    }

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

  _atualizarNomeFirestore() {
    String nome = _controllerNOME.text;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"nome": nome};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  // _atualizarUsernameFirestore() {
  //   String username = _controllerUSERNAME.text;

  //   FirebaseFirestore db = FirebaseFirestore.instance;

  //   Map<String, dynamic> dadosAtualizar = {"username": username};

  //   db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  // }

  _atualizarSobrenomeFirestore() {
    String sobrenome = _controllerSOBRENOME.text;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"sobrenome": sobrenome};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarEmailFirestore() {
    String email = _controllerEMAIL.text;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"email": email};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarBioFirestore() {
    String bio = _controllerBIO.text;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"biografia": bio};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
    _controllerNOME.text = dados["nome"];
    _controllerSOBRENOME.text = dados["sobrenome"];
    _controllerEMAIL.text = dados["email"];
    _controllerBIO.text = dados["biografia"];
    _controllerUSERNAME.text = dados['username'];
    if (dados["urlImagem"] != null) {
      setState(() {
        urlImagemRecuperada = dados["urlImagem"];
      });
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
        });
      }
    }
  }

    void showAlertErroUsername() {
    QuickAlert.show(
        context: context,
        title: 'Negado',
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

  @override
  void initState() {
    _recuperarDadosUsuario();
    _recuperarDadosUsuarioString();
    recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                                onTap: () {
                                  _recuperarImagem("galeria");
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    // ignore: unnecessary_null_comparison
                                    image: urlImagemRecuperada != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                urlImagemRecuperada),
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
                          onTap: () {
                            _recuperarImagem("galeria");
                          },
                          child: Text(
                            '$nome $sobrenome',
                            style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _recuperarImagem("galeria");
                          },
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
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Nome',
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
                        child: TextField(
                          controller: _controllerNOME,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 243, 243, 243),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                    const BorderSide(color: Colors.white)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(32, 15, 32, 16),
                            hintText: "Nome",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 189, 185, 185),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sobrenome',
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
                        child: TextField(
                          controller: _controllerSOBRENOME,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 243, 243, 243),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                    const BorderSide(color: Colors.white)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(32, 15, 32, 16),
                            hintText: "Sobrenome",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 189, 185, 185),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'E-mail',
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
                        child: TextField(
                          controller: _controllerEMAIL,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 243, 243, 243),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                    const BorderSide(color: Colors.white)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(32, 15, 32, 16),
                            hintText: "E-mail",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 189, 185, 185),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Bio',
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
                        child: TextField(
                          controller: _controllerBIO,
                          maxLines: null,
                          maxLength: 5000,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 243, 243, 243),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide:
                                    const BorderSide(color: Colors.white)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(32, 15, 32, 16),
                            hintText:
                                "Exemplo:\n🎉 Sua idade\n💻 Profissão\n🌍 Descendência",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 189, 185, 185),
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const home_principal()));
                        },
                        child: Container(
                          width: 110,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Center(
                              child: Text(
                            'Cancelar',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
