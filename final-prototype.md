# Incógnita Deck — Protótipo final

Branch `feat/final-prototype`. Registro das alterações da entrega base e complemento ao GDD para esta versão.

## Combate e projétil

- A prévia e o projétil usam os mesmos segmentos calculados pelas cartas. O projétil se move a 1.100 unidades de cena por segundo entre contatos e aguarda a reação a cada acerto antes de seguir.
- A colisão é calculada ao longo dos segmentos, na ordem percorrida. O disparo atravessa os alvos vivos. Cada entrada na região de um inimigo conta como um acerto. Permanecer dentro da região conta como um só contato.
- O raio de acerto existente é medido a partir da posição de repouso do inimigo. A flutuação visual não muda as coordenadas de acerto. Se o Professor se teleportar ao receber dano, um contato previsto na posição anterior é ignorado.
- Cada acerto aplica o dano e a perfuração da combinação. O primeiro acerto em cada inimigo aplica a quantidade integral de veneno e vulnerabilidade. Novas passagens adicionam uma carga de cada um desses efeitos se estiver presente na combinação.
- A próxima ação inimiga aparece ao manter o mouse sobre o inimigo ou sua barra de vida.

## Mão e descarte

- O jogador compra até seis cartas no início de cada turno, incluindo o primeiro, com teto de 12 cartas na mão. As cartas não usadas permanecem entre turnos.
- Em **Fim do turno**, clique em até duas cartas não jogadas para marcá-las. Clique novamente em uma carta para desmarcá-la. **Continuar** encerra a seleção e resolve o turno. Quando a mão está vazia, **Fim do turno** resolve o turno diretamente.
- As cartas jogadas e os descartes opcionais vão para a pilha de descarte. O descarte opcional tem custo zero e a compra acontece normalmente no turno seguinte. Se a pilha de compra esgotar durante a compra, a pilha de descarte é embaralhada para completá-la.
- O HUD indica o tamanho da mão e das duas pilhas. Quando a mão cresce, as cartas se sobrepõem parcialmente e a carta apontada aparece na frente.

## Campanha e entrega

- A campanha da entrega base consiste nas sete etapas do mapa atual e termina no Professor. Ambos os modos usam as mesmas regras de combate. O modo Difícil oculta as ilustrações das cartas.
- Rigidez, a regra de borda de 3× da arena e o salto da animação longa ficam para a definição da expansão de trajetórias.
- O responsável pela entrega vai gerar o executável com o preset **Windows Desktop**.

## Validação

Os testes foram executados no Godot 4.6.1 para Windows. O README indica 4.6.3 para abrir o projeto.

| Verificação | Resultado |
| --- | --- |
| Regressão antes das mudanças | 10.701 verificações, zero falhas |
| Regressão do protótipo com renderização | 10.736 verificações, zero falhas. Revisão visual da mão cheia e da seleção de descarte |
| Playtest antes das mudanças | 1 vitória em 4 runs, zero falhas de execução |
| Playtest do protótipo | 4 vitórias em 4 runs, zero falhas de execução |

| Semente | Modo no protótipo | Turnos | HP ao derrotar o Professor |
| --- | --- | ---: | ---: |
| 17 | Normal | 21 | 36 |
| 42 | Difícil | 15 | 80 |
| 991 | Normal | 19 | 57 |
| 12345 | Difícil | 22 | 16 |

O playtest automatizado usa uma heurística e as mesmas quatro sementes da referência. A referência executou as quatro no modo Normal. A conservação de cartas e a compra aumentaram as opções da heurística. Os atributos das cartas e dos inimigos foram preservados nesta entrega.
