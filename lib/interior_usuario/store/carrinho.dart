// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class carrinho extends StatefulWidget {
//   const carrinho({Key? key});

//   @override
//   State<carrinho> createState() => _carrinhoState();
// }

// class _carrinhoState extends State<carrinho> {
//   FirebaseAuth auth = FirebaseAuth.instance;

//   String? idUsuarioLogado;

//   double somaTotal = 0.0;

//   List<Map<String, dynamic>> livrosCarrinho = [];

//   Future<void> recuperarDadosUsuario() async {
//     User? usuarioLogado = auth.currentUser;
//     idUsuarioLogado = usuarioLogado?.uid;
//   }

//   Future<void> fetchCarrinho() async {
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('carrinho')
//         .doc(idUsuarioLogado)
//         .collection('meuslivros')
//         .get();
//     List<Map<String, dynamic>> meuslivrosCarrinho = [];

//     for (var doc in querySnapshot.docs) {
//       Map<String, dynamic> postagensData = {
//         'titulo': doc.get('titulo'),
//         'capa': doc.get('capa'),
//         'genero': doc.get('genero'),
//         'hora': doc.get('hora'),
//         'idUsuario': doc.get('idUsuario'),
//         'isbn': doc.get('isbn'),
//         'valor': doc.get('valor'),
//         'quantidade': doc.get('quantidade')
//       };

//       meuslivrosCarrinho.add(postagensData);
//     }

//     setState(() {
//       livrosCarrinho = meuslivrosCarrinho;
//     });
//   }

//   void calcularSomaTotal() {
//     double total = 0.0;
//     for (var livro in livrosCarrinho) {
//       String valorString = livro['valor'].replaceAll('R\$ ', '');
//       valorString = valorString.replaceAll(',', '.');
//       double valor = double.parse(valorString);
//       int quantidade = livro['quantidade'];
//       total += valor * quantidade;
//     }
//     setState(() {
//       somaTotal = total;
//     });
//   }

//   double calcularValorTotal() {
//     double total = 0.0;
//     for (var livro in livrosCarrinho) {
//       String valorString = livro['valor'].replaceAll('R\$ ', '');
//       valorString = valorString.replaceAll(',', '.');
//       double valor = double.parse(valorString);
//       int quantidade = livro['quantidade'];
//       total += valor * quantidade;
//     }
//     return total;
//   }

//   @override
//   void initState() {
//     super.initState();
//     recuperarDadosUsuario();
//     livrosCarrinho = [];
//     fetchCarrinho();
//     calcularSomaTotal();
//     calcularValorTotal();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 245, 245, 245),
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         leadingWidth: 26,
//         backgroundColor: Colors.transparent,
//         title: const Text('Carrinho'),
//       ),
//       body: Stack(
//         children: [
//           StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('carrinho')
//                 .doc(idUsuarioLogado)
//                 .collection('meuslivros')
//                 .snapshots(),
//             builder:
//                 (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return const Text(
//                   'Ocorreu um erro ao carregar os comentários',
//                   style: TextStyle(fontSize: 16),
//                 );
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
//                 return const Center(
//                     child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.shopping_cart_outlined, color: Colors.black12, size: 82),
//                       Text(
//                         'Seu carrinho está vazio :(',
//                         style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: Colors.black26,
//                             fontSize: 16),
//                       )
//                     ],
//                   ),);
//               }
//               return ListView.builder(
//                   itemCount: livrosCarrinho.length,
//                   itemBuilder: (context, index) {
//                     final livro = livrosCarrinho[index];
//                     String valorComSimbolo = 'R\$ ${livro['valor']}';
//                     String valorString = livro['valor'].replaceAll('R\$ ', '');
//                     valorString = valorString.replaceAll(',', '.');

//                     return SingleChildScrollView(
//                       child: Stack(
//                         children: [
//                           Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: 180,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     color: Colors.white,
//                                   ),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding:
//                                                 const EdgeInsets.only(left: 20),
//                                             child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadiusDirectional
//                                                         .circular(12),
//                                                 child: Image.network(
//                                                   livro['capa'],
//                                                   width: 100,
//                                                 )),
//                                           ),
//                                           const SizedBox(width: 20),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(livro['titulo'],
//                                                   style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w500,
//                                                       color: Colors.black,
//                                                       fontSize: 20)),
//                                               const SizedBox(height: 10),
//                                               Text(valorComSimbolo,
//                                                   style: const TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 18)),
//                                               const SizedBox(height: 35),
//                                               Row(
//                                                 children: [
//                                                   GestureDetector(
//                                                     onTap: () {
//                                                       void
//                                                           diminuirQuantidade() {
//                                                         CollectionReference
//                                                             carrinhoCollection =
//                                                             FirebaseFirestore
//                                                                 .instance
//                                                                 .collection(
//                                                                     'carrinho');

//                                                         carrinhoCollection
//                                                             .doc(
//                                                                 idUsuarioLogado)
//                                                             .collection(
//                                                                 'meuslivros')
//                                                             .doc(livro['isbn'])
//                                                             .get()
//                                                             .then((doc) {
//                                                           if (doc.exists) {
//                                                             Map<String, dynamic>
//                                                                 data =
//                                                                 doc.data()
//                                                                     as Map<
//                                                                         String,
//                                                                         dynamic>;
//                                                             int quantidade =
//                                                                 data['quantidade'] ??
//                                                                     0;

//                                                             if (quantidade >=
//                                                                 0) {
//                                                               carrinhoCollection
//                                                                   .doc(
//                                                                       idUsuarioLogado)
//                                                                   .collection(
//                                                                       'meuslivros')
//                                                                   .doc(livro[
//                                                                       'isbn'])
//                                                                   .update({
//                                                                 'quantidade':
//                                                                     quantidade -
//                                                                         1
//                                                               });
//                                                             }
//                                                             fetchCarrinho();
//                                                           }
//                                                         });
//                                                       }

//                                                       diminuirQuantidade();
//                                                     },
//                                                     child: Container(
//                                                       width: 45,
//                                                       height: 45,
//                                                       decoration: BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(8),
//                                                           color: const Color
//                                                               .fromARGB(255,
//                                                               241, 241, 241)),
//                                                       child: const Center(
//                                                           child: Text('-',
//                                                               style: TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w300,
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize:
//                                                                       20))),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 20),
//                                                   StreamBuilder<
//                                                       DocumentSnapshot>(
//                                                     stream: FirebaseFirestore
//                                                         .instance
//                                                         .collection('carrinho')
//                                                         .doc(idUsuarioLogado)
//                                                         .collection(
//                                                             'meuslivros')
//                                                         .doc(livro['isbn'])
//                                                         .snapshots(),
//                                                     builder:
//                                                         (context, snapshot) {
//                                                       if (!snapshot.hasData) {
//                                                         return const Text(
//                                                             '0', // Ou qualquer outro valor padrão
//                                                             style: TextStyle());
//                                                       }

//                                                       final quantidade =
//                                                           snapshot.data!.get(
//                                                               'quantidade');
//                                                       return Text('$quantidade',
//                                                           style:
//                                                               const TextStyle());
//                                                     },
//                                                   ),
//                                                   const SizedBox(width: 20),
//                                                   GestureDetector(
//                                                     onTap: () {
//                                                       void
//                                                           aumentarQuantidade() {
//                                                         CollectionReference
//                                                             carrinhoCollection =
//                                                             FirebaseFirestore
//                                                                 .instance
//                                                                 .collection(
//                                                                     'carrinho');

//                                                         carrinhoCollection
//                                                             .doc(
//                                                                 idUsuarioLogado)
//                                                             .collection(
//                                                                 'meuslivros')
//                                                             .doc(livro['isbn'])
//                                                             .get()
//                                                             .then((doc) {
//                                                           if (doc.exists) {
//                                                             Map<String, dynamic>
//                                                                 data =
//                                                                 doc.data()
//                                                                     as Map<
//                                                                         String,
//                                                                         dynamic>;
//                                                             int quantidade =
//                                                                 data['quantidade'] ??
//                                                                     0;

//                                                             if (quantidade >=
//                                                                 0) {
//                                                               carrinhoCollection
//                                                                   .doc(
//                                                                       idUsuarioLogado)
//                                                                   .collection(
//                                                                       'meuslivros')
//                                                                   .doc(livro[
//                                                                       'isbn'])
//                                                                   .update({
//                                                                 'quantidade':
//                                                                     quantidade +
//                                                                         1
//                                                               });
//                                                             }
//                                                             fetchCarrinho();
//                                                           }
//                                                         });
//                                                       }

//                                                       aumentarQuantidade();
//                                                     },
//                                                     child: Container(
//                                                       width: 45,
//                                                       height: 45,
//                                                       decoration: BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(8),
//                                                           color: const Color
//                                                               .fromARGB(255,
//                                                               241, 241, 241)),
//                                                       child: const Center(
//                                                           child: Text('+',
//                                                               style: TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w300,
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontSize:
//                                                                       20))),
//                                                     ),
//                                                   )
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                             ],
//                           ),
//                           Positioned(
//                               top: 20,
//                               right: 20,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   void excluirLivro(String isbn) {
//                                     CollectionReference livrosExcluirColecao =
//                                         FirebaseFirestore.instance
//                                             .collection('carrinho')
//                                             .doc(idUsuarioLogado)
//                                             .collection('meuslivros');

//                                     // Excluir o documento do Firestore
//                                     livrosExcluirColecao
//                                         .doc(livro['isbn'])
//                                         .delete();
//                                     // Chamar fetchFeed novamente após a exclusão
//                                     fetchCarrinho();
//                                   }

//                                   excluirLivro(livro['isbn']);
//                                 },
//                                 child: const Icon(
//                                   Icons.delete_outline_rounded,
//                                   size: 26,
//                                   color: Colors.black45,
//                                 ),
//                               )),
//                         ],
//                       ),
//                     );
//                   });
//             },
//           ),
//           Positioned(
//               right: 20,
//               bottom: 20,
//               child: Row(
//                 children: [
//                   Container(
//                     width: 165,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(32),
//                       color: Colors.white,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text('Subtotal',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black,
//                                 fontSize: 16)),
//                         Text(
//                           'R\$ ${calcularValorTotal().toStringAsFixed(2)}',
//                           style: const TextStyle(
//                               color: Colors.black, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Container(
//                     width: 70,
//                     height: 70,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.black,
//                     ),
//                     child: const Icon(Icons.shopping_cart_checkout_rounded,
//                         color: Colors.white, size: 26),
//                   ),
//                 ],
//               )),
//         ],
//       ),
//     );
//   }
// }
