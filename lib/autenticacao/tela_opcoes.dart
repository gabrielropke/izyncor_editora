import 'package:editora_izyncor_app/autenticacao/Cadastros/cadastro_leitor.dart';
import 'package:flutter/material.dart';

class tela_opcoes extends StatefulWidget {
  const tela_opcoes({super.key});

  @override
  State<tela_opcoes> createState() => _tela_opcoesState();
}

class _tela_opcoesState extends State<tela_opcoes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(child: Image.asset("assets/background_options.jpg")),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        width: 300,
                        child: Image.asset("assets/logo_izyncor02.png")),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 40, top: 40),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Quem é você?',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 189, 147, 157)),
                      )),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 42, top: 10),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Defina o seu modelo de cadastro',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color.fromARGB(255, 206, 170, 179)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40, left: 42),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: 210,
                      height: 70,
                      child: Stack(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 200,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(42),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              width: 200,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Color(0xFFBB2649),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(42),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => cadastro()));
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                  width: 200,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 248, 228, 228),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(42),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Leitor',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFBB2649),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_sharp,
                                          color: Color(0xFFBB2649),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 42),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: 210,
                      height: 70,
                      child: Stack(children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 200,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(42),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: 200,
                            height: 65,
                            decoration: BoxDecoration(
                              color: Color(0xFF611325),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(42),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) => tela_cadastro()));
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                width: 200,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 244, 231, 235),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(42),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Autor',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF611325),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_sharp,
                                        color: Color(0xFF611325),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
