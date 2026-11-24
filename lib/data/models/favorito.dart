/// Acomodação salva por um usuário.
///
/// Na tabela `favoritos` a chave primária é o par
/// (usuario_id, acomodacao_id), então não existe favorito duplicado.
class Favorito {
  const Favorito({
    required this.usuarioId,
    required this.acomodacaoId,
    required this.criadoEm,
  });

  final int usuarioId;
  final int acomodacaoId;
  final DateTime criadoEm;

  factory Favorito.fromMap(Map<String, Object?> map) {
    return Favorito(
      usuarioId: map['usuario_id'] as int,
      acomodacaoId: map['acomodacao_id'] as int,
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Map<String, Object?> toMap() => {
        'usuario_id': usuarioId,
        'acomodacao_id': acomodacaoId,
        'criado_em': criadoEm.toIso8601String(),
      };
}
