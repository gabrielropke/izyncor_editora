class Postagens {
  String? _idUsuario;
  String? _legenda;
  String?  _urlImagem;

  Postagens();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "legenda": legenda,
    };

    return map;
  }

  String get idUsuario => _idUsuario!;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get urlImagem => _urlImagem!;
 
  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get legenda => _legenda!;

  set legenda(String value) {
    _legenda = value;
  }
}
