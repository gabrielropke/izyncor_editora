class Google {
  String? _idUsuario;
  String? _nascimento;
  String? _username;

  Google();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nascimento": nascimento,
      "cadastro": 'Leitor(a)',
      "username": username,
    };

    return map;
  }

  String get idUsuario => _idUsuario!;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get username => _username!;

  set username(String value) {
    _username = value;
  }

  String get nascimento => _nascimento!;

  set nascimento(String value) {
    _nascimento = value;
  }
}