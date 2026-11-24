import 'texto.dart';

/// Validadores para `TextFormField(validator: ...)`.
///
/// Retornam `null` quando o valor é válido ou a mensagem de erro.
abstract final class Validadores {
  static final _regexEmail = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static const int tamanhoMinimoSenha = 6;

  static String? nome(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome';
    if (v.length < 3) return 'Nome muito curto';
    return null;
  }

  static String? email(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu e-mail';
    if (!_regexEmail.hasMatch(v)) return 'E-mail inválido';
    return null;
  }

  /// Usado no login: só verifica se foi preenchida.
  static String? senhaObrigatoria(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    return null;
  }

  /// Usado no cadastro e na troca de senha.
  static String? novaSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Crie uma senha';
    if (valor.length < tamanhoMinimoSenha) {
      return 'A senha deve ter ao menos $tamanhoMinimoSenha caracteres';
    }
    return null;
  }

  static String? Function(String?) confirmarSenha(String Function() senha) {
    return (valor) {
      if (valor == null || valor.isEmpty) return 'Confirme a senha';
      if (valor != senha()) return 'As senhas não coincidem';
      return null;
    };
  }

  /// Telefone é opcional; se preenchido, deve ter DDD + número.
  static String? telefoneOpcional(String? valor) {
    final digitos = Texto.somenteDigitos(valor ?? '');
    if (digitos.isEmpty) return null;
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Telefone inválido (inclua o DDD)';
    }
    return null;
  }
}
