import 'package:book_space/core/usuario.dart';

class Autenticador {
  static final Usuario _mariana = Usuario('Mariana', 'mariana@email.com');
  static Usuario? _logado; // null = ninguém logado

  static Future<Usuario?> login() async {
    _logado = _mariana;
    return _logado;
  }

  static Future<Usuario?> recuperarUsuario() async {
    return _logado;
  }

  static Future<void> logout() async {
    _logado = null;
  }
}
