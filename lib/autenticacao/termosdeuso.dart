import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/recepcao/recepcao.dart';
import 'package:flutter/material.dart';

class TermosDeUso extends StatefulWidget {
  final String idUsuarioLogado;
  final bool aceito;
  const TermosDeUso(
      {super.key, required this.idUsuarioLogado, required this.aceito});

  @override
  State<TermosDeUso> createState() => _TermosDeUsoState();
}

class _TermosDeUsoState extends State<TermosDeUso> {
  late String idUsuarioLogado;
  late bool aceito;
  void aceitarTermos() async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(idUsuarioLogado)
        .update({
      'termos': 'aceito',
    });
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const recepcao()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    idUsuarioLogado = widget.idUsuarioLogado;
    aceito = widget.aceito;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Conheça nossas Políticas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Center(child: Image.asset('assets/logo2.png')),
            ),
            const PoliticasTexto(corpoTexto: '''Política de Privacidade
Esta Política de Privacidade aplica-se à todos os usuários e visitantes do site/ aplicativo, bem como integra os Termos e Condições Gerais de Uso da EDITORIAL E SOCIAL NETWORK L&T IZYNCOR LTDA., devidamente inscrita no CNPJ nº 42.947.173/0001-61, doravante nominada “Izyncor”.

A presente Política de Privacidade contém informações sobre coleta, uso, armazenamento, tratamento e proteção de dados pessoais dos usuários e visitantes dos sites e aplicativos de propriedade da Organização Izyncor, com a finalidade de demonstrar absoluta transparência quanto ao assunto e esclarecer a todos os interessados sobre os tipos de dados que serão coletados, bem como os motivos de sua coleta e a forma como os usuários podem gerenciar ou excluir informações pessoais.

O presente documento foi elaborado em consonância com a Lei Geral de Proteção de Dados – LGPD (Lei nº 13.709/18), com o Marco Civil da Internet (Lei 12.965/14) e com o Regulamento da UE nº 2016/6.790.

1. RECOLHIMENTO DE DADOS PESSOAIS DE USUÁRIOS E VISITANTES
Os dados pessoais de usuários e visitantes são recolhidos por esta plataforma da seguinte forma:

a) Quando o usuário cria uma conta/perfil:
Dados básicos de identificação como e-mail, nome completo, cidade em que reside, telefone e profissão;
A partir dos dados supracitados, a plataforma poderá identificar o usuário, além de garantir uma maior segurança e bem-estar para atender às suas necessidades;
Ficam cientes os usuários de que seu perfil na plataforma estará acessível a todos os demais usuários e visitantes da presente plataforma.
b) Quando o visitante ou usuários acessa o aplicativo ou às páginas do site:
As informações sobre interação e acesso são coletadas pela empresa para garantir uma melhor experiência ao usuário e visitante;
Os dados supracitados podem tratar sobre palavras-chaves utilizadas em buscas, o compartilhamento de um documento específico, comentários, visualizações de páginas e perfis, a URL de onde provêm o usuário e o visitante, o navegador por eles utilizados, bem como seus IPs de acesso, dentre outras informações que poderão ser armazenadas e retidas.
c) Por intermédio de terceiros:
A presente plataforma recebe dados de terceiros, como Google e Facebook, quando o usuário realiza o login com seu perfil de um desses sites.
A utilização destes dados é autorizada previamente pelos usuários junto ao terceiro em questão;
A presente plataforma não repassa as informações colhidas de seus usuários e visitantes a terceiros, exceto àqueles previstos no item 6.3 do presente documento.
 

1.1 A plataforma esclarece que os dados pessoais são tratados de forma confidencial, e que todas as medidas de segurança necessárias para garantir a proteção destes dados são tomadas por essa.

2. DADOS A SEREM RECOLHIDOS DO USUÁRIO E DO VISITANTE
2.1 Serão recolhidos os seguintes dados pessoais do visitante e do usuário da plataforma:

Dados para a criação de um perfil: nome completo, data de nascimento e e-mail;
Dados para optimização da navegação: acesso a páginas, palavras-chaves utilizadas nas buscas, recomendações, comentários, interação com outros usuários, perfis seguidos, endereço de IP;
Dados para concretizar transações: dados referentes ao pagamento e transações tais como número de cartão de crédito, além de pagamentos efetuados e históricos de compras, endereço completo para cobranças e entregas dos produtos que venham a ser, eventualmente, entregues;
Newsletter: o e-mail cadastrado pelo usuário ou visitante caso optem por se inscrever será coletado e armazenado até que estes solicitem seu descadastro;
Dados relacionados a contratos: diante de uma formalização de um contrato de compra e venda ou prestação de serviço entre a plataforma e o usuário/visitante, poderão ser coletados e armazenados dados relativos à execução contratual, inclusive as comunicações realizadas entre as partes em questão.
2.2 A presente plataforma não realiza a coleta de dados sensíveis de seus usuários e visitantes.

2.3 Os usuários e visitantes, ainda, ao realizar a criação de seu perfil poderão, caso queiram, informar seu contato, redes sociais, bem como outras informações.

3. FINALIDADE DOS DADOS PESSOAIS RECOLHIDOS DE USUÁRIOS E VISITANTES
3.1 Os dados pessoais dos usuários e visitantes coletados e armazenados por esta plataforma tem por finalidade:

Bem-estar do usuário/visitante: aprimorar o produto e serviço oferecido, buscando facilitar, agilizar e cumprir compromissos estabelecidos entre as partes, melhorar a experiência e fornecer funcionalidades específicas com base nas preferências desses;
Melhorias para a plataforma: compreender o modo como o usuário/visitante utiliza a plataforma, para auxiliar no desenvolvimento de projetos e técnicas para melhor atendê-lo;
Anúncios: apresentar anúncios personalizados com base nos dados fornecidos;
Comercial: os dados serão utilizados para personalizar o conteúdo oferecido e gerar subsídio para a plataforma, visando a melhora da qualidade do funcionamento dos serviços;
Previsão do perfil: tratamento automatizados de dados pessoais para avaliar o uso da plataforma, exclusivo para usuários cadastrados;
Dados de contrato: conferir às partes segurança jurídica, facilitando, assim, a conclusão de negócios realizados entre elas.
3.2 O tratamento de dados pessoais dos usuários e visitantes para finalidades não previstas nesta Política de Privacidade somente ocorrerá mediante comunicação prévia a estes, de modo que os direitos e obrigações previsto no presente documento permanecem aplicáveis.

3.3 O usuário possui direito ao acesso à todas as informações por ele fornecidas à plataforma, bem como à correção, eliminação, portabilidade, limitação do tratamento e oposição.

3.4 O usuário possui o direito de negar, a qualquer momento, que seus dados pessoais sejam utilizados para fins de marketing e recebimento de comunicações comerciais.

3.5 Caso o usuário deseje realizar uma alteração ou remoção em seus dados pessoais cadastrados na plataforma, deverá enviar solicitação formal para o e-mail ‘privacidade@izyncor.org’.

3.5.1 Caso o usuário realize a remoção de seus dados pessoais cadastrados na plataforma, o uso desta e dos serviços por ela prestados para esse usuário poderá ser afetado.

3.6 Caso o usuário não possua 18 (dezoito) anos de idade, este deverá solicitar a permissão de seus responsáveis para ter acesso ao conteúdo da plataforma.

3.6.1 É de total responsabilidade do responsável pelo menor de idade o acesso da plataforma e de todo o seu conteúdo.

4. TEMPO DE ARMAZENAMENTO DE DADOS PESSOAIS
4.1 Os dados pessoais do usuário e do visitante serão armazenados pela plataforma durante o período necessário para a prestação do serviço ou o cumprimento das finalidades previstas no presente documento, conforme prevê o artigo 15, I, da Lei 13.709/18.

4.2 Os dados podem ser removidos ou anonimizados a pedido do usuário, exceto os casos em que a lei oferecer outro tratamento.

4.3 Os dados pessoais dos usuários somente poderão ser conservados após o término de seu tratamento nas hipóteses previstas no artigo 16 da Lei 13.709/18, quais sejam:

Para o cumprimento de obrigação legal ou regulatória pelo controlador;
Para o estudo por órgão de pesquisa, garantida, sempre que possível, a anonimização dos dados pessoais;
Para a transferência a terceiro, desde que respeitados os requisitos de tratamento de dados dispostos nesta Lei; ou
Para o uso exclusivo do controlador, vedado seu acesso por terceiro, e desde que anonimizados os dados.
4.4 Caso o usuário encerre sua conta criada na plataforma, seus dados pessoais serão eliminados do banco de dados desta, em até 30 (trinta) dias após o encerramento desta.

5. SEGURANÇA DOS DADOS PESSOAIS ARMAZENADOS
5.1 A plataforma se compromete a aplicar as medidas técnicas e organizativas aptas a proteger os dados pessoais de acessos não autorizados e de situações de destruição, perda, alteração, comunicação ou difusão dos dados pessoais armazenados.

5.2 Os dados relativos à cartões de crédito são criptografados usando a tecnologia Mercado pago/CNPJ:10.573.521/0001-91, que garante a transmissão dos dados de forma segura e confidencial, de modo que a transmissão dos dados entre servidor e usuário ocorre de maneira cifrada e encriptada.

5.3 A plataforma não se exime de responsabilidade por culpa exclusiva de terceiro, como em caso de ataque de hackers ou crackers.

5.3.1 A presente plataforma se compromete a comunicar o usuário em caso de violação de segurança de seus dados pessoais.

5.4 Os dados pessoais armazenados são tratados com confidencialidade, dentro dos limites legais. Contudo, poderão ser divulgadas informações pessoais caso a plataforma seja obrigada pela lei a fazê-lo ou caso o usuário viole os Termos e Condições de uso dos seus serviços.

6. COMPARTILHAMENTO DE DADOS PESSOAIS
6.1 O compartilhamento de dados do usuário ocorre apenas com os dados referentes a publicações realizadas pelo próprio usuário. Respectivas ações são compartilhadas publicamente com os demais usuários.

6.2 Os dados do perfil do usuário são compartilhados publicamente em sistemas de busca e dentro da plataforma, sendo permitido ao usuário modificar respectiva configuração, para que seu perfil não apareça nos resultados de buscas de tais ferramentas.

6.3 Os dados pessoais poderão ser compartilhados apenas, em caso de realização de compras, com os seguintes terceiros: Acras Tecnologia da Informação LTDA/07.504.505/0001-32.

6.3.1 Os terceiros acima indicados receberam apenas os dados necessários para permitir a realização dos serviços contratados.

6.3.2 Com relação aos prestadores de serviços terceirizados da plataforma, informamos que cada um possui sua politica de privacidade. Assim, é recomendada ao usuário a realização da leitura das suas politicas de privacidade para compreensão de quais informações pessoais serão usadas por eles.

6.3.3 Caso os terceiros indicados possuam instalações em diferentes países, os dados pessoais transferidos poderão se sujeitar às leis de jurisdições nas quais o fornecedor de serviço ou suas instalações estão localizados.

6.3.4 Ao acessar nossos serviços e prover informações, o usuário estará consentindo eventual processamento, transferência e armazenamento desta informação em outros países.

6.4 Ao ser redirecionado para outro aplicativo ou site de terceiros, o usuário não será mais regido por essa Política de Privacidade ou pelos Termos e Condições de Uso dos serviços das plataformas de domínio Izyncor.

6.4.1 Esta plataforma não se responsabiliza pelas práticas de privacidade de outros sites, bem como recomenda a leitura da declaração de privacidade destes.

6.5 Em caso de fusão ou venda da plataforma à terceiro, os dados dos usuários poderão ser transferidos para os novos proprietários para dar continuidade aos serviços oferecidos.

Política de Cookies e Navegação dos domínios e aplicativos Izyncor
7. COOKIES DE NAVEGAÇÃO
7.1 Os cookies referem-se a arquivos de texto enviados pela plataforma ao computador do usuário e visitante e que nele ficam armazenados, com informações relacionadas à navegação no site/aplicativo.

7.1.1 As informações supracitadas são relacionadas aos dados de acesso, tais como local e horário de acesso, e são armazenadas pelo navegador do usuário e visitante para que o servidor da plataforma possa lê-las posteriormente a fim de personalizar os serviços da plataforma.

7.2 O usuário e/ou visitante da presente plataforma manifesta conhecer e aceitar que pode ser utilizado um sistema de coleta de dados de navegação mediante a utilização de cookies.

7.3 O cookie persistente permanece no disco rígido do usuário e/ou visitante depois que o navegador é fechado e será usado por este em visitas subsequentes à plataforma.

7.4 Os cookies persistentes podem ser removidos seguindo as instruções do navegador utilizado pelo usuário e visitante.

7.5 Os cookies de sessão são temporários e desaparecem após o navegador ser fechado.

7.6 É possível redefinir o navegador para recusar todos os cookies, porém alguns recursos da plataforma podem não funcionar corretamente se essa opção for habilitada.

Termos e Condições de Uso - Plataformas e Serviços Izyncor
8. CONSENTIMENTO
Ao utilizar os serviços e fornecer as informações pessoais na plataforma, o usuário está consentindo com a presente Política de Privacidade.

8.1 Ao cadastrar-se, o usuário manifesta conhecer e poder exercitar seus direitos de cancelar seu cadastro, acessar e atualizar seus dados pessoais, bem como garante a veracidade das informações por ele disponibilizadas.

8.2 O usuário tem direito de retirar seu consentimento a qualquer momento, devendo, para tanto, entrar em contato com a plataforma através do seguinte e-mail: privacidade@izyncor.org.

9. ALTERAÇÕES DA PRESENTE POLÍTICA DE PRIVACIDADE
A plataforma reserva o direito de modificar a presente Política de Privacidade a qualquer momento. Desta forma, é recomendado ao usuário e/ou visitante que a revise com frequência.

9.1 As alterações e esclarecimentos irão surtir efeito imediatamente após sua publicação na plataforma.

9.1.1 Os usuários serão notificados em caso de alterações na presente Política de Privacidade.

9.1.2 Ao utilizar o serviço ou fornecer informações pessoais após eventual alteração na presente Política de Privacidade, o usuário e/ou visitante demonstram sua concordância com as novas normas.

10. JURISDIÇÃO PARA RESOLUÇÃO DE CONFLITOS
10.1 Para a solução de controvérsias decorrentes do presente instrumento, será aplicado integralmente o Direito Brasileiro.

10.2 Eventuais litígios deverão ser apresentados no foro da comarca em que se encontra a sede da empresa, qual seja, Mariana, MG.

 

A presente Política de Privacidade passa a ter validade a partir de sua publicação, com tempo indefinido de vigência.'''),
            // const SizedBox(height: 20),
            Visibility(
              visible: aceito == false,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBB2649),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13))),
                      onPressed: () {
                        aceitarTermos();
                      },
                      child: const Text(
                        "Aceitar os termos",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      )),
                ),
              ),
            ),
            if (Platform.isIOS)
            const SizedBox(height: 30)
          ],
        ),
      ),
    );
  }
}

class PoliticasTexto extends StatelessWidget {
  const PoliticasTexto({super.key, required this.corpoTexto});

  final String corpoTexto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Text(
            corpoTexto,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
