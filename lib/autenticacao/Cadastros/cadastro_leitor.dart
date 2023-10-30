import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/autenticacao/Login/tela_login_usuario.dart';
import 'package:editora_izyncor_app/model/login/auth_service.dart';
import 'package:editora_izyncor_app/recepcao/recepcao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../model/usuario.dart';
import 'package:intl/intl.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;

class cadastro extends StatefulWidget {
  const cadastro({super.key});

  @override
  State<cadastro> createState() => _cadastroState();
}

class _cadastroState extends State<cadastro> {
  //Controladores
  TextEditingController _controllerUsername = TextEditingController();
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerSobrenome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  DateTime? _selectedDate;

  void showAlertEmail() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'E-mail inválido',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertTelefone() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Telefone inválido',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertSenha() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Senha muito curta',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertNascimento() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Você precisa ter pelo menos 13 anos de idade.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Preencha os dados',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertErro() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Erro ao cadastrar usuário, confira os dados e tente novamente.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
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

  // ignore: unused_field
  String _mensagemErro = "";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  _validarCampos() async {
    // Recupera dados dos campos
    String nome = _controllerNome.text;
    String sobrenome = _controllerSobrenome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;
    DateTime? nascimento = _selectedDate;
    String username = _controllerUsername.text;

    // Verifica se o campo username está vazio
    if (username.isEmpty) {
      setState(() {
        showAlertErroUsername();
      });
      return; // Impede que o cadastro prossiga
    }

    // Verifica se o usuário já existe no banco de dados
    bool userExists = await checkUserPermission(username);

    if (userExists) {
      setState(() {
        showAlertErroUsername();
      });
      return; // Impede que o cadastro prossiga
    }

    // Verifica outros campos
    if (nome.isEmpty) {
      setState(() {
        showAlert();
      });
      return;
    }

    if (sobrenome.isEmpty) {
      setState(() {
        showAlert();
      });
      return;
    }

    if (email.isEmpty || !email.contains("@")) {
      setState(() {
        showAlertEmail();
      });
      return;
    }

    if (senha.isEmpty || senha.length < 6) {
      setState(() {
        showAlertSenha();
      });
      return;
    }

    if (nascimento == null || nascimento.year > 2010) {
      setState(() {
        showAlertNascimento();
      });
      return;
    }

    // Se chegou até aqui, todos os campos estão validados
    setState(() {
      _mensagemErro = "";
    });

    Usuario usuario = Usuario();
    usuario.nome = nome;
    usuario.sobrenome = sobrenome;
    usuario.username = username;
    usuario.email = email;
    usuario.senha = senha;
    usuario.cadastro = 'Leitor(a)';
    usuario.cpf = '';
    String nascimentoString = nascimento.toString();
    usuario.nascimento = nascimentoString;

    _cadastrarUsuario(usuario);
  }

  _cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((FirebaseUser) {
      //Salvar dados do usuário
      FirebaseFirestore db = FirebaseFirestore.instance;

      db
          .collection("usuarios")
          .doc(FirebaseUser.user!.uid)
          .set(usuario.toMap());

      // enviar_email(usuario.email);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => (recepcao()))));
    }).catchError((error) {
      print("erro app: " + error.toString());
      setState(() {
        showAlertErro();
      });
    });
  }

  // Future<void> enviar_email(String email) async {
  //   var url = Uri.parse(
  //       'https://api-welcome-izyncor.onrender.com/send?destinatario=$email');
  //   var response = await http.get(url);
  //   print(response.body);
  // }

  Future<bool> checkUserPermission(String username) async {
    final usersCollection = FirebaseFirestore.instance.collection('usuarios');
    final querySnapshot =
        await usersCollection.where('username', isEqualTo: username).get();

    return querySnapshot.docs.isNotEmpty;
  }

  bool _obscureText = true;
  IconData? _iconPassword = Icons.visibility_outlined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 234, 228),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(child: Image.asset("assets/background_cadastro.png")),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        width: 300,
                        child: Image.asset("assets/logo_izyncor02.png")),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Equipe Izyncor,',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 189, 147, 157)),
                          )),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Faça parte da nossa comunidade.',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color.fromARGB(255, 206, 170, 179)),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem uma conta?',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 131, 99, 108)),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => login()));
                            },
                            child: const Text(
                              'Clique aqui!',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 131, 99, 108)),
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      controller: _controllerUsername,
                      keyboardType: TextInputType.name,
                      maxLength: 20,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
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
                            String username = _controllerUsername.text;

                            // Verifique se o campo está vazio
                            if (username.isEmpty) {
                              setState(() {
                                showAlert(); // Exiba uma mensagem de campo vazio
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
                            bool userExists =
                                await checkUserPermission(username);
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
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Colors.white)),
                        contentPadding:
                            const EdgeInsets.fromLTRB(32, 15, 32, 16),
                        hintText: "Nome de usuário",
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 189, 185, 185),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      controller: _controllerNome,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: Color.fromARGB(255, 203, 197, 190),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Colors.white)),
                        contentPadding:
                            const EdgeInsets.fromLTRB(32, 15, 32, 16),
                        hintText: "Primeiro nome",
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 189, 185, 185),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      controller: _controllerSobrenome,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: Color.fromARGB(255, 203, 197, 190),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Colors.white)),
                        contentPadding:
                            const EdgeInsets.fromLTRB(32, 15, 32, 16),
                        hintText: "Segundo nome",
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 189, 185, 185),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          size: 20,
                          color: Color.fromARGB(255, 203, 197, 190),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Colors.white)),
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
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TextField(
                      controller: _controllerSenha,
                      keyboardType: TextInputType.visiblePassword,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          iconSize: 20,
                          color: Color.fromARGB(255, 166, 160, 155),
                          onPressed: () {
                            if (_obscureText == true) {
                              setState(() {
                                _obscureText = false;
                                _iconPassword = Icons.visibility_off_outlined;
                              });
                            } else {
                              setState(() {
                                _obscureText = true;
                                _iconPassword = Icons.visibility_outlined;
                              });
                            }
                          },
                          icon: Icon(_iconPassword),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(color: Colors.white)),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: Color.fromARGB(255, 203, 197, 190),
                        ),
                        contentPadding: EdgeInsets.fromLTRB(32, 15, 32, 16),
                        hintText: "Senha",
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 189, 185, 185),
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 260,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, left: 10),
                          child: Text(
                            _selectedDate == null
                                ? 'Data de Nascimento'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? Color.fromARGB(255, 189, 185, 185)
                                  : Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _selectDate(context);
                          },
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 30,
                            color: Color.fromARGB(255, 203, 197, 190),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFBB2649),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            _validarCampos();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 125),
                                child: Text(
                                  "Cadastrar",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_sharp,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                // const Padding(
                //     padding: EdgeInsets.only(top: 40),
                //     child: Center(
                //       child: Text(
                //         'Entre também com',
                //         style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.w500,
                //             color: Color.fromARGB(255, 180, 158, 162)),
                //       ),
                //     ),
                //   ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 1,
                        color: Colors.black12,
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Ou',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 180, 158, 162)),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 100,
                        height: 1,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () => AuthService().signInWithGoogle(context),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Color.fromARGB(255, 53, 135, 230)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 3),
                          Stack(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 7,
                                left: 6,
                                child: Image.asset(
                                  "assets/logo_google.png",
                                  width:
                                      30, // Defina a largura desejada da imagem
                                  height:
                                      30, // Defina a altura desejada da imagem
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 60),
                          const Text('Entrar com o google',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
