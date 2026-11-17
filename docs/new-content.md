`Já disponível na branch 'main'`

# Conteúdo novo — feat/new-content

Implementação local sobre a reestruturação anterior, em 03/11/2026. A branch solicitada é `feat/new-content`; inclui também as alterações da reestruturação que ainda não tinham sido commitadas. Nenhum envio ao remoto foi feito.

## Fluxo da run

Menu → escolha de modo → O Plano Cartesiano → Professor → Sala de Aula → Alunos → Diretoria → Diretor → ENEM → recompensa final → resumo. Iniciar outra run retorna à escolha de modo.

O modo **Difícil** altera a apresentação das cartas: remove a arte de fundo e todos os pictogramas, inclusive nos efeitos, nas ofertas de recompensa e no visualizador do baralho. As expressões, nomes, destinos dos efeitos e custos continuam visíveis. A trajetória no campo permanece disponível. Esse modo não multiplica atributos dos inimigos; a dificuldade numérica vem do tier de cada encontro.

## Cartas e baralho

O catálogo tem 36 cartas. Cada carta possui custo no canto superior direito. Cartas sem energia suficiente ficam acinzentadas. Jogar uma carta ou devolvê-la à mão altera a seleção. Cura, escudo e outros efeitos são aplicados ao confirmar o turno.

| Nova carta | Custo | Efeito |
| --- | ---: | --- |
| Remendo | 1 | Cura 5 HP |
| Guarda | 1 | Ganha 7 de escudo |
| Tinta tóxica | 1 | Aplica 4 de veneno aos alvos atingidos |
| Giz afiado | 1 | +8 de dano no ataque da trajetória |
| Antídoto | 1 | Remove seu veneno e cura 3 HP |
| Muralha | 2 | Ganha 16 de escudo |
| Recuperação | 2 | Cura 12 HP |
| Contágio | 2 | Aplica 9 de veneno aos alvos atingidos |
| Compasso | 2 | +12 de dano, ignorando o escudo dos alvos |
| Espinhos | 1 | 4 de escudo e retorna 4 de dano a cada atacante |
| Ponto fraco | 1 | Aplica 2 de vulnerabilidade aos alvos atingidos |
| Concentração | 1 | +3 de força durante o combate |
| Abrigo | 2 | Cura 6 HP e ganha 8 de escudo |
| Descida | 1 | Deslocamento (5, -2) |
| Rampa | 1 | Soma 0,5x à função |

Os conceitos de bloqueio, veneno acumulado, vulnerabilidade, compra/descarte e escolha de recompensa foram usados como inspiração de design. Nomes, valores e implementação são próprios do projeto; nenhuma arte de outro jogo foi incorporada.

O baralho inicial contém 12 cartas: Avanço ×2; Elevar, Arco, Queda, Onda e Degrau ×1; Remendo ×1; Guarda ×2; Tinta tóxica e Giz afiado ×1. A run começa com 80 HP e cada turno tem 5 de energia. Os efeitos temporários são reiniciados em cada combate; HP e baralho persistem entre encontros.

Em cada combate o baralho é embaralhado com a semente do encontro. O jogador compra até cinco cartas no início de cada turno. Ao confirmar a jogada, pode manter até duas cartas não jogadas e descarta as demais, incluindo as cartas preparadas. Com as cartas mantidas e a nova compra, a mão pode chegar a sete cartas. Se uma compra esgotar a pilha, o descarte é embaralhado para concluir a compra. As ofertas de recompensa têm três IDs diferentes e podem incluir uma cópia de uma carta que já existe no baralho. Apenas uma escolha ou pulo é aceito por vitória. A oferta é sorteada uma vez por vitória.

## Regras dos efeitos

- O projétil percorre os mesmos segmentos da prévia e resolve contatos por ordem de distância percorrida. O primeiro acerto por inimigo usa o dano integral (base 15). Uma nova passagem pelo mesmo inimigo causa 70% do dano, arredondado para baixo, e adiciona até uma carga de cada efeito acumulável presente no ataque.
- Num disparo com Espiral, cada inimigo recebe o primeiro acerto e até dois adicionais. As passagens seguintes não aplicam dano nem efeitos.
- Escudo absorve dano normal e expira no início do próximo turno do seu dono. Perfuração ignora o escudo sem consumi-lo.
- Veneno causa dano igual às cargas no início do turno do alvo, ignora escudo e perde uma carga. Pode se acumular. Veneno letal impede a ação do alvo.
- Vulnerabilidade aumenta dano de ataques em 50%, inclusive no ataque que a aplica, e perde uma carga depois da ação inimiga. Não amplia o dano do veneno ou dos espinhos.
- Força aumenta o dano de todos os seus ataques durante aquele combate. Fraqueza reduz esse dano em 25% e perde uma carga após seu turno.
- Espinhos retornam dano a cada inimigo que ataca, mesmo quando o ataque foi bloqueado. Expiram no seu próximo turno.
- Cura respeita HP máximo; vida não fica negativa. Não há cura automática após vitórias: cura depende de cartas e descanso.

Na composição matemática, ondas agora conservam sua frequência/comprimento e são somadas como funções individuais. Adicionar Avanço não altera a frequência escrita na carta. O maior alcance entre deslocamento X e ondas determina o intervalo desenhado. As cartas Colina/Mergulho usam coeficientes ±0,20 e Vale altera o termo constante em -2, tornando essas opções distintas das anteriores.

A convenção herdada para composições com curva é mantida: o deslocamento Y entra como termo constante, enquanto uma seleção apenas linear define o ponto final. A equipe ainda pode revisar essa convenção pedagógica separadamente.

A Espiral usa o fim do percurso como centro e cresce linearmente em função do ângulo até completar quatro voltas e alcançar três unidades da grade. A Reflexão em X inverte Y. A Rotação gira o trajeto em 15° em torno da origem. O jogo compõe a base primeiro e aplica Espiral, Reflexão e Rotação na ordem em que foram preparadas.

A Fenda atravessa barreiras e permite ricochetes nos espelhos. O Prisma acrescenta 7 de dano quando a jogada inclui uma Reflexão em X ou ricocheteia. O Catalisador acrescenta 3 cargas de veneno quando combinado com uma carta que já aplica veneno.

## Mapa e encontros

Cada run gera três mapas de 6, 7 e 8 etapas. Um nó libera nós da próxima etapa na mesma coluna ou nas colunas vizinhas. Todos os caminhos chegam ao chefe daquele mundo. Após o Diretor, o ENEM acontece fora do mapa. Rotas disponíveis, visitadas e bloqueadas ficam indicadas na tela.

Tiers de 1 a 5 são apresentados como Leve, Moderado, Desafiador, Difícil e Extremo. O tier sobe com o mundo e com a etapa. Elites recebem um tier adicional, limitado a 5. Após a primeira etapa há chance de Descanso e, a partir da terceira, de Elite. A penúltima etapa de cada mundo garante um Descanso na coluna central.

Cada encontro comum reúne 2 a 4 inimigos da lista do mundo. Atributos escalam em **+15% de HP e +1 de dano por tier acima de 1**. Todo Elite contém um inimigo difícil da lista do mundo, com 22% de HP extra (mínimo de 6), +2 de dano e ações extras. No Descanso, escolha curar **40% da vida máxima** (32 HP) ou remover uma cópia de uma carta. O Elite oferece pelo menos uma rara entre três opções.

A profundidade total da run acrescenta 0,65% de HP por etapa já passada, arredondado por inimigo, e +1 de dano a cada dez etapas. O Plano Cartesiano tem encontros em que o inimigo da frente muda de altura a cada dois turnos. Na Sala de Aula podem aparecer espelhos. Na Diretoria, espelhos e barreiras podem aparecer juntos. A chance de cada regra aumenta ao avançar no mapa.

Os nós marcados com **Espelho** têm um segmento refletor fixo. Compasso, Alunos, Diretor e ENEM também podem colocar espelhos com duração sorteada de 4 a 12 turnos do jogador. O contato reflete o trecho restante do percurso, inclusive para curvas. A prévia e o disparo usam a mesma trajetória resultante.

Alguns nós de **Evento** abrem o Desafio do Monitor. A questão e a ordem das respostas são reproduzíveis pela semente do nó. Acertar abre a oferta de cartas. Aceitar o treino abre um combate comum no mesmo nó, que é concluído após a vitória.

O slot da run guarda a posição atual no mapa e o estado de entrada dos encontros. Se uma vitória já tiver sido registrada, a retomada abre a recompensa pendente com as mesmas opções.

Alunos, Diretor e ENEM têm duas ações em dois de cada três turnos. A ação adicional é de defesa ou suporte. As intenções são anunciadas na ordem de execução. O Professor age uma vez por turno.

O mapa é gerado uma única vez e suas sementes de encontro ficam armazenadas na run. Entrar em um nó ou retornar da recompensa não muda os encontros restantes. É impossível selecionar um nó bloqueado usando apenas o ID. A semente exibida permite reproduzir o mapa pela API `GameManager.prepare_run(modo, semente)` em testes.

## Inimigos

| Arquétipo | Comportamento anunciado |
| --- | --- |
| Cubo | Reduz o dano comum enquanto tem escudo. Perfuração evita a redução |
| Fantasma | Protege os aliados e fica exposto enquanto levanta os escudos |
| Calculadora | Reduz em 5 o dano de disparos com menos de duas cartas matemáticas |
| Slime | Aplica veneno e recebe +4 de dano por acerto enquanto está envenenado |
| Sentinela (novo) | Protege aliados, carrega força e usa golpe forte |
| Alquimista (novo) | Usa veneno/fraqueza e anuncia cura quando aliados estão feridos |
| Sanguessuga (novo) | Drena vida com base no dano realmente causado e pressiona quando está ferida |
| Professor | Teleporta, protege o grupo e alterna ataques/veneno; muda a sequência com menos de 50% de HP |

As intenções são escolhidas antes do turno do jogador e executadas sem novo sorteio oculto. Passe o mouse sobre o inimigo ou a barra de vida para consultar a próxima ação. Os três novos arquétipos reaproveitam a arte existente e se diferenciam pelo nome e comportamento.

## Revisão da identidade visual

Revisão solicitada após a implementação funcional: a apresentação volta a usar os backgrounds, papéis, botões e ícones originais, com escrita à mão e contornos irregulares. Foram removidos os painéis e botões azuis/arredondados introduzidos na primeira versão.

O mapa usa `assets/backgrounds/background_map.png`. Nós e conexões são desenhados por cima em tempo de execução, em um percurso horizontal ramificado. Os caminhos tracejados têm pequenas irregularidades estáveis por semente; nós disponíveis recebem círculos de lápis e nós concluídos recebem marcação. A imagem `map_variation_1.png` não participa dessa composição.

O menu foi convertido para Control com alinhamento central e fundo preenchendo o viewport, mantendo logo e botões originais. As margens transparentes do logo são recortadas apenas por AtlasTexture, sem alterar o arquivo de arte. Começar e Sair ocupam espaços separados, e a engrenagem permanece no canto inferior direito.

Dificuldade, recompensa, baralho e resumo compartilham o background de doodles e botões de papel com contorno desenhado. No combate, os botões ilustrados originais de finalizar turno e limpar trajetória foram recuperados; a área de preparo deixou de ser um painel azul. O modo difícil continua removendo ilustrações das cartas.

A tipografia de texto usa fontes de escrita à mão do sistema, definidas em `interface/ui_style.gd`; nenhuma fonte proprietária foi copiada para o projeto.

### Restauração do HUD com símbolos e da energia original

Após a revisão visual, o HUD de combate voltou ao painel compacto translúcido com os ícones originais de vida, escudo e veneno. Foi adicionado um ícone de espinhos gerado com ImageGen, documentado em [thorns-icon.md](thorns-icon.md), também usado na carta Espinhos. Força e fraqueza aparecem como informações auxiliares quando ativas.

O contador inferior usa novamente as seis imagens originais `energy_0.png` a `energy_5.png`, acompanhando gasto, remoção de cartas, limpeza e início de turno. AtlasTexture remove apenas o espaço transparente ao redor dos símbolos, sem modificar as artes originais. As faixas de papel que cobriam toda a largura foram retiradas do combate; os recortes restantes atrás dos controles inferiores também foram removidos na revisão seguinte.

Textos pequenos, valores e botões usam a fonte legível do tema, com oversampling e hinting configurados; a escrita à mão fica nos títulos, com renderização MSDF. Os detalhes dos inimigos passaram para o hover na revisão seguinte. Os ícones usam mipmaps para redução de tamanho. Referência técnica: [fontes no Godot 4.6](https://docs.godotengine.org/en/4.6/tutorials/ui/gui_using_fonts.html) e [propriedades de SystemFont](https://docs.godotengine.org/en/4.6/classes/class_systemfont.html).

A rodada dessa restauração passou em **10.560 verificações renderizadas**, incluindo valores dos quatro símbolos e todos os estados do contador de energia. As capturas do HUD, das cartas, do mapa e dos inimigos foram inspecionadas.

A revisão visual passou em **10.547 verificações renderizadas**, incluindo preenchimento do background do mapa e testes de centralização/separação dos controles do menu. As capturas de menu, mapa, combate, dificuldade e recompensa foram inspecionadas.

### Cartas inteiras, hover e informações no pause

Cartas selecionadas mantêm o mesmo tamanho (128 × 196), moldura, símbolo e informações da mão. A área de soltura foi ampliada e é independente da fileira de cartas preparadas. Os controles inferiores ficam diretamente sobre o fundo, sem os recortes de papel. O custo se sobrepõe ao canto superior direito, fora da moldura.

Turno, fase do combate, etapa, dificuldade do encontro e modo ficam no pause. Inimigos exibem somente uma barra de vida: ao passar o mouse sobre a barra ou o desenho aparecem apenas vida atual/máxima, escudo total (inclusive zero) e nome, sem painel de fundo. Os números ficam acima da barra e o nome abaixo do desenho. Função, próxima ação e demais efeitos não aparecem no hover. Os valores acompanham dano, cura e escudo. Inimigos do mesmo tipo recebem números em ordem de criação (Fantasma 1, Fantasma 2 etc.); o número permanece fixo durante o combate, mesmo após outra duplicata ser derrotada. Inimigos únicos ficam sem número. A regra se aplica aos oito tipos e aos cenários antigos.

Títulos e fórmulas ajustam o tamanho da fonte ao espaço, sem dividir nomes no meio das palavras. A onda usa a forma equivalente `Δy = A·sen(kx)` com `k` na segunda linha. A recompensa remove as legendas repetidas de nome/custo e encurta as instruções.

Validação: **10.712 verificações renderizadas, sem falhas**, incluindo soltura na borda da região ampliada, carta preparada inteira, largura dos textos das 30 cartas, informações no pause, hover real sobre o sprite e a barra e numeração estável dos oito tipos de inimigo. Capturas de combate, recompensa, pause e hover inspecionadas.

## Verificação e limites

A suíte cobre importação/compilação dos recursos, 60 combinações de mundo e semente, determinismo das ofertas, conservação das pilhas, apresentação normal/difícil, arraste real, escudo, veneno, perfuração, ações inimigas e navegação pelas 22 etapas até o resumo. Uma regressão específica cobre um inimigo liberado enquanto outro ainda executa sua ação.

Validação do conteúdo antes da revisão visual, no Godot 4.6.3: **10.530 verificações headless e 10.537 renderizadas, sem falhas ou erros de script/runtime**. As sete verificações extras validam a gravação das capturas. O `git diff --check` também passou. Os totais incluem as verificações repetidas das 60 sementes, não representam essa quantidade de cenários de jogo diferentes. A rodada mais recente da revisão visual está registrada acima.

Há também um jogador automático que avalia subconjuntos da mão, tenta acertar trajetórias e escolhe rotas/recompensas. Ele executa quatro partidas sem manipular HP ou eliminar inimigos artificialmente. Vitórias e derrotas desse bot não comprovam o balanceamento para alunos: a equipe deve revisar legibilidade, duração das runs e curva de dificuldade em partidas humanas.

Na execução final, as quatro partidas terminaram sem falhas de execução: uma vitória (semente 42) e três derrotas (17, 991 e 12345). A simulação serve para detectar travamentos e percorrer o fluxo real; o balanceamento é uma primeira proposta para avaliação da equipe.

Revisar principalmente: custos/valores das novas cartas, velocidade de progressão do veneno, legibilidade das intenções, quantidade de inimigos nas elites, tamanho das cartas em telas menores e conforto do modo difícil. A validação renderizada usa Compatibility/OpenGL; o renderer padrão do projeto e os presets de exportação foram preservados. Um executável exportado não foi validado nesta etapa.
