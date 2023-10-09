import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editora_izyncor_app/interior_usuario/tabbar.dart';
import 'package:editora_izyncor_app/recepcao/cadastros_outros/mais_dados.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        // O usuário cancelou a seleção de conta.
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        String? nome = user.displayName;
        String? sobrenome = "";

        if (nome != null && nome.contains(" ")) {
          List<String> partesNome = nome.split(" ");
          nome = partesNome[0];
          sobrenome = partesNome.sublist(1).join(" ");
        }

        // Verifique se o documento já existe no Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection("usuarios").doc(user.uid).get();

        if (userDoc.exists) {
          // O documento já existe, navegue para a tela home_principal
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const home_principal(),
            ),
          );
        } else {
          // O documento não existe, adicione os dados ao Firestore e navegue para a tela mais_dados_google
          await _firestore.collection("usuarios").doc(user.uid).set({
            'login': 'Google',
            'nome': nome,
            'sobrenome': sobrenome,
            'email': user.email,
            "seguidores": 0,
            "seguindo": 0,
            "postagens": 0,
            "cpf": '',
            "Cadastro": 'Leitor(a)',
            "biografia": 'Boas vindas a Izyncor!',
            "urlImagem":
                'https://firebasestorage.googleapis.com/v0/b/izyncor-app-949df.appspot.com/o/perfil%2F130GNy50ahX6G9keTyhHsP3vQEu2.jpg?alt=media&token=9230ad6c-614d-4adf-bf00-257d1a45d725'
          });

          // Navegue para a tela mais_dados_google
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const mais_dados_google(),
            ),
          );
        }

        return user;
      }
    } catch (e) {
      print("Erro durante o login com o Google: $e");
      return null;
    }
    return null;
  }
}
