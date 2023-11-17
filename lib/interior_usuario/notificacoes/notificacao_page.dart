import 'package:flutter/material.dart';

class notificacao_page extends StatefulWidget {
  const notificacao_page({super.key});

  @override
  State<notificacao_page> createState() => _notificacao_pageState();
}

class _notificacao_pageState extends State<notificacao_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Colors.black,
          elevation: 0,
          leadingWidth: 26,
          backgroundColor: Colors.transparent,
          title: const Text('Notificações'),
        ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}