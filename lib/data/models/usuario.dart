import '../../core/utils/texto.dart';

/// Usuário do aplicativo.
///
/// Importante: este modelo NÃO carrega a senha nem o hash dela.
/// As colunas `senha_hash` e `senha_salt` existem só no banco e são
/// manipuladas exclusivamente pelo `UsuarioRepository`. Assim, nenhuma
/// tela consegue ler ou exibir dados de senha por engano.
class Usuario {
  const Usuario({
    this.id,
    required this.nome,
    required this.email,
    this.telefone,
    required this.criadoEm,
  });

  /// `null` enquanto o usuário ainda não foi salvo no banco.
  final int? id;
  final String nome;

  /// Sempre em minúsculas e sem espaços (normalizado no repositório).
  final String email;

  /// Apenas dígitos, ex.: "83999998888". Opcional.
  final String? telefone;
  final DateTime criadoEm;

  /// "Maria da Silva" → "Maria"
  String get primeiroNome => nome.trim().split(RegExp(r'\s+')).first;

  /// "Maria da Silva" → "MS" (para o avatar)
  String get iniciais => Texto.iniciais(nome);

  // ---------------------------------------------------------------------------
  // Conversão banco <-> objeto
  // ---------------------------------------------------------------------------

  factory Usuario.fromMap(Map<String, Object?> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String?,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  /// Mapa com os dados públicos (sem colunas de senha).
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    bool limparTelefone = false,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: limparTelefone ? null : (telefone ?? this.telefone),
      criadoEm: criadoEm,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Usuario &&
      other.id == id &&
      other.nome == nome &&
      other.email == email &&
      other.telefone == telefone;

  @override
  int get hashCode => Object.hash(id, nome, email, telefone);

  @override
  String toString() => 'Usuario(id: $id, nome: $nome, email: $email)';
}
