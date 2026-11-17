# Incógnita Deck

Jogo de cartas, estratégia por turnos e composição de funções em **Godot 4.6 / GDScript**.

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

1. Na tela principal do repositório. Selecione a opção "Code" (botão verde, na tela principal do repositório) e selecione "Download Zip" ou "Baixar Zip".
2. Após baixar o ZIP, selecione ele na pasta de Downloads (no próprio computador), aperte com o botão direito e selecione a opção extrair.
3. Após extrair, abra o aplicativo *Godot* e selecione a opção "Importar". Selecione o arquivo `project.godot` na pasta extraída, confirme a importação, abra o projeto e aguarde a importação dos recursos. 
4. Continue para o capítulo "Jogar". 

### Quero clonar o projeto

1. Abra sua IDE de preferência (os comandos a seguir foram marcados utilizando o Visual Studio Code, pode haver divergências).
2. Selecione a opção de *Source Control* e a opção *Clone Repository*.
3. Selecione *Clone from Github*.
4. Copie e cole esta url: "https://github.com/catolica-faculdade/incognita-deck", pressione enter.
5. Selecione a pasta de destino.
6. Após clonar abra o aplicativo Godot e selecione a opção "Importar". Selecione o arquivo `project.godot` na pasta clonada, confirme a importação, abra o projeto e aguarde a importação dos recursos.  
7. Continue para o capítulo "Jogar". 

### Utilizando o executável

1. Caso haja uma versão executável publicada, abra a seção [Releases do repositório](https://github.com/catolica-faculdade/incognita-deck/releases) e baixe o pacote para Windows referente à entrega.
2. Extraia o pacote completo para uma pasta no computador, mantendo todos os arquivos juntos.
3. Abra o arquivo com extensão `.exe` do jogo com dois cliques e divirta-se! Não é necessário abrir o Godot. Caso não haja um executável disponível, utilize uma das opções de baixar ou clonar o projeto.

## Jogar

1. Abra `project.godot` no Godot 4.6.3 e pressione **F5**.
2. Clique em iniciar e escolha **Normal** ou **Difícil** antes de cada run. Difícil esconde as ilustrações das cartas e mantém fórmulas, alvos e custos.
3. No mapa, escolha um nó disponível. Os encontros têm dificuldades sorteadas e composições geradas. Apenas rotas adjacentes ficam disponíveis.
4. Arraste cartas para a área de preparo acima da mão para montar trajetória e efeitos. O número amarelo é o custo em energia. Devolva cartas ou use **Limpar** para desfazer.
5. Clique em **Fim do turno**, selecione até duas cartas não jogadas para manter e clique em **Continuar**. O projétil segue a prévia e aplica efeitos ofensivos ao atingir inimigos. Cura e bloqueio afetam o jogador mesmo sem acerto.
6. Ao vencer, escolha **uma de três cartas** para o baralho, ou pule a recompensa. Derrote o chefe de cada mundo para avançar e vença o ENEM para concluir a jornada.

*Obs*: Use **Ver baralho** para revisar suas cartas e **Esc** para pausar. O modo difícil também vale nas recompensas e na visualização do baralho.

## Regras básicas

- A campanha tem três mapas: **O Plano Cartesiano** (6 etapas, Professor), **Sala de Aula** (7 etapas, Alunos) e **Diretoria** (8 etapas, Diretor). Ao sair da Diretoria, o próximo combate é o **ENEM**.
- O jogador inicia a tentativa com **80 de vida** e possui **5 pontos de energia por turno**. A energia é restaurada no início de cada turno e não acumula entre turnos.
- Cada carta possui um custo em energia. Combine cartas para montar uma trajetória que atinja os inimigos, ou utilize efeitos para auxiliar o personagem.
- As cartas jogadas e as que você deixou sem marcar vão para o descarte. No início do próximo turno, compre até cinco cartas além das que escolheu manter. A mão pode chegar a sete cartas.
- O combate termina em vitória quando todos os inimigos são derrotados. Caso a vida do jogador chegue a zero, a tentativa termina em derrota.
- A vida restante é mantida entre combates. No **Descanso**, escolha entre curar **40% da vida máxima** (32 HP) e remover uma cópia de uma carta.
- Cada encontro de **Elite** inclui um inimigo difícil e oferece ao menos uma carta **Rara**. Nos encontros com espelho fixo ou colocado por um inimigo, a prévia mostra o desvio do disparo.
- Ao vencer um combate, escolha uma carta para adicionar ao baralho durante a tentativa, ou pule a recompensa.
- Ao passar o mouse por cima de um inimigo, é possível verificar seu nome, vida, escudo e próxima ação. A barra de vida fica azul enquanto ele possui escudo, e o marcador de veneno aparece enquanto ele estiver envenenado.

## Conteúdo

- 36 cartas, incluindo Rotação, Fenda, Prisma e Catalisador. Combine as cartas de trajetória e efeitos para lidar com as defesas dos inimigos e as regras da arena.
- O Plano Cartesiano pode ter um alvo móvel, a Sala de Aula pode ter espelhos e a Diretoria pode combinar espelhos e barreiras. A chance sobe ao avançar em cada mundo.
- Baralho inicial de 12 cartas, embaralhamento do descarte quando a compra esgota e recompensas persistentes durante a run.
- Três mapas ramificados e um encontro final, com vida e baralho preservados entre mundos. Cada semente reproduz seus mapas e encontros.
- 21 arquétipos de inimigos, incluindo cinco difíceis reservados aos Elites e quatro chefes.

As mudanças da entrega base estão no [registro do protótipo final](final-prototype.md), que complementa o GDD com as regras implementadas.

As regras, valores e pontos para avaliação estão em [docs/new-content.md](docs/new-content.md). O documento da reestruturação anterior foi mantido como histórico.

A apresentação utiliza os backgrounds, papéis, botões e ícones originais. O mapa desenha caminhos tracejados sobre `background_map.png`, sem usar a imagem do mapa pré-montado. O menu usa layout centralizado, sem câmera ou sobreposição entre botões.

## Limitações da versão atual

- Melhorias de cartas continuam fora do escopo da versão atual.
- O jogo ainda não possui tutorial interno. Utilize as orientações deste guia para iniciar e jogar.

## Continuar uma run

O jogo usa um slot. O menu exibe **Continuar run** quando há um progresso válido. O jogo salva automaticamente ao avançar e também oferece **Salvar run** no menu de pausa. Retomar durante um combate reinicia aquele encontro com o HP de entrada. Se a recompensa já estiver disponível, a retomada abre as mesmas cartas. Uma nova run substitui o slot. Derrota ou conclusão apagam o salvamento.

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
core/run/                     Geração do mapa e dos encontros
card/                         Catálogo e apresentação das cartas
interface/                    Dificuldade, combate, recompensas, baralho e resultados
settings/                     Estado da run, navegação e janela
world/map/                    Mapa procedural e suas rotas
world/combat/                 Montagem do encontro; cenas antigas para inspeção
world/enemy/enemy_combat/     Base comum e 8 comportamentos de inimigos
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
