import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class resetar_senha extends StatefulWidget {
  const resetar_senha({super.key});

  @override
  State<resetar_senha> createState() => _resetar_senhaState();
}

class _resetar_senhaState extends State<resetar_senha> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void showAlertErro() {
    QuickAlert.show(
        context: context,
        title: 'Atenção',
        text: 'Este e-mail não existe em nosso banco de dados.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.error);
  }

  void showAlertSucesso() {
    QuickAlert.show(
        context: context,
        title: 'Feito',
        text: 'Enviamos para o seu e-mail um link para resetar a senha.',
        confirmBtnText: 'Ok',
        type: QuickAlertType.success);
  }

  Future resetarsenha() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showAlertSucesso();
    } on FirebaseException catch (e) {
      print(e);
      showAlertErro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 234, 228),
      body: Stack(
        children: [
          SizedBox(child: Image.asset("assets/topo_login.png")),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: ClipOval(
                  child: Container(
                    width: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 189, 147, 157)),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(width: 2, color: Colors.black)),
                    child: const Icon(
                      Icons.lock_clock_outlined,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Problemas para entrar?',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Insira o seu e-mail abaixo e enviaremos um link para você redefinir a senha da sua conta.',
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 310,
                      child: TextField(
                        controller: _emailController,
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
                                  const BorderSide(color: Colors.black26)),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: 310,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFBB2649),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13))),
                      onPressed: resetarsenha,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 110),
                            child: Text(
                              "Enviar",
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
              ]),
        ],
      ),
    );
  }
}
