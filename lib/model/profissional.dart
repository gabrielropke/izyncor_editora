class UsuarioProfissional {

  String? _idUsuario;
  String? _nome;
  String? _sobrenome;
  String? _email;
  String? _senha;
  String? _urlImagem;
  String? _nascimento;
  String? _cadastro;
  String? _seguidores;
  String? _cargo;
 
  UsuarioProfissional();

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "nome" : this.nome,
      "email" : this.email,
      "cargo" : this.cargo,
      "sobrenome" : this.sobrenome,
      "Nascimento" : this.nascimento,
      "seguidores" : this._seguidores,
      "Cadastro" : 'Equipe Izyncor',
    };

    return map;

  }

  String get idUsuario => _idUsuario!;
 
  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get cargo => _cargo!;
 
  set cargo(String value) {
    _cargo = value;
  }

  String get nome => _nome!;
 
  set nome(String value) {
    _nome = value;
  }

  String get sobrenome => _sobrenome!;
 
  set sobrenome(String value) {
    _sobrenome = value;
  }
 
  String get email => _email!;
 
  set email(String value) {
    _email = value;
  }
 
  String get senha => _senha!;
 
  set senha(String value) {
    _senha = value;
  }

  String get nascimento => _nascimento!;
 
  set nascimento(String value) {
    _nascimento = value;
  }

  String get urlImagem => _urlImagem!;
 
  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get cadastro => _cadastro!;
 
  set cadastro(String value) {
    _cadastro = value;
  }

  String get seguidores => _seguidores!;
 
  set seguidores(String value) {
    _seguidores = value;
  }

}