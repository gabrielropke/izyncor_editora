import 'package:flutter/material.dart';

class icone_documentos extends StatelessWidget {
  const icone_documentos({super.key, required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    if (mensagem.toLowerCase().endsWith('pdf')) {
      return SizedBox(
        child: Image.asset('assets/icone_pdf.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('zip')) {
      return SizedBox(
        child: Image.asset('assets/icone_zip.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('mp4')) {
      return SizedBox(
        child: Image.asset('assets/icone_video.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('AVI')) {
      return SizedBox(
        child: Image.asset('assets/icone_video.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('WMV')) {
      return SizedBox(
        child: Image.asset('assets/icone_video.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('MKV')) {
      return SizedBox(
        child: Image.asset('assets/icone_video.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('MOV')) {
      return SizedBox(
        child: Image.asset('assets/icone_video.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('jpg')) {
      return SizedBox(
        child: Image.asset('assets/icone_imagem.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('jpeg')) {
      return SizedBox(
        child: Image.asset('assets/icone_imagem.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('png')) {
      return SizedBox(
        child: Image.asset('assets/icone_imagem.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('pptx')) {
      return SizedBox(
        child: Image.asset('assets/icone_powerpoint.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('xls')) {
      return SizedBox(
        child: Image.asset('assets/icone_excel.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('xlsx')) {
      return SizedBox(
        child: Image.asset('assets/icone_excel.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('xlsm')) {
      return SizedBox(
        child: Image.asset('assets/icone_excel.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('doc')) {
      return SizedBox(
        child: Image.asset('assets/icone_word.png'),
      );
    } else if (mensagem.toLowerCase().endsWith('docx')) {
      return SizedBox(
        child: Image.asset('assets/icone_word.png'),
      );
    } else {
      return SizedBox(
        child: Image.asset('assets/icone_doc2.png', color: Colors.white),
      );
    }
  }
}
