import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:editora_izyncor_app/recepcao/paginas/pagina_dois.dart';
import 'package:editora_izyncor_app/recepcao/paginas/pagina_tres.dart';
import 'package:editora_izyncor_app/recepcao/paginas/pagina_um.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class recepcao extends StatefulWidget {
  const recepcao({super.key});

  @override
  State<recepcao> createState() => _recepcaoState();
}

class _recepcaoState extends State<recepcao> {
  PageController _controller = PageController();

  bool ultimaPagina = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  ultimaPagina = (index == 2);
                });
              },
              children: const [
                paginaum(),
                paginadois(),
                paginatres(),
              ],
            ),
            ultimaPagina
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const home_principal()),
                          );
                        },
                        child: Container(
                          width: 130,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black38,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                width: 2,
                                  color: Colors.white)),
                          child: const Center(
                              child: Text(
                            'Vamos lá',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                  )
                : Container(
                    alignment: Alignment(0, 1),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SmoothPageIndicator(
                            controller: _controller,
                            count: 3,
                            effect: const WormEffect(
                              activeDotColor: Color.fromARGB(255, 179, 51, 89),
                              dotColor: Color.fromARGB(255, 221, 224, 224),
                              dotHeight: 8,
                              dotWidth: 8,
                            ),
                          ),
                          const SizedBox(),
                          GestureDetector(
                              onTap: () {
                                _controller.nextPage(
                                    duration: const Duration(milliseconds: 850),
                                    curve: Curves.easeInOutCirc);
                              },
                              child: Container(
                                  width: 80,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    border: Border.all(width: 2, color: Colors.white),
                                      borderRadius: BorderRadius.circular(16)),
                                  child: const Center(
                                      child: Text(
                                    'Pular',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )))),
                        ],
                      ),
                    ))
          ],
        ));
  }
}
