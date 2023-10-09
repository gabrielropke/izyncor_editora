class Usuario {
  String? _idUsuario;
  String? _nome;
  String? _sobrenome;
  String? _email;
  String? _senha;
  String? _urlImagem;
  String? _nascimento;
  String? _cadastro;
  String? _seguidores;
  String? _biografia;
  String? _cpf;
  String? _username;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nome": this.nome,
      "username": this.username,
      "email": this.email,
      "sobrenome": this.sobrenome,
      "Nascimento": this.nascimento,
      "seguidores": 0,
      "seguindo": 0,
      "postagens": 0,
      "cpf": this.cpf,
      "Cadastro": 'Leitor(a)',
      "biografia": 'Boas vindas a Izyncor!',
      "urlImagem":
          'https://firebasestorage.googleapis.com/v0/b/izyncor-app-949df.appspot.com/o/perfil%2F130GNy50ahX6G9keTyhHsP3vQEu2.jpg?alt=media&token=9230ad6c-614d-4adf-bf00-257d1a45d725'
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

  String get cpf => _cpf!;

  set cpf(String value) {
    _cpf = value;
  }

  String get nome => _nome!;

  set nome(String value) {
    _nome = value;
  }

  String get biografia => _biografia!;

  set biografia(String value) {
    _biografia = value;
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
