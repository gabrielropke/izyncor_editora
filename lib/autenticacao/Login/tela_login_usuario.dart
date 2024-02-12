import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/autenticacao/dados_beta.dart';
import 'package:editora_izyncor_app/autenticacao/resetar_senha.dart';
import 'package:editora_izyncor_app/autenticacao/tela_opcoes.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:editora_izyncor_app/widgets/textfield_widget.dart';
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

  _validarCamposFirst() {
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

        _logarUsuarioFirst(usuario);
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
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: ((context) => const home_principal(
                    indexPagina: 2,
                  ))));
    }).catchError((error) {
      setState(() {
        showAlert();
      });
    });
  }

  _logarUsuarioFirst(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((FirebaseUser) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: ((context) => const DadosBetaPage())));
    }).catchError((error) {
      setState(() {
        showAlert();
      });
    });
  }

  Future<bool> verificarExistenciaDados() async {
    String email = _controllerEmail.text;
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Verificar no Firestore
      QuerySnapshot querySnapshot = await firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      // Verificar na autenticação do Firebase
      List<String> signInMethods = await auth.fetchSignInMethodsForEmail(email);
      if (querySnapshot.docs.isEmpty && signInMethods.isNotEmpty) {
        // ignore: use_build_context_synchronously
        _validarCamposFirst();
      } else if (querySnapshot.docs.isEmpty && signInMethods.isEmpty) {
        showAlert();
      } else if (querySnapshot.docs.isNotEmpty && signInMethods.isNotEmpty) {
        _validarCampos();
      }

      return signInMethods.isNotEmpty;
    } catch (e) {
      print("Erro ao verificar email existente: $e");
      return false;
    }
  }

  Future<bool> verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuerioLogado = auth.currentUser;

    try {
      if (usuerioLogado != null) {
        // Aqui você pode acessar as informações do usuário diretamente de 'usuerioLogado'
        String email = usuerioLogado
            .email!; // Usuário logado, então o e-mail não deve ser nulo

        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Verificar no Firestore se existem dados do usuário
        DocumentSnapshot userDoc =
            await firestore.collection('usuarios').doc(usuerioLogado.uid).get();

        if (userDoc.exists) {
          // Se existem dados do usuário, redirecione para a página principal
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const home_principal(indexPagina: 2)),
          );
          mensagemAlertaIzyncor(
              'Estamos em fase de testes. Reporte qualquer erro ou inconsistência encontrada!');
        } else {
          // Se não há dados do usuário, redirecione para a página de dados beta
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DadosBetaPage()),
          );
        }
        return true; // Usuário logado
      } else {
        return false; // Nenhum usuário logado
      }
    } catch (e) {
      print("Erro ao verificar usuário logado: $e");
      return false;
    }
  }

  mensagemAlertaIzyncor(String mensagem) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 150,
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Image.asset(
                      'assets/icone.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      mensagem,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok')),
            ],
          );
        });
  }

  @override
  void initState() {
    verificaUsuarioLogado();
    super.initState();
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
            SizedBox(child: Image.asset("assets/topo_login.png")),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        width: 350,
                        child: Image.asset("assets/logobanner.png")),
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
                  child: Container(
                    width: 310,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        textfield_widget(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 20,
                              color: Color.fromARGB(255, 203, 197, 190),
                            ),
                            controller: _controllerEmail,
                            obscureText: false,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'E-mail'),
                        const SizedBox(height: 10),
                        textfield_widget(
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                              color: Color.fromARGB(255, 203, 197, 190),
                            ),
                            controller: _controllerSenha,
                            obscureText: _obscureText,
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
                            keyboardType: TextInputType.visiblePassword,
                            hintText: 'Senha'),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const resetar_senha()));
                          },
                          child: const SizedBox(
                            width: 150,
                            height: 40,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                'Esqueci a senha',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 131, 99, 108)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
                          verificarExistenciaDados();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 108),
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
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    onTap: () {
                      mensagemAlertaIzyncor(
                          'Não disponível na versão de testes. Utilize o login e senha disponibilizados pela equipe!');
                    },
                    // onTap: () => AuthService().signInWithGoogle(context),
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
                              Navigator.push(
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
    );
  }
}
