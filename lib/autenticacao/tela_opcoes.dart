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
      backgroundColor: const Color.fromARGB(255, 238, 234, 228),
      body: Stack(
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
              const TextoWidget(texto: 'Olá Izyncorianos!', tipo: 'titulo'),
              const TextoWidget(
                  texto:
                      'A versão atual está em fase de testes e optamos por manter uma quantidade limitada de usuários. Em breve lançaremos a versão oficial aberta ao público...',
                  tipo: 'subtitulo'),
              // Padding(
              //   padding: const EdgeInsets.only(top: 40, left: 42),
              //   child: Align(
              //     alignment: Alignment.center,
              //     child: SizedBox(
              //       width: 210,
              //       height: 70,
              //       child: Stack(children: [
              //         Padding(
              //           padding: const EdgeInsets.only(top: 0),
              //           child: Align(
              //             alignment: Alignment.topRight,
              //             child: Container(
              //               width: 200,
              //               height: 65,
              //               decoration: BoxDecoration(
              //                 color: Color.fromARGB(255, 255, 255, 255),
              //                 shape: BoxShape.rectangle,
              //                 borderRadius: BorderRadius.circular(42),
              //               ),
              //             ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.only(top: 0),
              //           child: Align(
              //             alignment: Alignment.bottomLeft,
              //             child: Container(
              //               width: 200,
              //               height: 65,
              //               decoration: BoxDecoration(
              //                 color: Color(0xFFBB2649),
              //                 shape: BoxShape.rectangle,
              //                 borderRadius: BorderRadius.circular(42),
              //               ),
              //             ),
              //           ),
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.only(top: 0),
              //           child: GestureDetector(
              //             onTap: () {
              //               Navigator.pushReplacement(
              //                   context,
              //                   MaterialPageRoute(
              //                       builder: (context) => cadastro()));
              //             },
              //             child: Align(
              //               alignment: Alignment.center,
              //               child: Container(
              //                   width: 200,
              //                   height: 65,
              //                   decoration: BoxDecoration(
              //                     color: Color.fromARGB(255, 248, 228, 228),
              //                     shape: BoxShape.rectangle,
              //                     borderRadius: BorderRadius.circular(42),
              //                   ),
              //                   child: const Padding(
              //                     padding: EdgeInsets.all(20),
              //                     child: Row(
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Text(
              //                           'Leitor',
              //                           style: TextStyle(
              //                             fontSize: 22,
              //                             fontWeight: FontWeight.bold,
              //                             color: Color(0xFFBB2649),
              //                           ),
              //                         ),
              //                         Icon(
              //                           Icons.arrow_forward_sharp,
              //                           color: Color(0xFFBB2649),
              //                           size: 20,
              //                         ),
              //                       ],
              //                     ),
              //                   )),
              //             ),
              //           ),
              //         ),
              //       ]),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
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
              )
            ],
          )
        ],
      ),
    );
  }
}

class TextoWidget extends StatelessWidget {
  const TextoWidget({super.key, required this.texto, required this.tipo});

  final String texto;
  final String tipo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          texto,
          style: TextStyle(
              fontSize: tipo == 'titulo' ? 25 : 20,
              fontWeight: tipo == 'titulo' ? FontWeight.bold : FontWeight.w400,
              color: tipo == 'titulo'
                  ? const Color.fromARGB(255, 168, 130, 139)
                  : const Color.fromARGB(255, 189, 147, 157)),
        ),
      ),
    );
  }
}
