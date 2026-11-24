import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatadores.dart';
import '../../../core/utils/telefone_input_formatter.dart';
import '../../../core/utils/texto.dart';
import '../../../core/utils/validadores.dart';
import '../../../data/models/usuario.dart';
import '../../../data/repositories/repositorio_exception.dart';
import '../../../injecao.dart';

/// Formulário de edição de nome, e-mail e telefone.
///
/// O botão "Salvar" só fica ativo quando algo foi alterado.
class DadosPessoaisCard extends StatefulWidget {
  const DadosPessoaisCard({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<DadosPessoaisCard> createState() => _DadosPessoaisCardState();
}

class _DadosPessoaisCardState extends State<DadosPessoaisCard> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeCtrl = TextEditingController(text: widget.usuario.nome);
  late final _emailCtrl = TextEditingController(text: widget.usuario.email);
  late final _telefoneCtrl = TextEditingController(
      text: Formatadores.telefone(widget.usuario.telefone));

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Atualiza o estado do botão a cada digitação.
    for (final c in [_nomeCtrl, _emailCtrl, _telefoneCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  bool get _alterado {
    final u = widget.usuario;
    return _nomeCtrl.text.trim() != u.nome ||
        _emailCtrl.text.trim().toLowerCase() != u.email ||
        Texto.somenteDigitos(_telefoneCtrl.text) != (u.telefone ?? '');
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _salvando = true);
    try {
      await Injecao.sessao.atualizarPerfil(
        nome: _nomeCtrl.text,
        email: _emailCtrl.text,
        telefone: _telefoneCtrl.text,
      );
      mensageiro.showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso.')),
      );
    } on RepositorioException catch (e) {
      mensageiro.showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const espaco = SizedBox(height: AppSpacing.md);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validadores.nome,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              espaco,
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: Validadores.email,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              espaco,
              TextFormField(
                controller: _telefoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [TelefoneInputFormatter()],
                validator: Validadores.telefoneOpcional,
                decoration: const InputDecoration(
                  labelText: 'Telefone (opcional)',
                  hintText: '(83) 99999-9999',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: (_alterado && !_salvando) ? _salvar : null,
                child: _salvando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
