import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class relatar_problema extends StatefulWidget {
  const relatar_problema({super.key});

  @override
  State<relatar_problema> createState() => _relatar_problemaState();
}

class _relatar_problemaState extends State<relatar_problema> {
  final bugController = TextEditingController();

  @override
  void dispose() {
    bugController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Relatar problemas'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
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
                      Icons.warning_amber_rounded,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Encontrou algum bug?',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Ajude-nos a melhorar e reporte o erro encontrado!',
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
                        controller: bugController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        maxLines: null,
                        maxLength: null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.error_outline,
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
                          hintText: "Relatar problemas",
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
                      onPressed: () {},
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
        ),
      ),
    );
  }
}
