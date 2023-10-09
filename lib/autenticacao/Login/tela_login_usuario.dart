import 'package:editora_izyncor_app/autenticacao/resetar_senha.dart';
import 'package:editora_izyncor_app/autenticacao/tela_opcoes.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:editora_izyncor_app/model/login/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../../../model/usuario.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<login> {
  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'AVISO',
        text: 'Confira seu e-mail e senha e tente novamente.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String mensagemErro = "";

  _validarCampos() {
    //Recupera dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty) {
        setState(() {
          mensagemErro = "";
        });

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        setState(() {
          showAlert();
        });
      }
    } else {
      setState(() {
        showAlert();
      });
    }
  }

  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((FirebaseUser) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: ((context) => const home_principal())));
    }).catchError((error) {
      setState(() {
        showAlert();
      });
    });
  }

  Future _verificaUsuarioLogado() async {
    // com //#coment o login não acontece
    // sem //#coment o login acontece

    FirebaseAuth auth = FirebaseAuth.instance;
    // auth.signOut();

    User? usuarioLogado = await auth.currentUser;
    if (usuarioLogado != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: ((context) => home_principal())));
    }
  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    super.initState();
  }

  bool _obscureText = true;
  IconData? _iconPassword = Icons.visibility_outlined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 234, 228),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(child: Image.asset("assets/topo_login.png")),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                          width: 350,
                          child: Image.asset("assets/logo_izyncor01.png")),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 40, top: 40),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Vamos lá!',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 189, 147, 157)),
                        )),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 42, top: 5),
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Fala login para continuarmos',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 206, 170, 179)),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 310,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 310,
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
                                    _iconPassword =
                                        Icons.visibility_off_outlined;
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
                                borderSide:
                                    const BorderSide(color: Colors.white)),
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
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, right: 40),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const resetar_senha()));
                          },
                          child: Container(
                            width: 150,
                            height: 40,
                            child: const Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                'Esqueci a senha',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 131, 99, 108)),
                              ),
                            ),
                          ),
                        )),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 310,
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFBB2649),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13))),
                          onPressed: () {
                            _validarCampos();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 115),
                                child: Text(
                                  "Entrar",
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
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 10),
                  //   child: Center(
                  //     child: Text(
                  //       'Ou',
                  //       style: TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w500,
                  //           color: Color.fromARGB(255, 180, 158, 162)),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () => AuthService().signInWithGoogle(context),
                      child: Container(
                        width: 310,
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
                            const SizedBox(width: 40),
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
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 30),
                  //   child: Align(
                  //     alignment: Alignment.center,
                  //     child: SizedBox(
                  //       width: double.infinity,
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           GestureDetector(
                  //             onTap: () =>
                  //                 AuthService().signInWithGoogle(context),
                  //             child: SizedBox(
                  //                 width: 40,
                  //                 child: Image.asset("assets/logo_google.png")),
                  //           ),
                  //           const SizedBox(width: 30),
                  //           SizedBox(
                  //               width: 40,
                  //               child: Image.asset("assets/logo_facebook.png")),
                  //           const SizedBox(width: 30),
                  //           SizedBox(
                  //               width: 40,
                  //               child: Image.asset("assets/logo_apple.png")),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não tem uma conta?',
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
                                        builder: ((context) => tela_opcoes())));
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
