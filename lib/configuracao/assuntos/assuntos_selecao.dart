import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class assuntos_selecao extends StatefulWidget {
  const assuntos_selecao({Key? key}) : super(key: key);

  @override
  State<assuntos_selecao> createState() => _assuntos_selecaoState();
}

// ignore: camel_case_types
class _assuntos_selecaoState extends State<assuntos_selecao> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<bool> selectedItems = List.generate(34, (index) => false);

  String? idUsuarioLogado;

  Future<void> recuperarDadosUsuario() async {
  User? usuarioLogado = auth.currentUser;
  idUsuarioLogado = usuarioLogado?.uid;

  if (idUsuarioLogado != null) {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuarioLogado)
        .collection('assuntos')
        .doc('assuntos')
        .get();

    if (snapshot.exists) {
      List<String> savedAssuntos = List<String>.from(snapshot.data()?['assunto'] ?? []);
      for (int i = 0; i < selectedItems.length; i++) {
        if (savedAssuntos.contains(_getContainerLabel(i + 1))) {
          setState(() {
            selectedItems[i] = true;
          });
        }
      }
    }
  }
}


  String _getContainerLabel(int index) {
    switch (index) {
      case 1:
        return 'Ficção Científica';
      case 2:
        return 'Fantasia';
      case 3:
        return 'Mistério/Thriller';
      case 4:
        return 'Romance';
      case 5:
        return 'Drama';
      case 6:
        return 'Aventura';
      case 7:
        return 'História Alternativa';
      case 8:
        return 'Distopia';
      case 9:
        return 'Não Ficção';
      case 10:
        return 'Ciência';
      case 11:
        return 'Autoajuda';
      case 12:
        return 'Mistério';
      case 13:
        return 'Suspense';
      case 14:
        return 'Terror';
      case 15:
        return 'Comédia';
      case 16:
        return 'História Real';
      case 17:
        return 'Romance Histórico';
      case 18:
        return 'Política';
      case 19:
        return 'Tecnologia';
      case 20:
        return 'Psicologia';
      case 21:
        return 'Didático';
      case 22:
        return 'Leitura Nacional';
      case 23:
        return 'Autores Nacionais';
      case 24:
        return 'Editoras';
      case 25:
        return 'Revisores de Texto';
      case 26:
        return 'Leitores críticos';
      case 27:
        return 'Mentores';
      case 28:
        return 'Preparadores de texto';
      case 29:
        return 'Editores';
      case 30:
        return 'Designer';
      case 31:
        return 'Capistas';
      case 32:
        return 'Ilustradores';
      case 33:
        return 'Influenciadores';
      case 34:
        return 'Thriller';
      default:
        return '';
    }
  }

  Future<void> setarAssuntos() async {
    if (idUsuarioLogado != null) {
      List<String> selectedAssuntos = [];
      for (int i = 0; i < selectedItems.length; i++) {
        if (selectedItems[i]) {
          selectedAssuntos.add(_getContainerLabel(i + 1));
        }
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(idUsuarioLogado)
          .collection('assuntos')
          .doc('assuntos')
          .set({
        'assunto': selectedAssuntos,
      });

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const home_principal(indexPagina: 2)));
      
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        title: const Text('Assuntos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                const Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Selecione os tópicos mais interessantes para você',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 34,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedItems[index] = !selectedItems[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32.0),
                            border: selectedItems[index]
                                ? Border.all(width: 1, color: Colors.white)
                                : Border.all(width: 1, color: Colors.black12),
                            color: selectedItems[index]
                                ? const Color.fromARGB(255, 190, 37, 96)
                                : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              _getContainerLabel(index + 1),
                              style: selectedItems[index]
                                  ? const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500)
                                  : const TextStyle(
                                      fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 5,
              child: GestureDetector(
                onTap: () {
                  setarAssuntos();
                },
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Text(
                      'Finalizar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
