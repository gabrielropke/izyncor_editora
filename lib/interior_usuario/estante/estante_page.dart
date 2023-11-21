import 'package:flutter/material.dart';

class estante_page extends StatefulWidget {
  const estante_page({super.key});

  @override
  State<estante_page> createState() => _estante_pageState();
}

class _estante_pageState extends State<estante_page> {
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Estante vazia')
            ],
          ),
        ),
      ),
    );
  }
}