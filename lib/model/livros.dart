class Livros {
  String? _idUsuario;
  String? _capa;
  String? _background;
  String? _titulo;
  String? _autor;
  String? _ano;
  String? _editora;
  String? _genero;
  String? _sinopse;
  String? _paginas;
  String? _tipocapa;
  String? _tipomiolo;
  String? _impressao;
  String? _isbn;
  String? _bisac;
  String? _editores;
  String? _revisores;
  String? _preparadores;
  String? _diagramacao;
  String? _valor;
  String? _ilustradores;
  String? _designers;
  String? _idioma;
  String? _dimensao;
  String? _idademinima;
  String? _contador;
  String? _nota;

  Livros();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "capa": this.capa,
      "background": this.background,
      "titulo": this.titulo,
      "autor": this.autor,
      "ano": this.ano,
      "editora": this.editora,
      "genero": this.genero,
      "sinopse": this.sinopse,
      "paginas": this.paginas,
      "tipocapa": this.tipocapa,
      "tipomiolo": this.tipomiolo,
      "impressao": this.impressao,
      "isbn": this.isbn,
      "bisac": this.bisac,
      "editores": this.editores,
      "revisores": this.revisores,
      "preparadores": this.preparadores,
      "diagramacao": this.diagramacao,
      "valor": this.valor,
      "ilustradores": this.ilustradores,
      "designers": this.designers,
      "idioma": this.idioma,
      "dimensao": this.dimensao,
      "idademinima": this.idademinima,
      "contador": this.contador,
      "nota": this.nota,
    };

    return map;
  }

  String get titulo => _titulo!;

  set titulo(String value) {
    _titulo = value;
  }

  String get contador => _contador!;
 
  set contador(String value) {
    _contador = value;
  }

  String get nota => _nota!;
 
  set nota(String value) {
    _nota = value;
  }

  String get idioma => _idioma!;

  set idioma(String value) {
    _idioma = value;
  }

  String get dimensao => _dimensao!;

  set dimensao(String value) {
    _dimensao = value;
  }

  String get idademinima => _idademinima!;

  set idademinima(String value) {
    _idademinima = value;
  }

  String get ilustradores=> _ilustradores!;

  set ilustradores(String value) {
    _ilustradores = value;
  }

  String get designers => _designers!;

  set designers(String value) {
    _designers = value;
  }

  String get background => _background!;

  set background(String value) {
    _background = value;
  }

  String get valor => _valor!;

  set valor(String value) {
    _valor = value;
  }
  
  String get capa => _capa!;

  set capa(String value) {
    _capa = value;
  }


  String get impressao => _impressao!;

  set impressao(String value) {
    _impressao = value;
  }

  String get sinopse => _sinopse!;

  set sinopse(String value) {
    _sinopse = value;
  }

  String get isbn => _isbn!;

  set isbn(String value) {
    _isbn = value;
  }

  String get bisac => _bisac!;

  set bisac(String value) {
    _bisac = value;
  }

  String get editores => _editores!;

  set editores(String value) {
    _editores = value;
  }

  String get revisores => _revisores!;

  set revisores(String value) {
    _revisores = value;
  }

  String get preparadores => _preparadores!;

  set preparadores(String value) {
    _preparadores = value;
  }

  String get diagramacao => _diagramacao!;

  set diagramacao(String value) {
    _diagramacao = value;
  }

  String get autor => _autor!;

  set autor(String value) {
    _autor = value;
  }

  String get ano => _ano!;

  set ano(String value) {
    _ano = value;
  }

  String get editora => _editora!;

  set editora(String value) {
    _editora = value;
  }

  String get idUsuario => _idUsuario!;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get genero => _genero!;

  set genero(String value) {
    _genero = value;
  }

  String get paginas => _paginas!;

  set paginas(String value) {
    _paginas = value;
  }

  String get tipocapa => _tipocapa!;

  set tipocapa(String value) {
    _tipocapa = value;
  }

  String get tipomiolo => _tipomiolo!;

  set tipomiolo(String value) {
    _tipomiolo = value;
  }
}
