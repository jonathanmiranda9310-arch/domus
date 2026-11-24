import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Hash de senhas com PBKDF2-HMAC-SHA256 + salt aleatório.
///
/// Por que não só `sha256(senha)`?
/// - Sem salt, duas pessoas com a mesma senha teriam o mesmo hash, e
///   tabelas prontas ("rainbow tables") quebrariam senhas comuns.
/// - SHA-256 puro é rápido demais; o PBKDF2 repete o HMAC milhares de
///   vezes, tornando ataques de força bruta muito mais lentos.
///
/// No banco ficam apenas `senha_hash` e `senha_salt` — nunca a senha.
abstract final class SenhaHash {
  /// Quantidade de repetições do HMAC.
  static const int iteracoes = 10000;

  /// Gera um salt aleatório criptograficamente seguro (Base64).
  static String gerarSalt([int bytes = 16]) {
    final random = Random.secure();
    final valores = List<int>.generate(bytes, (_) => random.nextInt(256));
    return base64Url.encode(valores);
  }

  /// Calcula o hash da [senha] usando o [salt] informado.
  static String gerarHash(String senha, String salt) {
    final hmac = Hmac(sha256, utf8.encode(senha));

    // PBKDF2 (RFC 8018) com um único bloco de 32 bytes:
    // U1 = HMAC(senha, salt || 0x00000001), Ui = HMAC(senha, Ui-1)
    // resultado = U1 xor U2 xor ... xor Un
    var u = hmac.convert([...utf8.encode(salt), 0, 0, 0, 1]).bytes;
    final resultado = Uint8List.fromList(u);
    for (var i = 1; i < iteracoes; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < resultado.length; j++) {
        resultado[j] ^= u[j];
      }
    }
    return base64.encode(resultado);
  }

  /// Confere se a [senha] digitada corresponde ao [hashSalvo].
  static bool verificar(String senha, String salt, String hashSalvo) {
    return _comparacaoSegura(gerarHash(senha, salt), hashSalvo);
  }

  /// Compara em tempo constante (evita ataques de temporização).
  static bool _comparacaoSegura(String a, String b) {
    if (a.length != b.length) return false;
    var diferenca = 0;
    for (var i = 0; i < a.length; i++) {
      diferenca |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diferenca == 0;
  }
}
