import 'package:flutter/material.dart';

/// Paleta oficial do Domus.
///
/// Use sempre estas constantes (ou o `Theme.of(context)`) em vez de cores
/// soltas no código, para manter a identidade visual consistente entre
/// as telas de todos os integrantes do grupo.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Cores principais
  // ---------------------------------------------------------------------------

  /// Índigo — botões, ícones ativos e links.
  static const Color primaria = Color(0xFF4F46E5);

  /// Versão mais clara da primária — fundos de destaque, chips selecionados.
  static const Color primariaClara = Color(0xFFE0E7FF);

  /// Versão mais escura da primária — estado pressionado.
  static const Color primariaEscura = Color(0xFF4338CA);

  /// Verde Menta — disponibilidade, confirmação e custo-benefício.
  static const Color secundaria = Color(0xFF10B981);

  /// Versão clara da secundária — fundo de badges "Confirmada", "Disponível".
  static const Color secundariaClara = Color(0xFFD1FAE5);

  // ---------------------------------------------------------------------------
  // Superfícies
  // ---------------------------------------------------------------------------

  /// Fundo de todas as telas.
  static const Color fundo = Color(0xFFF8FAFC);

  /// Fundo dos cards.
  static const Color card = Color(0xFFFFFFFF);

  /// Bordas e divisórias suaves.
  static const Color borda = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // Texto
  // ---------------------------------------------------------------------------

  /// Grafite — texto principal.
  static const Color texto = Color(0xFF1E293B);

  /// Texto secundário (endereços, legendas, datas).
  static const Color textoSecundario = Color(0xFF64748B);

  /// Texto desabilitado / placeholders.
  static const Color textoDesabilitado = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Feedback
  // ---------------------------------------------------------------------------

  /// Erros de formulário e reservas canceladas.
  static const Color erro = Color(0xFFEF4444);

  /// Fundo claro para badges de erro / cancelada.
  static const Color erroClaro = Color(0xFFFEE2E2);

  /// Estrela da avaliação.
  static const Color estrela = Color(0xFFF59E0B);
}
