import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validadores.dart';
import '../../../data/repositories/repositorio_exception.dart';
import '../../../injecao.dart';
import '../../auth/widgets/campo_senha.dart';
import '../../auth/widgets/mensagem_erro.dart';

/// Bottom sheet para trocar a senha.
///
/// Retorna `true` se a senha foi alterada.
class AlterarSenhaSheet extends StatefulWidget {
  const AlterarSenhaSheet({super.key});

  static Future<bool?> abrir(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // sobe junto com o teclado
      showDragHandle: true,
      builder: (_) => const AlterarSenhaSheet(),
    );
  }

  @override
  State<AlterarSenhaSheet> createState() => _AlterarSenhaSheetState();
}

class _AlterarSenhaSheetState extends State<AlterarSenhaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _atualCtrl = TextEditingController();
  final _novaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _atualCtrl.dispose();
    _novaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _erro = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await Injecao.sessao.alterarSenha(
        senhaAtual: _atualCtrl.text,
        novaSenha: _novaCtrl.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on RepositorioException catch (e) {
      setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tecladoAltura = MediaQuery.viewInsetsOf(context).bottom;
    const espaco = SizedBox(height: AppSpacing.md);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + tecladoAltura,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Alterar senha',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            CampoSenha(
              controller: _atualCtrl,
              rotulo: 'Senha atual',
              textInputAction: TextInputAction.next,
              validator: Validadores.senhaObrigatoria,
            ),
            espaco,
            CampoSenha(
              controller: _novaCtrl,
              rotulo: 'Nova senha',
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validadores.novaSenha,
            ),
            espaco,
            CampoSenha(
              controller: _confirmarCtrl,
              rotulo: 'Confirmar nova senha',
              autofillHints: const [AutofillHints.newPassword],
              validator: Validadores.confirmarSenha(() => _novaCtrl.text),
              onFieldSubmitted: (_) => _salvar(),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_erro != null) ...[
              MensagemErro(_erro!),
              espaco,
            ],
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Salvar nova senha'),
            ),
          ],
        ),
      ),
    );
  }
}
