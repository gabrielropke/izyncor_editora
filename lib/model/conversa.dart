import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  String? _idRemetente;
  String? _idDestinatario;
  String? _nome;
  String? _sobrenome;
  String? _mensagem;
  String? _caminhoFoto;
  String? _tipoMensagem;
  String? _autorMensagem;
  String? _hora;

  Conversa();

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("conversas")
        .doc(this.idRemetente)
        .collection("ultima_conversa")
        .doc(this.idDestinatario)
        .set(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "autorMensagem": this.autorMensagem,
      "nome": this.nome,
      "sobrenome": this.sobrenome,
      "mensagem": this.mensagem,
      "caminhoFoto": this.caminhoFoto,
      "tipoMensagem": this.tipoMensagem,
      "hora": this.hora,
    };

    return map;
  }

  String get idRemetente => _idRemetente!;

  set idRemetente(String value) {
    _idRemetente = value;
  }

  String get idDestinatario => _idDestinatario!;

  set idDestinatario(String value) {
    _idDestinatario = value;
  }

  String get hora => _hora!;

  set hora(String value) {
    _hora = value;
  }

  String get autorMensagem => _autorMensagem!;

  set autorMensagem(String value) {
    _autorMensagem = value;
  }

  String get sobrenome => _sobrenome!;

  set sobrenome(String value) {
    _sobrenome = value;
  }

  String get tipoMensagem => _tipoMensagem!;

  set tipoMensagem(String value) {
    _tipoMensagem = value;
  }

  String get nome => _nome!;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem!;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get caminhoFoto => _caminhoFoto!;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }
}
