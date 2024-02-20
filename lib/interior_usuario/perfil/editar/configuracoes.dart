import 'package:editora_izyncor_app/configuracao/itens/base%20endere%C3%A7o.dart';
import 'package:editora_izyncor_app/interior_usuario/perfil/editar/minha_conta.dart';
import 'package:editora_izyncor_app/widgets/alerta_izyncor.dart';
import 'package:flutter/material.dart';

class configuracoes extends StatelessWidget {
  const configuracoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 26,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const minha_conta()));
                AlertasIzyncor.mostrarAlerta(context,
                    'Estes dados são sigilosos.\nUtilizaremos eles apenas para futuras compras.');
              },
              child: const container_widget(
                titulo: 'Informações pessoais',
                subtitulo: 'Essas informações são privadas',
                icone: Icon(Icons.info_outline_rounded, size: 26),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const base_endereco()));
              },
              child: const container_widget(
                titulo: 'Cadastro de endereços',
                subtitulo: 'Facilite sua vida com os envios',
                icone: Icon(Icons.add_location_alt_outlined, size: 26),
              ),
            ),
            // const SizedBox(height: 12),
            // GestureDetector(
            //   onTap: () {},
            //   child: const container_widget(
            //     titulo: 'Dados de faturamento',
            //     subtitulo: 'Cadastre seus dados de cartão',
            //     icone: Icon(Icons.payment_rounded, size: 26),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class container_widget extends StatelessWidget {
  const container_widget(
      {super.key,
      required this.icone,
      required this.titulo,
      required this.subtitulo});

  final Widget icone;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icone,
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.black45),
                    ),
                  ],
                )
              ],
            ),
            const Icon(Icons.arrow_right_outlined, size: 26),
          ],
        ),
      ),
    );
  }
}
