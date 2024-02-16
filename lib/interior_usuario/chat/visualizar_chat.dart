import 'package:editora_izyncor_app/interior_usuario/chat/conversas_chat.dart';
import 'package:editora_izyncor_app/interior_usuario/chat/usuarios_chat.dart';
import 'package:flutter/material.dart';

class visualizar_chat extends StatefulWidget {
  const visualizar_chat({super.key});

  @override
  State<visualizar_chat> createState() => _visualizar_chatState();
}

class _visualizar_chatState extends State<visualizar_chat> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            foregroundColor: Colors.black,
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: false,
            title: Image.asset(
              'assets/izyncor.png',
              width: 100, // ajuste a largura conforme necessário
              height: 40, // ajuste a altura conforme necessário
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 244, 244, 243),
                      borderRadius: BorderRadius.circular(2)),
                  child: TabBar(
                      indicator: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 244, 244, 243),
                            width: 3),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      labelColor: const Color.fromARGB(255, 0, 0, 0),
                      unselectedLabelColor: const Color.fromARGB(255, 211, 207, 207),
                      tabs: const [
                        Tab(
                          child: Text(
                            'Conversas',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Usuários',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 10,),
              const Expanded(
                child: TabBarView(children: [
                  conversas_chat(),
                  usuarios_chat(),
                  
                ]),
              )
            ],
          ),
        ));
  }
}
