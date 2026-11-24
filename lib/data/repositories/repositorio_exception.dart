/// Erros de regra de negócio lançados pelos repositórios.
///
/// Todos têm uma [mensagem] em português pronta para exibir na tela:
/// ```dart
/// try {
///   await Injecao.reservas.criar(...);
/// } on RepositorioException catch (e) {
///   ScaffoldMessenger.of(context)
///       .showSnackBar(SnackBar(content: Text(e.mensagem)));
/// }
/// ```
sealed class RepositorioException implements Exception {
  const RepositorioException(this.mensagem);
  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

class EmailJaCadastradoException extends RepositorioException {
  const EmailJaCadastradoException()
      : super('Já existe uma conta com este e-mail.');
}

class CredenciaisInvalidasException extends RepositorioException {
  const CredenciaisInvalidasException() : super('E-mail ou senha incorretos.');
}

class SenhaAtualIncorretaException extends RepositorioException {
  const SenhaAtualIncorretaException() : super('A senha atual está incorreta.');
}

class UsuarioNaoEncontradoException extends RepositorioException {
  const UsuarioNaoEncontradoException() : super('Usuário não encontrado.');
}

class ReservaInvalidaException extends RepositorioException {
  const ReservaInvalidaException(super.mensagem);
}
