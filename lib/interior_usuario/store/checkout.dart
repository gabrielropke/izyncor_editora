// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class checkout extends StatefulWidget {
//   const checkout({Key? key});

//   @override
//   _checkoutState createState() => _checkoutState();
// }

// class _checkoutState extends State<checkout> {
//   String metodoEntregaSelecionado = '';
//   String? _idUsuarioLogado;
//   String metodoPagamentoSelecionado = '';

//   StreamController<String> streamLOGRADOURO = StreamController<String>();
//   StreamController<String> streamNUMERO = StreamController<String>();
//   StreamController<String> streamCEP = StreamController<String>();
//   StreamController<String> streamBAIRRO = StreamController<String>();
//   StreamController<String> streamCIDADE = StreamController<String>();
//   StreamController<String> streamESTADO = StreamController<String>();
//   StreamController<String> streamCOMP = StreamController<String>();

//   StreamController<String> stramNOME = StreamController<String>();
//   StreamController<String> stramSOBRENOME = StreamController<String>();
//   StreamController<String> stramEMAIL = StreamController<String>();
//   StreamController<String> stramCPF = StreamController<String>();
//   StreamController<String> stramTELEFONE = StreamController<String>();

//   bool mostrarContainer = true;

//   TextEditingController _nameController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//   TextEditingController _pixKeyController = TextEditingController();
//   TextEditingController _boletoController = TextEditingController();
//   TextEditingController _cartaoController = TextEditingController();

//   final GlobalKey<FormState> _enderecoFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> _dadospessoaisFormKey = GlobalKey<FormState>();

//   List<String> metodosEntrega = [
//     'Frete grátis',
//     'Retirada no local',
//   ];

//   List<String> metodosPagamento = [
//     'Débito ou crédito',
//     'Pix',
//     'Boleto',
//   ];

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _addressController.dispose();
//     _pixKeyController.dispose();
//     _boletoController.dispose();
//     _cartaoController.dispose();
//     super.dispose();
//   }

//   void _exibirPopupEnderecoEntrega() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Editar Endereço de Entrega'),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _enderecoFormKey,
//               child: _EnderecoEntrega(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Realize as ações necessárias ao clicar em "Salvar"
//                 if (_enderecoFormKey.currentState!.validate()) {
//                   // Validação passou, salve os dados e feche o popup
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: Text('Salvar'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Feche o popup ao clicar em "Cancelar"
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancelar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _exibirPopupDadosPessoais() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Editar dados pessoais'),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _dadospessoaisFormKey,
//               child: _DadosPessoais(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 // Realize as ações necessárias ao clicar em "Salvar"
//                 if (_enderecoFormKey.currentState!.validate()) {
//                   // Validação passou, salve os dados e feche o popup
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: Text('Salvar'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Feche o popup ao clicar em "Cancelar"
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancelar'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   recuperarDadosUsuario() async {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? usuarioLogado = auth.currentUser;
//     _idUsuarioLogado = usuarioLogado?.uid;

//     FirebaseFirestore db = FirebaseFirestore.instance;
//     DocumentSnapshot snapshot =
//         await db.collection("enderecos").doc(_idUsuarioLogado).get();

//     Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
//     streamLOGRADOURO.add(dados["logradouro"]);
//     streamNUMERO.add(dados["numero"]);
//     streamCEP.add(dados["cep"]);
//     streamBAIRRO.add(dados["bairro"]);
//     streamCIDADE.add(dados["cidade"]);
//     streamESTADO.add(dados["uf"]);
//     streamCOMP.add(dados["complemento"]);

//     FirebaseFirestore db2 = FirebaseFirestore.instance;
//     DocumentSnapshot snapshot2 =
//         await db2.collection("usuarios").doc(_idUsuarioLogado).get();

//     Map<String, dynamic> dados2 = snapshot2.data() as Map<String, dynamic>;
//     stramNOME.add(dados2["nome"]);
//     stramSOBRENOME.add(dados2["sobrenome"]);
//     stramEMAIL.add(dados2["email"]);
//     stramCPF.add(dados2["cpf"]);
//     stramTELEFONE.add(dados2["telefone"]);
//   }

//   Future<String> buscarUIDUsuarioLogado() async {
//     FirebaseFirestore db = FirebaseFirestore.instance;
//     DocumentSnapshot snapshot =
//         await db.collection("enderecos").doc(_idUsuarioLogado).get();

//     if (snapshot.exists) {
//       return 'sim';
//     } else {
//       return 'nao';
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     recuperarDadosUsuario();
//     buscarUIDUsuarioLogado().then((value) {
//       if (value == 'sim') {
//         setState(() {
//           mostrarContainer = true;
//         });
//         // UID encontrado
//         // Atualize os StreamControllers com os dados do endereço
//       } else {
//         setState(() {
//           mostrarContainer = false;
//         });
//         // UID não encontrado
//         // Realize as ações necessárias
//       }
//     });
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 238, 238, 238),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leadingWidth: 30,
//         foregroundColor: Colors.black,
//         title: const Text('Checkout'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               const Align(
//                   alignment: Alignment.bottomLeft,
//                   child:
//                       Text('Dados pessoais', style: TextStyle(fontSize: 16))),
//               const SizedBox(height: 10),
//               Container(
//                 width: double.infinity,
//                 height: 130,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: Stack(
//                     children: [
//                       SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 StreamBuilder<String>(
//                                   stream: stramNOME.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                                 const Text(' '),
//                                 StreamBuilder<String>(
//                                   stream: stramSOBRENOME.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5),
//                             StreamBuilder<String>(
//                               stream: stramTELEFONE.stream,
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   final phoneNumber = snapshot.data!;
//                                   final formattedPhoneNumber =
//                                       '(${phoneNumber.substring(0, 2)}) ${phoneNumber.substring(2, 3)} ${phoneNumber.substring(3, 7)}-${phoneNumber.substring(7)}';
//                                   return Align(
//                                     alignment: Alignment.topLeft,
//                                     child: Text(
//                                       formattedPhoneNumber,
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   );
//                                 } else if (snapshot.hasError) {
//                                   return const Text('');
//                                 } else {
//                                   return const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   );
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 5),
//                             StreamBuilder<String>(
//                               stream: stramEMAIL.stream,
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   return Align(
//                                     alignment: Alignment.topLeft,
//                                     child: Text(
//                                       snapshot.data!,
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   );
//                                 } else if (snapshot.hasError) {
//                                   return const Text('');
//                                 } else {
//                                   return const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   );
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 5),
//                             StreamBuilder<String>(
//                               stream: stramCPF.stream,
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasData) {
//                                   final cpf = snapshot.data!;
//                                   final formattedCPF =
//                                       '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9, 11)}';

//                                   return Align(
//                                     alignment: Alignment.topLeft,
//                                     child: Text(
//                                       formattedCPF,
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   );
//                                 } else if (snapshot.hasError) {
//                                   return const Text('');
//                                 } else {
//                                   return const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   );
//                                 }
//                               },
//                             )
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                           top: 30,
//                           bottom: 30,
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: () {
//                               _exibirPopupDadosPessoais();
//                             },
//                             child: Container(
//                               width: 60,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                   color:
//                                       const Color.fromARGB(255, 238, 238, 238),
//                                   borderRadius: BorderRadius.circular(6)),
//                               child: const Center(
//                                 child: Text('Editar'),
//                               ),
//                             ),
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               const Align(
//                   alignment: Alignment.bottomLeft,
//                   child: Text('Endereço de entrega',
//                       style: TextStyle(fontSize: 16))),
//               const SizedBox(height: 10),
//               Container(
//                 width: double.infinity,
//                 height: 110,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: Stack(
//                     children: [
//                       SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 StreamBuilder<String>(
//                                   stream: streamLOGRADOURO.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                                 const SizedBox(width: 5),
//                                 StreamBuilder<String>(
//                                   stream: streamNUMERO.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               children: [
//                                 const Text(
//                                   'CEP ',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                                 StreamBuilder<String>(
//                                   stream: streamCEP.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                                 const Text(
//                                   ' - ',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                                 StreamBuilder<String>(
//                                   stream: streamBAIRRO.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 5),
//                             Row(
//                               children: [
//                                 StreamBuilder<String>(
//                                   stream: streamCIDADE.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                                 const Text(
//                                   ' - ',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey,
//                                       fontWeight: FontWeight.w400),
//                                 ),
//                                 StreamBuilder<String>(
//                                   stream: streamESTADO.stream,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData) {
//                                       return Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           snapshot.data!,
//                                           style: const TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey,
//                                               fontWeight: FontWeight.w400),
//                                         ),
//                                       );
//                                     } else if (snapshot.hasError) {
//                                       return const Text('');
//                                     } else {
//                                       return const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                           top: 20,
//                           bottom: 20,
//                           right: 0,
//                           child: GestureDetector(
//                             onTap: () {
//                               _exibirPopupEnderecoEntrega();
//                             },
//                             child: Container(
//                               width: 60,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                   color:
//                                       const Color.fromARGB(255, 238, 238, 238),
//                                   borderRadius: BorderRadius.circular(6)),
//                               child: const Center(
//                                 child: Text('Editar'),
//                               ),
//                             ),
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               ExpansionTile(
//                 title: const Row(
//                   children: [
//                     Icon(Icons.emoji_transportation, color: Colors.grey),
//                     SizedBox(width: 10),
//                     Text(
//                       'Método de entrega',
//                       style: TextStyle(fontWeight: FontWeight.w400),
//                     ),
//                   ],
//                 ),
//                 onExpansionChanged: (value) {
//                   setState(() {});
//                 },
//                 children: [
//                   const SizedBox(height: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: metodosEntrega.map((metodo) {
//                       return RadioListTile<String>(
//                         title: Text(metodo),
//                         value: metodo,
//                         groupValue: metodoEntregaSelecionado,
//                         onChanged: (value) {
//                           setState(() {
//                             metodoEntregaSelecionado = value!;
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               ExpansionTile(
//                 title: const Row(
//                   children: [
//                     Icon(Icons.payment, color: Colors.grey),
//                     SizedBox(width: 10),
//                     Text(
//                       'Método de pagamento',
//                       style: TextStyle(fontWeight: FontWeight.w400),
//                     ),
//                   ],
//                 ),
//                 onExpansionChanged: (value) {
//                   setState(() {});
//                 },
//                 children: [
//                   const SizedBox(height: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: metodosPagamento.map((metodo) {
//                       return RadioListTile<String>(
//                         title: Text(metodo),
//                         value: metodo,
//                         groupValue: metodoPagamentoSelecionado,
//                         onChanged: (value) {
//                           setState(() {
//                             metodoPagamentoSelecionado = value!;
//                           });
//                         },
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   if (metodoPagamentoSelecionado == 'Pix') _buildPixFields(),
//                   if (metodoPagamentoSelecionado == 'Boleto')
//                     _buildBoletoFields(),
//                   if (metodoPagamentoSelecionado == 'Débito ou crédito')
//                     _buildCartao(),
//                 ],
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCartao() {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               width: double.infinity,
//               height: 700,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(18.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.payment, size: 22, color: Colors.black),
//                         SizedBox(width: 10),
//                         Text('Cartão',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Preencha os dados do seu cartão',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 40),
//                     const Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Text('Número do cartão')),
//                     const SizedBox(height: 5),
//                     SizedBox(
//                       width: double.infinity,
//                       child: TextField(
//                         maxLength: 16,
//                         keyboardType: TextInputType.number,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: const BorderSide(color: Colors.grey)),
//                           contentPadding:
//                               const EdgeInsets.fromLTRB(32, 15, 32, 16),
//                           hintText: '0000 0000 0000 0000',
//                           hintStyle: const TextStyle(
//                               color: Color.fromARGB(255, 189, 185, 185),
//                               fontWeight: FontWeight.w400),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Text('Nome do titular (como no cartão)')),
//                     const SizedBox(height: 5),
//                     SizedBox(
//                       width: double.infinity,
//                       child: TextField(
//                         keyboardType: TextInputType.name,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: const BorderSide(color: Colors.grey)),
//                           contentPadding:
//                               const EdgeInsets.fromLTRB(32, 15, 32, 16),
//                           hintText: 'Ex: Leandro Chagas',
//                           hintStyle: const TextStyle(
//                               color: Color.fromARGB(255, 189, 185, 185),
//                               fontWeight: FontWeight.w400),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Text('Vencimento')),
//                     const SizedBox(height: 5),
//                     SizedBox(
//                       width: double.infinity,
//                       child: TextField(
//                         keyboardType: TextInputType.name,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: const BorderSide(color: Colors.grey)),
//                           contentPadding:
//                               const EdgeInsets.fromLTRB(32, 15, 32, 16),
//                           hintText: 'mm/aa',
//                           hintStyle: const TextStyle(
//                               color: Color.fromARGB(255, 189, 185, 185),
//                               fontWeight: FontWeight.w400),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Align(
//                         alignment: Alignment.bottomLeft, child: Text('CVV')),
//                     const SizedBox(height: 5),
//                     SizedBox(
//                       width: double.infinity,
//                       child: TextField(
//                         maxLength: 3,
//                         keyboardType: TextInputType.name,
//                         style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8)),
//                           enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: const BorderSide(color: Colors.grey)),
//                           contentPadding:
//                               const EdgeInsets.fromLTRB(32, 15, 32, 16),
//                           hintText: '123',
//                           hintStyle: const TextStyle(
//                               color: Color.fromARGB(255, 189, 185, 185),
//                               fontWeight: FontWeight.w400),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     const Text('Ao continuar você concorda com nossos'),
//                     const Text('Termos e condições',
//                         style: TextStyle(color: Colors.blue)),
//                     const SizedBox(height: 30),
//                     Container(
//                       width: 150,
//                       height: 40,
//                       decoration: BoxDecoration(
//                           color: Colors.blueGrey,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: const Center(
//                           child: Text(
//                         'Continuar',
//                         style: TextStyle(color: Colors.white),
//                       )),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPixFields() {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               width: double.infinity,
//               height: 300,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(18.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.pix,
//                           size: 22,
//                           color: Color.fromARGB(255, 76, 175, 137),
//                         ),
//                         SizedBox(width: 10),
//                         Text('Pix',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Pague de forma segura e instantânea',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     const Text(
//                       'Ao confirmar a compra, nós vamos te mostrar o código para fazer o pagamento.',
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 30),
//                     const Text('Ao continuar você concorda com nossos'),
//                     const Text('Termos e condições',
//                         style: TextStyle(color: Colors.blue)),
//                     const SizedBox(height: 30),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => metodo_pix()));
//                       },
//                       child: Container(
//                         width: 150,
//                         height: 40,
//                         decoration: BoxDecoration(
//                             color: Colors.blueGrey,
//                             borderRadius: BorderRadius.circular(8)),
//                         child: const Center(
//                             child: Text(
//                           'Continuar',
//                           style: TextStyle(color: Colors.white),
//                         )),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _EnderecoEntrega() {
//     return Column(
//       children: [
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             maxLength: 8,
//             keyboardType: TextInputType.number,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'CEP',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.name,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'UF',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.name,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'Cidade',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.name,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'Bairro',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.name,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'Logradouro',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.number,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'N°',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.text,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'Complemento (opcional)',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _DadosPessoais() {
//     return Column(
//       children: [
//         TextField(
//           controller: _nameController,
//           keyboardType: TextInputType.name,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(color: Colors.grey)),
//             contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//             labelText: 'Nome',
//             hintStyle: const TextStyle(
//                 color: Color.fromARGB(255, 189, 185, 185),
//                 fontWeight: FontWeight.w400),
//           ),
//         ),
//         const SizedBox(height: 10),
//         TextField(
//           controller: _addressController,
//           keyboardType: TextInputType.name,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(color: Colors.grey)),
//             contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//             labelText: 'Sobrenome',
//             hintStyle: const TextStyle(
//                 color: Color.fromARGB(255, 189, 185, 185),
//                 fontWeight: FontWeight.w400),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.name,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'Telefone',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         TextField(
//           keyboardType: TextInputType.name,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: const BorderSide(color: Colors.grey)),
//             contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//             labelText: 'E-mail',
//             hintStyle: const TextStyle(
//                 color: Color.fromARGB(255, 189, 185, 185),
//                 fontWeight: FontWeight.w400),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           width: double.infinity,
//           child: TextField(
//             keyboardType: TextInputType.name,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//             ),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: Colors.white,
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(color: Colors.grey)),
//               contentPadding: const EdgeInsets.fromLTRB(32, 15, 32, 16),
//               labelText: 'CPF',
//               hintStyle: const TextStyle(
//                   color: Color.fromARGB(255, 189, 185, 185),
//                   fontWeight: FontWeight.w400),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildBoletoFields() {
//     return Column(
//       children: [
//         Stack(
//           children: [
//             Container(
//               width: double.infinity,
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(18.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                             width: 25, child: Image.asset('assets/boleto.jpg')),
//                         const SizedBox(width: 10),
//                         const Text('Boleto',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18)),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     const Text('Ao continuar você concorda com nossos'),
//                     const Text('Termos e condições',
//                         style: TextStyle(color: Colors.blue)),
//                     const SizedBox(height: 30),
//                     Container(
//                       width: 150,
//                       height: 40,
//                       decoration: BoxDecoration(
//                           color: Colors.blueGrey,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: const Center(
//                           child: Text(
//                         'Continuar',
//                         style: TextStyle(color: Colors.white),
//                       )),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
