import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/calculos.dart';
import '../../core/utils/datas.dart';
import 'acomodacao.dart';

/// Status salvo no banco.
enum StatusReserva { ativa, cancelada }

/// Situação calculada a partir do status + datas (o que aparece na tela).
enum SituacaoReserva {
  /// Ativa e com check-in a partir de hoje → aba "Próximas".
  proxima('Confirmada', AppColors.secundaria, AppColors.secundariaClara),

  /// Ativa, check-in já passou mas check-out não → aba "Próximas".
  emAndamento('Em andamento', AppColors.primaria, AppColors.primariaClara),

  /// Ativa e check-out já passou → aba "Concluídas".
  concluida('Concluída', AppColors.textoSecundario, Color(0xFFF1F5F9)),

  /// Cancelada pelo usuário → aba "Concluídas" (com badge vermelho).
  cancelada('Cancelada', AppColors.erro, AppColors.erroClaro);

  const SituacaoReserva(this.rotulo, this.cor, this.corFundo);

  /// Texto do badge de status.
  final String rotulo;
  final Color cor;
  final Color corFundo;

  /// `true` se a reserva aparece na aba "Próximas".
  bool get ehProxima => this == proxima || this == emAndamento;
}

/// Reserva feita por um usuário em uma acomodação.
class Reserva {
  const Reserva({
    this.id,
    required this.usuarioId,
    required this.acomodacaoId,
    required this.checkIn,
    required this.checkOut,
    required this.numeroHospedes,
    required this.valorDiaria,
    required this.valorTotal,
    this.status = StatusReserva.ativa,
    required this.criadoEm,
  });

  /// Cria uma nova reserva já calculando o valor total.
  ///
  /// O valor da diária é "congelado" na reserva: se o preço da
  /// acomodação mudar depois, a reserva mantém o valor contratado.
  factory Reserva.nova({
    required int usuarioId,
    required Acomodacao acomodacao,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numeroHospedes,
  }) {
    return Reserva(
      usuarioId: usuarioId,
      acomodacaoId: acomodacao.id!,
      checkIn: Datas.somenteData(checkIn),
      checkOut: Datas.somenteData(checkOut),
      numeroHospedes: numeroHospedes,
      valorDiaria: acomodacao.valorDiaria,
      valorTotal: acomodacao.calcularValorTotal(checkIn, checkOut),
      criadoEm: DateTime.now(),
    );
  }

  final int? id;
  final int usuarioId;
  final int acomodacaoId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int numeroHospedes;

  /// Diária no momento da reserva.
  final double valorDiaria;

  /// valorDiaria × noites.
  final double valorTotal;
  final StatusReserva status;
  final DateTime criadoEm;

  /// checkOut − checkIn, em noites.
  int get noites => Datas.calcularNoites(checkIn, checkOut);

  /// Situação atual. [hoje] pode ser passado para testes.
  SituacaoReserva situacao([DateTime? hoje]) {
    final referencia = Datas.somenteData(hoje ?? DateTime.now());
    if (status == StatusReserva.cancelada) return SituacaoReserva.cancelada;
    if (checkOut.isBefore(referencia)) return SituacaoReserva.concluida;
    if (!checkIn.isBefore(referencia)) return SituacaoReserva.proxima;
    return SituacaoReserva.emAndamento;
  }

  /// Só é possível cancelar reservas ativas que ainda não começaram.
  bool podeCancelar([DateTime? hoje]) =>
      situacao(hoje) == SituacaoReserva.proxima;

  // ---------------------------------------------------------------------------
  // Conversão banco <-> objeto
  // ---------------------------------------------------------------------------

  factory Reserva.fromMap(Map<String, Object?> map) {
    return Reserva(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      acomodacaoId: map['acomodacao_id'] as int,
      checkIn: Datas.deIso(map['check_in'] as String),
      checkOut: Datas.deIso(map['check_out'] as String),
      numeroHospedes: map['numero_hospedes'] as int,
      valorDiaria: (map['valor_diaria'] as num).toDouble(),
      valorTotal: (map['valor_total'] as num).toDouble(),
      status: StatusReserva.values.byName(map['status'] as String),
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'acomodacao_id': acomodacaoId,
      'check_in': Datas.paraIso(checkIn),
      'check_out': Datas.paraIso(checkOut),
      'numero_hospedes': numeroHospedes,
      'valor_diaria': valorDiaria,
      'valor_total': Calculos.arredondar(valorTotal),
      'status': status.name,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  Reserva copyWith({int? id, StatusReserva? status}) {
    return Reserva(
      id: id ?? this.id,
      usuarioId: usuarioId,
      acomodacaoId: acomodacaoId,
      checkIn: checkIn,
      checkOut: checkOut,
      numeroHospedes: numeroHospedes,
      valorDiaria: valorDiaria,
      valorTotal: valorTotal,
      status: status ?? this.status,
      criadoEm: criadoEm,
    );
  }

  @override
  String toString() =>
      'Reserva(id: $id, acomodacao: $acomodacaoId, $checkIn → $checkOut, $status)';
}

/// Reserva junto com a acomodação: é o que as listas de
/// "Minhas Reservas" e o histórico do Perfil precisam exibir
/// (foto, nome, cidade, datas, status).
class ReservaComAcomodacao {
  const ReservaComAcomodacao({required this.reserva, required this.acomodacao});

  final Reserva reserva;
  final Acomodacao acomodacao;
}
