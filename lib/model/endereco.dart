
class Endereco {

  String? _idUsuario;
  String? _logradouro;
  String? _numero;
  String? _complemento;
  String? _bairro;
  String? _cidade;
  String? _estado;
  String? _cep;
 
  
  Endereco();

  Map<String, dynamic> toMap(){

    Map<String, dynamic> map = {
      "logradouro" : this._logradouro,
      "numero" : this._numero,
      "complemento" : this._complemento,
      "bairro" : this._bairro,
      "cidade" : this._cidade,
      "estado" : this._estado,
      "cep" : this._cep,
    };

    return map;

  }

  String get idUsuario => _idUsuario!;
 
  set idUsuario(String value) {
    _idUsuario = value;
  }
  
  String get logradouro => _logradouro!;
 
  set logradouro(String value) {
    _logradouro = value;
  }

  String get numero => _numero!;
 
  set numero(String value) {
    _numero = value;
  }

  String get complemento => _complemento!;
 
  set complemento(String value) {
    _complemento = value;
  }

  String get bairro => _bairro!;
 
  set bairro(String value) {
    _bairro = value;
  }

  String get cidade => _cidade!;
 
  set cidade(String value) {
    _cidade = value;
  }

  String get estado => _estado!;
 
  set estado(String value) {
    _estado = value;
  }

  String get cep => _cep!;
 
  set cep(String value) {
    _cep = value;
  }
}