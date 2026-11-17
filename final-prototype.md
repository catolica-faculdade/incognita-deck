# Incógnita Deck — Protótipo final

Branch `feat/final-prototype`. Registro das alterações da entrega base e complemento ao GDD para esta versão.

## Combate e projétil

- A prévia e o projétil usam os mesmos segmentos calculados pelas cartas. O projétil parte a 1.100 unidades de cena por segundo e acelera até 3.600. A reação a cada acerto ainda faz uma pausa. Depois dela, o disparo continua com a velocidade que já acumulou.
- A colisão é calculada ao longo dos segmentos, na ordem percorrida. O disparo atravessa os alvos vivos. Cada entrada na região de um inimigo conta como um acerto. Permanecer dentro da região conta como um só contato.
- O raio de acerto existente é medido a partir da posição de repouso do inimigo. A flutuação visual não muda as coordenadas de acerto. Se o Professor se teleportar ao receber dano, um contato previsto na posição anterior é ignorado.
- O primeiro acerto em cada inimigo causa dano integral e aplica toda a quantidade de veneno e vulnerabilidade. Novas passagens no mesmo disparo causam 70% do dano, arredondado para baixo, e adicionam uma carga de cada um desses efeitos presentes na combinação.
- A próxima ação inimiga aparece ao manter o mouse sobre o inimigo ou sua barra de vida.

## Mão e descarte

- O jogador compra até cinco cartas no início de cada turno, incluindo o primeiro. A mão pode chegar a sete cartas quando duas foram mantidas do turno anterior.
- Em **Fim do turno**, clique em até duas cartas não jogadas para mantê-las na mão. Clique novamente em uma carta para desmarcá-la. **Continuar** resolve o turno. Se a mão estiver vazia, **Fim do turno** resolve o turno diretamente.
- Cartas jogadas e cartas deixadas sem marcar vão para a pilha de descarte. Manter cartas custa zero energia. Se a pilha de compra esgotar durante a compra, a pilha de descarte é embaralhada para completá-la.
- O HUD indica o tamanho da mão e das duas pilhas. Quando a mão cresce, as cartas se sobrepõem parcialmente e a carta apontada aparece na frente.

## Painel de mensagens

- As instruções e os efeitos das cartas preparadas, como veneno e escudo, aparecem num painel de papel no canto superior direito.
- O painel ajusta sua altura ao conteúdo desde a abertura do combate, inclusive antes da primeira carta preparada.
- Em **Fim do turno**, o painel mostra dois espaços em formato de carta. O símbolo `+` indica um espaço disponível e a marca verde com `✓` confirma cada carta escolhida para manter.

## Campanha e entrega

- A primeira entrega base usava sete etapas até o Professor. A campanha atual está descrita nos passos 9 e 10. Ambos os modos usam as mesmas regras de combate. O modo Difícil oculta as ilustrações das cartas.
- Rigidez, a regra de borda de 3× da arena e o salto da animação longa ficam para a definição da expansão de trajetórias.
- O responsável pela entrega vai gerar o executável com o preset **Windows Desktop**.

## Passos 6 a 8

- **Elite.** Entre as três opções de recompensa há pelo menos uma carta rara. O jogo identifica as raras na tela de recompensa. O jogador ainda pode escolher qualquer uma das três ou pular.
- **Descanso.** O jogador escolhe entre curar 40% da vida máxima, até o limite de HP, e remover uma cópia de uma carta. Um benefício conclui o nó. O jogo preserva pelo menos uma carta no baralho.
- **Espiral de Arquimedes.** Custa 2 de energia e é rara. Tem quatro voltas e raio máximo de três unidades da grade. Começa no fim do percurso ou na origem se for a única carta de trajetória. Em um disparo com Espiral, o primeiro acerto em cada inimigo causa dano integral. Até dois acertos adicionais causam 70% do dano, arredondado para baixo. Passagens seguintes não causam dano nem aplicam efeitos.
- **Reflexão em X.** Custa 1 de energia e inverte o Y do percurso montado até esse ponto. Espiral e Reflexão são aplicadas na ordem da seleção, depois de compor a trajetória base.
- **Espelhos na arena.** Alguns encontros exibem um espelho diagonal fixo, identificado no mapa. O espelho reflete o caminho restante a partir do contato e dura o combate. A prévia e o disparo compartilham o resultado. O percurso termina ao atingir o limite de 16 reflexões no mesmo disparo.

## Passos 9 e 10

- **Campanha.** O Plano Cartesiano tem seis etapas e termina no Professor. Sala de Aula tem sete e termina nos Alunos. Diretoria tem oito e termina no Diretor. O ENEM é a 22ª etapa e acontece fora do mapa. Derrotar o chefe do mundo restaura toda a vida antes da recompensa. O baralho continua na transição. Cada mundo tem quatro inimigos comuns exclusivos e usa uma tonalidade própria no papel do mapa e da arena.
- **Pool de Elites.** Sentinela e Alquimista no Plano Cartesiano. Tesoura, Compasso e Sentinela na Sala de Aula. Relógio, Compasso e Alquimista na Diretoria. Todo nó Elite reserva uma vaga a um deles. Esse inimigo recebe +22% de vida (ao menos +6 HP), +2 de dano e duas intenções adicionais intercaladas com suas ações originais.
- **Chefes.** Alunos, Diretor e ENEM agem duas vezes em dois de cada três turnos. A ação extra é de defesa ou suporte e aparece abaixo da primeira intenção ao passar o mouse. O Professor age uma vez.
- **Espelhos.** Compasso, Alunos, Diretor e ENEM podem posicionar espelhos que duram de 4 a 12 turnos do jogador. A duração é sorteada pela semente do encontro e aparece no espelho. Ele entra na prévia desde o primeiro turno e conta para o limite de quatro espelhos simultâneos na arena.
- **Arte.** Treze sprites transparentes de inimigos em `assets/enemies/doodle/`. O jato preto e branco, em `assets/projectiles/water_doodle.png`, aponta para a direção final da prévia e gira com o disparo durante o percurso.

As artes foram geradas com o ImageGen integrado e recortadas em sprites individuais. Os três pedidos de geração foram um atlas 3×3 com Lápis, Régua, Tesoura, Caderno, Compasso, Relógio, Alunos, Diretor e ENEM, um atlas 2×2 com Borracha, Clipe, Transferidor e Grampeador e um jato d'água horizontal voltado à direita com gotas atrás. Para os três, a direção visual foi contorno preto irregular de caneta, preenchimento branco, silhueta legível em tamanho reduzido, fundo transparente, sem texto ou cenário.

## Passos 11 e 12

- **Salvamento.** Um slot em `user://incognita-run.save` registra a semente, o mapa, o nó, o mundo, o modo, o HP e o baralho. A pausa permite gravar manualmente, e o menu oferece **Continuar run**. Ao retomar no combate, o encontro reinicia no turno 1 com o HP de entrada. Se houver recompensa pendente, o jogo reabre as mesmas opções. Começar outra run substitui o slot, e derrota ou conclusão encerram o salvamento.
- **Atalhos.** E ou Espaço abre ou confirma o fim do turno. Tab abre ou fecha o baralho. Ctrl alterna a revisão das cartas preparadas. Esc pausa.
- **Indicadores de teclado.** O HUD mostra os atalhos das ações e marca as cartas de 1 a 9 e depois 0. A tecla de uma carta permite prepará-la, devolvê-la ou selecioná-la para manter. Os números ficam estáveis durante o turno e também aceitam o teclado numérico.
- **Recompensas pelo teclado.** Os botões indicam as teclas 1, 2 e 3 da esquerda para a direita. O teclado numérico também confirma a escolha.
- **Evento.** Alguns nós mostram o **Desafio do Monitor**. A função e as opções de resposta dependem da semente do nó. O jogador pode acertar o cálculo para escolher uma carta sem combate, treinar contra inimigos ou seguir.

## Revisão de combate e arte

- O Plano Cartesiano introduz o **Alvo móvel**, que muda a altura do primeiro inimigo vivo a cada dois turnos. A Sala de Aula introduz **Espelhos**. A Diretoria acrescenta **Barreiras**, que interrompem o disparo e podem coexistir com espelhos. O mapa mostra as regras de cada nó, e a chance sobe nas etapas mais profundas.
- Além do tier, a profundidade acrescenta 0,65% de vida por etapa já passada e +1 de dano a cada dez etapas. Os Elites mantêm seus bônus próprios.
- Os inimigos mostram dicas estratégicas nas intenções. A Calculadora reduz o dano de composições com menos de duas cartas matemáticas, o Slime fica frágil sob veneno, o Cubo protege melhor com escudo e o Fantasma protege os outros. A Tesoura apara composições longas, o Grampeador amortece disparos fracos e a Badalada do Relógio ganha dano com o tempo.
- Entraram quatro cartas. **Rotação** gira o caminho em 15°. **Fenda** atravessa barreiras. **Prisma** acrescenta 7 de dano com Reflexão em X ou ricochete. **Catalisador** soma 3 cargas quando a jogada já aplica veneno. A Espiral passou de dez para quatro voltas com o mesmo raio.
- Redesenhei os 13 sprites em `assets/enemies/doodle/` com o ImageGen integrado. O pedido para os dois atlas foi preservar a ordem dos personagens, usar Cubo, Slime e Professor como referências, simplificar os olhos e a boca, igualar o traço de caneta e deixar o interior transparente para revelar o quadriculado. Os sprites foram recortados em PNGs individuais. A prévia agora marca o alvo com um losango ao lado da barra de HP, visível mesmo em sprites só de contorno.

## Validação

Os testes foram executados no Godot 4.6.1 para Windows. O README indica 4.6.3 para abrir o projeto.

| Verificação | Resultado |
| --- | --- |
| Regressão antes das mudanças | 10.701 verificações, zero falhas |
| Regressão da versão anterior com renderização | 10.736 verificações, zero falhas |
| Regressão da regra atual com renderização | 10.732 verificações, zero falhas. Revisão visual das cartas selecionadas para manter |
| Regressão do painel de mensagens com renderização | 10.739 verificações, zero falhas. Revisão visual dos efeitos e dos espaços de retenção |
| Regressão dos passos 6 a 8 com renderização | 10.793 verificações, zero falhas. Revisão visual de recompensa, descanso, espiral e espelho |
| Regressão dos passos 9 e 10 com renderização | 11.774 verificações, zero falhas. Inclui a garantia de inimigo difícil, a expiração do espelho e a campanha completa |
| Regressão do ajuste da Espiral | 11.745 verificações headless, zero falhas. Um disparo com cinco passagens aplica só três acertos e limita os efeitos |
| Regressão da aceleração do projétil | 11.751 verificações headless, zero falhas. Inclui continuidade após acertos, limite de velocidade e posição ao longo da trajetória |
| Regressão dos turnos de chefes e da duração de espelhos | 11.801 verificações headless, zero falhas. Inclui ordem das ações, efeitos por turno e expiração independente dos espelhos temporários |
| Regressão dos passos 11 e 12 | 11.437 verificações com renderização, zero falhas. Inclui retomar combate ou recompensa, limpar o slot na derrota, atalhos e os três caminhos do evento |
| Regressão da revisão de combate e arte | 11.501 verificações com renderização, zero falhas. Inclui a barreira na prévia e no disparo, Fenda, Prisma, Catalisador e as diferenças entre inimigos |
| Playtest antes das mudanças | 1 vitória em 4 runs, zero falhas de execução |
| Playtest da versão anterior | 4 vitórias em 4 runs, zero falhas de execução |
| Playtest da regra atual | 3 vitórias em 4 runs, zero falhas de execução |
| Playtest após os passos 6 a 8 | 4 vitórias em 4 runs, zero falhas de execução |
| Playtest da campanha de três mundos | 3 vitórias em 4 runs, zero falhas de execução. A semente 991 terminou em derrota na 18ª etapa, na Diretoria |

| Semente | Modo | Turnos na campanha atual | HP final | Resultado |
| --- | --- | ---: | ---: | --- |
| 17 | Normal | 96 | 55 | Vitória |
| 42 | Difícil | 68 | 64 | Vitória |
| 991 | Normal | 83 | 0 | Derrota na Diretoria |
| 12345 | Difícil | 81 | 80 | Vitória |

O playtest usa as mesmas quatro sementes da referência. A referência executou as quatro no modo Normal. A heurística mantém até duas cartas com base no valor atribuído a elas nas recompensas e escolhe cura no Descanso.
