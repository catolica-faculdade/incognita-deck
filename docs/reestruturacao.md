# Reestruturação para revisão da equipe

> Histórico da etapa anterior. A branch `feat/new-content` mudou baralho, efeitos, mapa e progressão. Para o comportamento atual, consulte [new-content.md](new-content.md).

## Escopo e ponto de partida

Preparada em 03/11/2026 sobre o commit `23e44ef`, branch local `main`, inicialmente sem alterações. Esta entrega consiste em alterações locais para revisão, sem commit ou envio ao remoto.

Os dois GDDs fornecidos têm 47 páginas e o mesmo texto extraído. Serviram de referência para compreender o projeto; funcionalidades previstas neles não foram tratadas como autorização para acrescentar conteúdo nesta etapa.

Os caminhos das cenas existentes foram mantidos para preservar a composição feita no editor. A organização mudou principalmente por responsabilidade: regras em `core`, apresentação nas cenas e um único coordenador de combate. Não é necessário reaprender a localização dos cenários e assets.

## Quem controla cada parte

| Parte | Responsabilidade | Não deve controlar |
| --- | --- | --- |
| `settings/game_manager.gd` | HP entre fases, nível, nova partida, vitória e troca de cena | Turno individual ou matemática das cartas |
| `world/battle_system/battle_system.gd` | Estados SETUP → PLAYER → RESOLVING → ENEMIES → PLAYER/FINISHED; alvos; sequência assíncrona; resultado único | Arraste ou débito de energia |
| `core/combat/card_selection.gd` | Aceitar/remover cartas por identidade, energia, bloqueio e reembolso | Nós visuais ou mudança de cena |
| `core/combat/trajectory_formula.gd` | Composição e amostragem da fórmula | Busca por jogador/inimigos na árvore |
| `core/combat/trajectory_targeting.gd` | Distância entre alvo e segmentos da trajetória | Animação ou dano |
| `interface/interface.gd` | Mão, cartas selecionadas, energia visual; emite intenções por sinais | Execução do turno ou resultado da batalha |
| `card/card.gd` | Apresentação e eventos de arraste | Decidir se há energia ou alterar seu próprio estado de seleção antes da validação |
| `world/player/trajectory.gd` | Mostrar os pontos calculados na Line2D | Acumular regras de cartas |
| `world/enemy/enemy_combat/combat_enemy.gd` | Vida, escudo, cura, ataque, veneno, animações comuns | Escolher a estratégia particular de cada inimigo |
| Scripts de cubo/fantasma/calculadora/slime/professor | Valores e escolha de ação; teleporte do professor | Duplicar a implementação de dano e suporte |

A interface recebe comandos do coordenador e devolve `end_turn_requested`, `selection_changed` e `card_hover_changed`. Ela não procura o BattleSystem nem o jogador globalmente. O coordenador recebe a trajetória diretamente do jogador e usa as referências conhecidas da interface. O grupo `Player` permanece como contrato dos ataques dos inimigos; o grupo `enemies` atende ao suporte coletivo.

## Correções incluídas

- Uma única autoridade de turno; removidos os flags globais concorrentes e as chamadas paralelas de fim de combate.
- Entrada bloqueada antes do primeiro `await`; encerrar turno repetidamente não dispara rodadas extras. Selecionar, remover e limpar também respeitam o bloqueio.
- Vitória e derrota passam pelo mesmo ponto de decisão; progresso não é aplicado duas vezes. Veneno letal encerra a batalha antes de um inimigo agir.
- Cada ação inimiga aguarda sua animação e seu efeito. Ataques aguardam a reação do jogador antes de passar ao próximo inimigo.
- Contrato uniforme `heal(amount)`: todos os inimigos aceitam cura externa, respeitando a quantidade recebida. Antes, cubo e fantasma tinham assinatura incompatível, e outros ignoravam o argumento.
- Escudo atualiza o HUD ao ser consumido/resetado; HP não fica negativo. Dano, cura e suporte usam a base comum.
- A seleção debita/reembolsa uma única vez; remover uma identidade inexistente não gera energia.
- Arraste acompanha movimento e liberação fora da carta. Usa as coordenadas do evento, e os filhos decorativos não interceptam o mouse. A zona de descarte é uma referência da própria interface.
- Hover conectado à raiz correta da carta; não interrompe a animação de ação do jogador.
- Alvos são destacados e recalculados durante o planejamento para acompanhar a movimentação dos inimigos. A seleção é congelada no momento da confirmação.
- O HUD mostra a quantidade de veneno. O painel de status fica no canto superior direito para liberar a informação de vida do fantasma; o texto da fórmula tem largura limitada.
- Texto da trajetória inclui a onda e mostra o destino das retas, evitando exibir uma reta diagonal como se fosse horizontal.
- Novas partidas e retorno ao menu reiniciam o estado pelo mesmo fluxo; referências de cenário são limpas.
- O evento de mapa que anteriormente não fazia nada em 20% dos sorteios agora avança sem recompensa. Este comportamento explícito é provisório até a equipe definir esse evento.
- A pausa não cobre telas de vitória/derrota.
- Entrada principal e autoloads usam caminhos explícitos, sem depender exclusivamente do cache local de UIDs.
- Removidos scripts de trajetória vazios/de demonstração e a cena genérica de inimigo sem uso. `world/world.tscn` continua como entrada de compatibilidade, redirecionando ao combate oficial sem criar outro jogador/controlador.
- Testes e documentação excluídos dos presets de exportação.

## Regras preservadas e decisões pendentes

| Tema | Protótipo preservado | GDD / decisão da equipe |
| --- | --- | --- |
| Energia e HP máximo | 5 de energia, 80 HP | GDD menciona 3 e 70; escolher o balanceamento desejado |
| Mão e compra | Cinco cartas iniciais fixas; cartas não jogadas permanecem; reposição aleatória uniforme | GDD descreve deck, descarte de toda a mão, embaralhamento e recompensas; é outro sistema a implementar depois |
| Probabilidade de compra | `draw_chance` continua sem uso | Definir se representa peso de compra, raridade ou algo diferente |
| Cura entre combates | Vitória recupera 25%; descanso recupera 50% | GDD descreve descanso como única cura passiva |
| Mapa | Mapa existente, nós liberados por nível | GDD prevê geração procedural e adjacência; não implementado nesta etapa |
| Veneno | Uma aplicação acumulada, processada após o ataque do jogador e antes dos inimigos | Confirmar duração, redução de cargas e interação com escudo antes de mudar |
| Calculadora | Mantém a chance de aplicar veneno existente no código | A seção de personagens do GDD diz que calculadora não envenena |
| Trajetória mista | Mantém a regra atual: deslocamento Y vira termo constante quando há curva/onda; alcance usa X ou o fallback original | Confirmar a interpretação matemática e se toda composição deve partir da origem |
| Efeitos e progressão futuros | Nenhum conteúdo novo | Projétil animado, recompensas, deck building e novas cartas aguardam etapa própria |

O objetivo é permitir revisar a estrutura sem alterar simultaneamente a dificuldade e os sistemas planejados. Os valores específicos podem ser ajustados nos scripts derivados dos inimigos; a regra comum fica na base. Para uma nova operação matemática, altere a fórmula e seus testes; para novos recursos visuais, altere a apresentação correspondente.

## Validação e roteiro manual

Validação realizada com Godot **4.6.3**, importação do editor, suíte headless e suíte renderizada em Compatibility/OpenGL. A suíte carrega os scripts/cenas do jogo, abre os nove cenários, injeta eventos de arraste e verifica seleção, energia, suporte, dano/escudo, morte, veneno letal, vitória comum/chefe, teleporte e navegação real entre cenas.

Resultado final: **158 verificações headless e 161 verificações com renderização, todas sem falhas**, com código de saída 0. As três verificações extras validam a gravação das capturas. A importação final e o `git diff --check` também passaram.

As capturas de combate inicial, carta selecionada e fórmula mista foram inspecionadas. Essa validação não substitui uma partida completa da equipe nem valida o executável exportado, desempenho em outras máquinas ou todos os tamanhos de janela. O renderer padrão do projeto foi preservado.

Roteiro sugerido para a revisão:

1. Abrir o projeto e jogar pelo caminho menu → mapa → batalha.
2. Arrastar cada tipo de carta, combinar efeitos e devolver cartas; conferir energia e trajetória.
3. Usar Limpar e Fim do turno; tentar cliques e arrastes durante as animações.
4. Testar pausa/retomada, saída ao menu e início de uma nova partida.
5. Concluir uma batalha normal, uma derrota e o chefe; conferir HP e avanço no mapa.
6. Conferir os nove cenários, especialmente suporte entre tipos diferentes de inimigo.
7. Revisar as decisões da tabela acima antes de iniciar conteúdo novo.

Para comparar a proposta com o original, use o diff local do Git. Os arquivos adicionados também precisam entrar no versionamento quando a equipe aceitar a estrutura; não versionar apenas as modificações dos scripts antigos.
