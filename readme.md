# Incógnita Deck

Jogo de cartas, estratégia por turnos e composição de funções em **Godot 4.6 / GDScript**.

**Atualizado em 18/11/2026 - Entrega do protótipo final.** Guia do estado atual da branch `feat/final-prototype`.

## Requisitos

- Sistema operacional: Windows.
- Para executar pelo projeto: Godot **4.6.3**, versão padrão, sem necessidade de .NET.
- Para clonar o projeto: Git instalado. Caso escolha baixar o ZIP, não é necessário possuir Git.
- Para utilizar o executável: não é necessário possuir Godot instalado.
- O projeto não possui dependências adicionais para instalar. Os recursos necessários são importados pelo próprio Godot.

# Como iniciar o jogo?

## Primeiro passo

0. Para executar pelo projeto, é necessário possuir o aplicativo Godot, caso não o possua, é possível baixá-lo por aqui: [Godot](https://godotengine.org/download/windows/). Os demais passos de instalação do Godot podem ser encontrados no próprio site, após baixar, basta continuar com o passo **1**. Caso escolha utilizar o executável, não é necessário instalar o Godot
1. Abra o repositório no github: [Incógnita Deck](https://github.com/catolica-faculdade/incognita-deck).
2. Escolha o capítulo "Quero baixar o projeto", "Quero clonar o projeto" ou "Utilizando o Executável", escolha a opção que se encaixar melhor no cenário que desejar. Caso já possua a versão desejada do projeto, pode pular para o capítulo "Jogar".

### Quero baixar o projeto

1. Na tela principal do repositório, selecione a branch **feat/final-prototype**, correspondente ao protótipo descrito neste guia. Selecione a opção "Code" e depois "Download ZIP" ou "Baixar ZIP". Para uma release específica, utilize o código-fonte associado àquela versão.
2. Após baixar o ZIP, selecione ele na pasta de Downloads (no próprio computador), aperte com o botão direito e selecione a opção extrair.
3. Após extrair, abra o aplicativo *Godot* e selecione a opção "Importar". Selecione o arquivo `project.godot` na pasta extraída, confirme a importação, abra o projeto e aguarde a importação dos recursos. 
4. Continue para o capítulo "Jogar". 

### Quero clonar o projeto

1. Abra sua IDE de preferência (os comandos a seguir foram marcados utilizando o Visual Studio Code, pode haver divergências).
2. Selecione a opção de *Source Control* e a opção *Clone Repository*.
3. Selecione *Clone from Github*.
4. Copie e cole esta url: "https://github.com/catolica-faculdade/incognita-deck", pressione enter.
5. Selecione a pasta de destino.
6. Após clonar, selecione a branch **feat/final-prototype** no controle de versão da IDE. Abra o Godot e selecione "Importar". Escolha `project.godot` na pasta clonada, confirme a importação e aguarde a importação dos recursos.
7. Continue para o capítulo "Jogar". 

### Utilizando o executável

1. Caso haja uma versão executável publicada, abra a seção [Releases do repositório](https://github.com/catolica-faculdade/incognita-deck/releases), o release deve ser o "Final Prototype" ([Url direta](https://github.com/catolica-faculdade/incognita-deck/releases#release-Release)) e baixe o pacote para Windows referente à entrega.
2. Extraia o pacote completo para uma pasta no computador, mantendo todos os arquivos juntos.
3. Abra o arquivo com extensão `.exe` do jogo com dois cliques e divirta-se! Não é necessário abrir o Godot. Caso não haja um executável disponível, utilize uma das opções de baixar ou clonar o projeto.

## Jogar

1. Abra `project.godot` no Godot 4.6.3 e pressione **F5**, ou abra o executável caso esteja utilizando o pacote Windows.
2. Clique em iniciar e escolha **Tutorial**, **Modo normal** ou **Modo difícil**. Tutorial abre o treino guiado; os outros modos iniciam a campanha diretamente. Difícil esconde as ilustrações das cartas e mantém fórmulas, alvos e custos.
3. No mapa, escolha um nó disponível. Os encontros têm dificuldades sorteadas e composições geradas. Apenas rotas adjacentes ficam disponíveis.
4. Arraste cartas para a área de preparo acima da mão para montar trajetória e efeitos. O número amarelo é o custo em energia. Devolva cartas ou use **Limpar** para desfazer.
5. Clique em **Fim do turno**, selecione até duas cartas não jogadas para manter e clique em **Continuar**. Manter cartas não custa energia. Se a mão estiver vazia, o turno é resolvido diretamente. O projétil segue a prévia e aplica efeitos ofensivos ao atingir inimigos. Cura e bloqueio afetam o jogador mesmo sem acerto.
6. Ao vencer, escolha **uma de três cartas** para o baralho, ou pule a recompensa. Derrote o chefe de cada mundo para avançar e vença o ENEM para concluir a jornada.

*Obs*: Use **Ver baralho** para revisar suas cartas e **Esc** para pausar. O modo difícil também vale nas recompensas e na visualização do baralho.

## Regras básicas

- A campanha tem três mapas: **O Plano Cartesiano** (6 etapas, Professor), **Sala de Aula** (7 etapas, Alunos) e **Diretoria** (8 etapas, Diretor). Ao sair da Diretoria, o próximo combate é o **ENEM**, totalizando **22 etapas**.
- Os combates das duas primeiras etapas de cada mundo são Leves ou Moderados. Elites e regras especiais de arena entram a partir da terceira etapa. A dificuldade dos encontros também cresce com a progressão da campanha.
- O jogador inicia a tentativa com **80 de vida** e possui **5 pontos de energia por turno**. A energia é restaurada no início de cada turno e não acumula entre turnos.
- Cada carta possui um custo em energia. Combine cartas para montar uma trajetória que atinja os inimigos, ou utilize efeitos para auxiliar o personagem.
- As cartas jogadas e as que você deixou sem marcar vão para o descarte. No início do próximo turno, compre até cinco cartas além das que escolheu manter. A mão pode chegar a sete cartas.
- O combate termina em vitória quando todos os inimigos são derrotados. Caso a vida do jogador chegue a zero, a tentativa termina em derrota.
- A vida restante é mantida entre combates. No **Descanso**, escolha entre curar **40% da vida máxima** (32 HP) e remover uma cópia de uma carta.
- Cada encontro de **Elite** inclui um inimigo do grupo de elites do mundo, com atributos reforçados e ações adicionais, e oferece ao menos uma carta **Rara entre as três opções de recompensa**. Nos encontros com espelho fixo ou colocado por um inimigo, a prévia mostra o desvio do disparo.
- Ao vencer um combate, escolha uma carta para adicionar ao baralho durante a tentativa, ou pule a recompensa.
- Ao passar o mouse por cima de um inimigo, é possível verificar seu nome, vida, escudo e próxima ação. A barra de vida fica azul enquanto ele possui escudo, e o marcador de veneno aparece enquanto ele estiver envenenado.
- O primeiro acerto em cada inimigo causa dano integral. Novas passagens no mesmo disparo causam **70% do dano**, arredondado para baixo, e aplicam quantidades reduzidas de veneno e vulnerabilidade. Disparos com Espiral ficam limitados a **três acertos por inimigo**.

## Conteúdo

- 36 cartas de deslocamento, parábola, onda, espiral, reflexão, rotação e efeitos. Incluem cura, escudo, veneno, perfuração, vulnerabilidade, força e espinhos. Fenda atravessa barreiras, Prisma acrescenta dano em combinações com reflexão e Catalisador reforça combinações que aplicam veneno.
- O Plano Cartesiano pode ter um alvo móvel, a Sala de Aula pode ter espelhos e a Diretoria pode combinar espelhos e barreiras. A chance sobe ao avançar em cada mundo.
- Baralho inicial de 12 cartas, embaralhamento do descarte quando a compra esgota e recompensas persistentes durante a run.
- Três mapas ramificados e um encontro final. Derrotar o Professor, os Alunos ou o Diretor restaura toda a vida. O baralho continua entre mundos, e cada semente reproduz seus mapas e encontros.
- 21 arquétipos de inimigos: 12 comuns, cinco tipos de elite e quatro chefes. Alunos, Diretor e ENEM realizam uma ação extra de defesa ou suporte em dois de cada três turnos.
- Projétil animado que acelera ao longo da trajetória, com acertos resolvidos na ordem do percurso e marcação dos alvos previstos.
- Evento **Desafio do Monitor**, recompensas com escolha de cartas e descanso com cura ou remoção de uma cópia do baralho.
- Modos **Normal** e **Difícil**, com as mesmas regras de combate. O modo Difícil oculta as ilustrações das cartas e mantém as informações necessárias para jogar.
- Tutorial opcional com falas escritas do Monitor, destaques visuais e ações práticas.
- Painel de orientações e efeitos no combate, indicadores das cartas mantidas e atalhos visíveis na interface.
- Hovers de cartas e inimigos com texto ampliado, fundo opaco e informações organizadas para análise.
- Configurações de volume separadas para música e efeitos sonoros, pausa e alternância entre janela e tela cheia.

As mudanças da entrega base estão no [registro do protótipo final](final-prototype.md), que complementa o GDD com as regras implementadas.

O registro da segunda entrega está em [docs/new-content.md](docs/new-content.md). Para as regras posteriores e o estado do protótipo final, consulte [final-prototype.md](final-prototype.md). O documento da reestruturação anterior foi mantido como histórico. Esses caminhos são relativos à raiz do repositório.

A apresentação utiliza os backgrounds, papéis, botões e ícones originais. O mapa desenha caminhos tracejados sobre `background_map.png`, sem usar a imagem do mapa pré-montado. O menu usa layout centralizado, sem câmera ou sobreposição entre botões.

## Limitações da versão atual

- Melhorias de cartas continuam fora do escopo da versão atual.
- O evento disponível é o **Desafio do Monitor**; uma variedade maior de eventos permanece como possibilidade de expansão.
- O salvamento não preserva o turno em andamento: ao continuar um combate, o encontro reinicia no primeiro turno, com a vida registrada na entrada.

## Tutorial guiado

Na tela inicial da partida, escolha **Tutorial** entre as três opções disponíveis: **Tutorial**, **Modo normal** e **Modo difícil**. O Monitor acompanha um treino com falas escritas, destaques visuais e ações práticas: abrir o baralho, escolher um caminho no mapa, passar o mouse no inimigo e em uma carta, conferir a trajetória, combinar ataque e escudo, limpar a jogada, manter cartas entre turnos e escolher uma recompensa.

O treino utiliza uma mão e um encontro preparados, com as ilustrações das cartas visíveis. As etapas avançam conforme você realiza a atividade indicada. Ao concluir, começa uma campanha nova no modo Normal, com vida e baralho iniciais. Também é possível sair do tutorial e começar a campanha diretamente.

A aula acompanha o ciclo completo de uma batalha: preparação, disparo, resposta do inimigo, compra do próximo turno, vitória e recompensa. Na visualização do baralho, a narração possui espaço reservado para não cobrir as cartas. As cartas e recompensas do treino não são transferidas para a campanha.

O treino não grava progresso nem altera uma partida salva existente. Começar a campanha após o treino substitui o slot anterior, como qualquer nova run.

## Análise de cartas e inimigos

Mantenha o mouse sobre uma carta, um inimigo ou sua barra de vida para abrir o painel de análise. Os hovers usam **fundo opaco, alto contraste, fonte maior e títulos destacados**, com espaçamento, quebra de linhas e altura ajustada ao conteúdo.

- **Cartas:** nome, custo de energia, alvo, fórmula e descrição dos efeitos. As informações também ficam disponíveis no modo Difícil, sem mostrar ilustrações.
- **Inimigos:** nome, vida atual e máxima, escudo, cargas de veneno quando presentes, próxima ação e dicas estratégicas.

Use essas informações antes de confirmar o turno para conferir o efeito das cartas e planejar sua resposta ao inimigo.

## Continuar uma run

O jogo usa **um único slot**. O menu exibe **Continuar run** quando há um progresso válido. O jogo salva automaticamente por pontos de progresso e também oferece **Salvar run** no menu de pausa. São preservados a semente, o mapa, a posição na campanha, o modo, a vida e o baralho do ponto salvo.

Retomar durante um combate reinicia aquele encontro no primeiro turno, com o HP de entrada; as ações e a mão do turno interrompido não são preservadas. Se a recompensa já estiver disponível, a retomada abre as mesmas cartas. Uma nova run substitui o slot. Derrota ou conclusão apagam o salvamento.

## Atalhos e eventos

- **E** ou **Espaço** abre a seleção de fim de turno e confirma as cartas a manter.
- **1 a 9**, depois **0**, acionam as cartas que exibem esses números. Pressione de novo para devolver a carta preparada ou desmarcá-la na seleção de fim de turno. O teclado numérico também funciona.
- Na recompensa, **1**, **2** ou **3** escolhe a carta indicada, da esquerda para a direita.
- **Tab** abre e fecha o baralho no mapa e no combate. **Ctrl** alterna a revisão das cartas preparadas. **Esc** pausa.
- Nos nós de **Evento**, o Monitor propõe uma questão de função linear. Acerte para escolher uma carta, treine em combate ou siga viagem.

## Organização

```text
core/cards/                   Compra, descarte e embaralhamento
core/combat/                  Seleção, efeitos, funções e geometria de acerto
core/run/                     Geração do mapa, encontros e leitura/gravação do save
card/                         Catálogo e apresentação das cartas
interface/                    Combate, recompensas, descanso, evento, pausa e resultados
settings/                     Estado da run, navegação e janela
world/map/                    Mapa procedural e suas rotas
world/combat/                 Montagem do encontro; cenas antigas para inspeção
world/enemy/enemy_combat/     Base comum e comportamentos dos 21 arquétipos de inimigos
world/player/                 Jogador, estados e renderização da trajetória
assets/, energy/              Arte e áudio existentes
main/                         Menu inicial
```

A execução normal usa `encounter_builder.gd`; as nove fases antigas ficam disponíveis apenas para inspeção/compatibilidade, sem participar do sorteio do mapa. **F6** em `battle_system.tscn` abre um encontro gerado de demonstração.

## Validação

Na raiz do projeto, informe o caminho do Godot se ele não estiver no PATH:

```powershell
./tests/run_tests.ps1 -Godot 'C:/caminho/Godot_console.exe'
./tests/run_tests.ps1 -Godot 'C:/caminho/Godot_console.exe' -Render -CaptureDirectory 'C:/caminho/capturas'
./tests/run_tests.ps1 -Godot 'C:/caminho/Godot_console.exe' -Playtest
```

A primeira suíte valida scripts/cenas, 60 sementes de mapa, cartas, pilhas, projétil, seleção de cartas para manter com mouse, resultados e navegação até a conclusão. A segunda executa os mesmos casos com renderização e salva capturas. A terceira joga quatro runs com uma heurística, duas em cada modo e sem alterar HP ou eliminar inimigos artificialmente.

O wrapper retorna falha também se o Godot emitir erros de script/runtime, mesmo quando o processo da engine retorna 0. Testes e documentação ficam excluídos dos presets de exportação.
