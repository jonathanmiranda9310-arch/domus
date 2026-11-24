import 'package:flutter/services.dart';

import 'formatadores.dart';
import 'texto.dart';

/// Máscara de telefone enquanto o usuário digita: (83) 99999-8888.
class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = Texto.somenteDigitos(newValue.text);
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final formatado = _formatarParcial(digitos);
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }

  String _formatarParcial(String d) {
    if (d.length >= 10) return Formatadores.telefone(d);
    if (d.length > 6) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
    }
    if (d.length > 2) return '(${d.substring(0, 2)}) ${d.substring(2)}';
    if (d.isNotEmpty) return '($d';
    return '';
  }
}
