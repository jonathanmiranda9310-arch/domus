import 'package:domus/core/utils/calculos.dart';
import 'package:domus/core/utils/datas.dart';
import 'package:domus/core/utils/formatadores.dart';
import 'package:domus/core/utils/senha_hash.dart';
import 'package:domus/core/utils/texto.dart';
import 'package:domus/core/utils/validadores.dart';
import 'package:domus/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  group('Datas e cálculos', () {
    test('noites = checkOut − checkIn', () {
      expect(Datas.calcularNoites(DateTime(2026, 12, 1), DateTime(2026, 12, 4)),
          3);
      expect(Datas.calcularNoites(DateTime(2026, 12, 4), DateTime(2026, 12, 4)),
          0);
      expect(Datas.calcularNoites(DateTime(2026, 12, 5), DateTime(2026, 12, 4)),
          0);
      // Ignora a hora do dia.
      expect(
        Datas.calcularNoites(
            DateTime(2026, 12, 1, 23, 59), DateTime(2026, 12, 2, 0, 1)),
        1,
      );
    });

    test('valorTotal = valorDiaria × noites', () {
      expect(
        Calculos.valorTotal(
          valorDiaria: 220,
          checkIn: DateTime(2026, 12, 1),
          checkOut: DateTime(2026, 12, 4),
        ),
        660,
      );
    });

    test('ISO ida e volta', () {
      final data = DateTime(2026, 3, 7);
      expect(Datas.paraIso(data), '2026-03-07');
      expect(Datas.deIso('2026-03-07'), data);
    });
  });

  group('Formatadores', () {
    test('moeda e nota em pt_BR', () {
      expect(Formatadores.moeda(1234.5), 'R\$ 1.234,50');
      expect(Formatadores.moedaCurta(220), 'R\$ 220');
      expect(Formatadores.nota(4.7), '4,7');
      expect(Formatadores.telefone('83999998888'), '(83) 99999-8888');
      expect(Formatadores.noites(1), '1 noite');
    });
  });

  group('Texto', () {
    test('normalizar remove acentos', () {
      expect(Texto.normalizar('  João Pessoa '), 'joao pessoa');
      expect(Texto.iniciais('Maria da Silva'), 'MS');
    });
  });

  group('SenhaHash', () {
    test('hash não é a senha, depende do salt e é verificável', () {
      final salt1 = SenhaHash.gerarSalt();
      final salt2 = SenhaHash.gerarSalt();
      final h1 = SenhaHash.gerarHash('segredo123', salt1);
      final h2 = SenhaHash.gerarHash('segredo123', salt2);

      expect(h1, isNot(contains('segredo123')));
      expect(h1, isNot(h2)); // salts diferentes → hashes diferentes
      expect(SenhaHash.verificar('segredo123', salt1, h1), isTrue);
      expect(SenhaHash.verificar('errada', salt1, h1), isFalse);
    });
  });

  group('Validadores', () {
    test('email e senha', () {
      expect(Validadores.email('a@b.com'), isNull);
      expect(Validadores.email('invalido'), isNotNull);
      expect(Validadores.novaSenha('12345'), isNotNull);
      expect(Validadores.novaSenha('123456'), isNull);
      expect(Validadores.telefoneOpcional(''), isNull);
      expect(Validadores.telefoneOpcional('(83) 9999'), isNotNull);
    });
  });

  group('Reserva.situacao', () {
    Reserva reserva(DateTime inicio, DateTime fim,
            [StatusReserva status = StatusReserva.ativa]) =>
        Reserva(
          usuarioId: 1,
          acomodacaoId: 1,
          checkIn: inicio,
          checkOut: fim,
          numeroHospedes: 1,
          valorDiaria: 100,
          valorTotal: 100,
          status: status,
          criadoEm: DateTime(2026),
        );
    final hoje = DateTime(2026, 11, 23);

    test('próxima, em andamento, concluída e cancelada', () {
      expect(
          reserva(DateTime(2026, 11, 23), DateTime(2026, 11, 25))
              .situacao(hoje),
          SituacaoReserva.proxima);
      expect(
          reserva(DateTime(2026, 11, 20), DateTime(2026, 11, 25))
              .situacao(hoje),
          SituacaoReserva.emAndamento);
      expect(
          reserva(DateTime(2026, 11, 10), DateTime(2026, 11, 12))
              .situacao(hoje),
          SituacaoReserva.concluida);
      expect(
          reserva(DateTime(2026, 12, 1), DateTime(2026, 12, 3),
                  StatusReserva.cancelada)
              .situacao(hoje),
          SituacaoReserva.cancelada);
    });
  });
}
