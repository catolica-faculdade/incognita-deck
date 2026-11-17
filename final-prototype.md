# Incógnita Deck — Protótipo final

Branch `feat/final-prototype`. Registro das alterações da entrega base e complemento ao GDD para esta versão.

## Combate e projétil

- A prévia e o projétil usam os mesmos segmentos calculados pelas cartas. O projétil se move a 1.100 unidades de cena por segundo entre contatos e aguarda a reação a cada acerto antes de seguir.
- A colisão é calculada ao longo dos segmentos, na ordem percorrida. O disparo atravessa os alvos vivos. Cada entrada na região de um inimigo conta como um acerto. Permanecer dentro da região conta como um só contato.
- O raio de acerto existente é medido a partir da posição de repouso do inimigo. A flutuação visual não muda as coordenadas de acerto. Se o Professor se teleportar ao receber dano, um contato previsto na posição anterior é ignorado.
- Cada acerto aplica o dano e a perfuração da combinação. O primeiro acerto em cada inimigo aplica a quantidade integral de veneno e vulnerabilidade. Novas passagens adicionam uma carga de cada um desses efeitos se estiver presente na combinação.
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

- A campanha da entrega base consiste nas sete etapas do mapa atual e termina no Professor. Ambos os modos usam as mesmas regras de combate. O modo Difícil oculta as ilustrações das cartas.
- Rigidez, a regra de borda de 3× da arena e o salto da animação longa ficam para a definição da expansão de trajetórias.
- O responsável pela entrega vai gerar o executável com o preset **Windows Desktop**.

## Validação

Os testes foram executados no Godot 4.6.1 para Windows. O README indica 4.6.3 para abrir o projeto.

| Verificação | Resultado |
| --- | --- |
| Regressão antes das mudanças | 10.701 verificações, zero falhas |
| Regressão da versão anterior com renderização | 10.736 verificações, zero falhas |
| Regressão da regra atual com renderização | 10.732 verificações, zero falhas. Revisão visual das cartas selecionadas para manter |
| Regressão do painel de mensagens com renderização | 10.739 verificações, zero falhas. Revisão visual dos efeitos e dos espaços de retenção |
| Playtest antes das mudanças | 1 vitória em 4 runs, zero falhas de execução |
| Playtest da versão anterior | 4 vitórias em 4 runs, zero falhas de execução |
| Playtest da regra atual | 3 vitórias em 4 runs, zero falhas de execução |

| Semente | Modo | Turnos | HP final | Resultado |
| --- | --- | ---: | ---: | --- |
| 17 | Normal | 23 | 19 | Vitória |
| 42 | Difícil | 20 | 80 | Vitória |
| 991 | Normal | 22 | 32 | Vitória |
| 12345 | Difícil | 22 | 0 | Derrota na sexta etapa |

O playtest usa as mesmas quatro sementes da referência. A referência executou as quatro no modo Normal. Na regra atual, a heurística escolhe até duas cartas para manter com base no valor dado a cada carta na recompensa. Os atributos das cartas e dos inimigos foram preservados.
