# Domus

**Sinta-se em casa, onde estiver.**

App Flutter para buscar, comparar e reservar hotéis, pousadas e quartos.
Projeto da disciplina de Desenvolvimento Mobile — UNIPÊ.

## Rodar

```bash
flutter pub get
flutter run          # precisa de um emulador Android/iOS ou celular conectado
flutter test         # testes de regras, repositórios e telas
```

Conta de demonstração (criada na 1ª execução): `demo@domus.app` / `domus123`.
Em modo debug, a tela de Login tem um botão para preenchê-la.

## Estrutura

```
lib/
  main.dart                 MaterialApp + tema + rotas
  injecao.dart              acesso único a repositórios e sessão
  rotas.dart                rotas nomeadas
  core/theme/               AppColors, AppTheme, AppSpacing, AppRadius, AppTextStyles
  core/utils/               datas, cálculos, formatadores, validadores, hash de senha
  core/app_info.dart        nome e slogan do app
  core/widgets/             DomusLogo/DomusMarca, FotoRede, FundoDecorado
  data/models/              Usuario, Acomodacao, Reserva, Favorito, FiltroBusca (+ enums)
  data/database/            AppDatabase (sqflite) + SeedDatabase (JSON de assets/)
  data/repositories/        Usuario, Acomodacao, Reserva, Favorito, Sessao
  features/                 splash, auth, perfil, shell (bottom nav),
                            explorar, detalhes, favoritos,
                            minhas_reservas (provisória)
assets/data/acomodacoes.json   20 acomodações de exemplo
assets/images/                 logo.png (completa), logo_icone.png (símbolo),
                               logo_icone_branco.png (para fundo índigo)
```

## Guia rápido para quem faz Home, Detalhes, Reserva e Favoritos

Tudo é acessado por `Injecao` (sem SQL nas telas):

```dart
import 'package:domus/injecao.dart';
import 'package:domus/data/models/models.dart';

final usuarioId = Injecao.sessao.usuarioId;

// Explorar
final lista = await Injecao.acomodacoes.buscar(FiltroBusca(
  destino: 'joao pessoa',            // ignora acentos e maiúsculas
  categoria: CategoriaAcomodacao.pousada,
  faixaPreco: FaixaPreco.ate150,
  notaMinima: 4.5,
  ordenacao: OrdenacaoBusca.menorPreco,
));
final destinos = await Injecao.acomodacoes.listarDestinos();

// Card / Detalhes
acomodacao.fotoPrincipal;  acomodacao.localizacao;  acomodacao.notaMedia;
acomodacao.comodidades;    // cada uma tem .rotulo e .icone
acomodacao.calcularValorTotal(checkIn, checkOut);  // diária × noites
Formatadores.moeda(valor); Formatadores.nota(4.7); Formatadores.periodo(a, b);

// Reserva
try {
  await Injecao.reservas.criar(
    usuarioId: usuarioId, acomodacao: acomodacao,
    checkIn: checkIn, checkOut: checkOut, numeroHospedes: 2,
  );
} on RepositorioException catch (e) {
  // e.mensagem já vem em português para mostrar na tela
}

// Minhas Reservas
await Injecao.reservas.listarProximas(usuarioId);    // List<ReservaComAcomodacao>
await Injecao.reservas.listarConcluidas(usuarioId);  // inclui canceladas
await Injecao.reservas.cancelar(reservaId);
item.reserva.situacao();      // .rotulo, .cor, .corFundo para o badge
item.reserva.podeCancelar();

// Favoritos
await Injecao.favoritos.alternar(usuarioId, acomodacaoId);  // retorna novo estado
await Injecao.favoritos.listarIds(usuarioId);               // Set<int> para os corações
await Injecao.favoritos.listarAcomodacoes(usuarioId);
```

### Telas já prontas como base visual

- **Explorar**: cabeçalho com slogan, busca por destino (ignora acentos),
  datas, hóspedes, chips de categoria, filtros de preço/nota e cards.
- **Detalhes**: galeria, comodidades, endereço, escolha de datas com total
  automático e barra fixa "Reservar agora".
  O método `_reservar()` em `features/detalhes/detalhes_page.dart` é o
  ponto para abrir a **Confirmação de Reserva**.
- **Favoritos**: usa `Injecao.favoritosCtrl`, que mantém o coração
  sincronizado entre todas as telas.
- Card reutilizável: `features/explorar/widgets/acomodacao_card.dart`.

Para adicionar acomodações de teste, basta incluir no JSON com um `id`
novo: na próxima abertura do app elas entram no banco sem apagar
reservas nem favoritos.

Ao substituir uma tela provisória, mantenha `PerfilAvatarButton()` nas
`actions` da AppBar: é por ele que o usuário abre o Perfil.

## Regras de negócio

- `valorTotal = valorDiaria × noites` (noites = checkOut − checkIn).
- **Próximas**: reservas ativas cujo check-out ainda não passou (inclui
  as que começam hoje ou depois e as "em andamento").
- **Concluídas**: check-out já passou, mais as canceladas.
- Só é possível cancelar reservas que ainda não começaram.
- Senhas: PBKDF2-HMAC-SHA256 com salt aleatório por usuário; o banco
  guarda apenas `senha_hash` e `senha_salt`.
