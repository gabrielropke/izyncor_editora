import 'package:editora_izyncor_app/configuracao/itens/base%20endere%C3%A7o.dart';
import 'package:editora_izyncor_app/configuracao/itens/relatar_problema.dart';
import 'package:editora_izyncor_app/configuracao/itens/sobre.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/editar_perfil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../autenticacao/Login/tela_login_usuario.dart';

class home_config extends StatefulWidget {
  const home_config({super.key});

  @override
  State<home_config> createState() => _home_configState();
}

class _home_configState extends State<home_config> {
  bool _isSwitched = false;

  _deslogarUsuario() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: ((context) => login())),
        (Route<dynamic> route) => false);
  }

  void showAlert() {
    QuickAlert.show(
        context: context,
        title: 'ATENÇÃO',
        text: 'Deseja realmente sair da conta?',
        confirmBtnText: 'Sair',
        type: QuickAlertType.warning,
        onConfirmBtnTap: () async {
          _deslogarUsuario();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Configurações'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Column(
              children: [
                SizedBox(
                  width: 400,
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => editar_perfil())));
                        },
                        icon: const Icon(
                          Icons.account_circle_outlined,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Minha conta",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              color: Colors.black),
                        )),
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => base_endereco()));
                        },
                        icon: const Icon(
                          Icons.add_home_outlined,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Endereços",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              color: Colors.black),
                        )),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     SizedBox(
                //       child: TextButton.icon(
                //           onPressed: () {
                //             setState(() {
                //               _isSwitched = !_isSwitched;
                //             });
                //           },
                //           icon: const Icon(
                //             Icons.notifications_active_outlined,
                //             color: Colors.black,
                //           ),
                //           label: const Text(
                //             "Notificações",
                //             style: TextStyle(
                //                 fontWeight: FontWeight.w400,
                //                 fontSize: 17,
                //                 color: Colors.black),
                //           )),
                //     ),
                //     Switch(
                //       value: _isSwitched,
                //       onChanged: (value) {
                //         setState(() {
                //           _isSwitched = value;
                //         });
                //       },
                //       activeTrackColor: Color.fromARGB(255, 238, 215, 223),
                //       activeColor: Color.fromARGB(255, 192, 19, 76),
                //     ),
                //   ],
                // ),
                SizedBox(
                  width: 400,
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const relatar_problema()));
                        },
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Relatar um problema",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              color: Colors.black),
                        )),
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const sobre()));
                        },
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Sobre",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              color: Colors.black),
                        )),
                  ),
                ),
                SizedBox(
                  width: 400,
                  height: 40,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          showAlert();
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Color.fromARGB(255, 255, 0, 0),
                        ),
                        label: const Text(
                          "Sair da conta",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 17,
                              color: Color.fromARGB(255, 255, 0, 0)),
                        )),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
