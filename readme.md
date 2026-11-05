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
5. **Fim do turno** confirma a jogada. Efeitos ofensivos precisam acertar os inimigos para serem efetivados, demais efeitos de cura e bloqueio afetam o player independente disso.
6. Ao vencer, escolha **uma de três cartas** para o baralho, ou pule a recompensa. O chefe da sétima etapa encerra a jornada.

*Obs*: Use **Ver baralho** para revisar suas cartas e **Esc** para pausar. O modo difícil também vale nas recompensas e na visualização do baralho.

## Regras básicas

- O objetivo é derrotar os inimigos de cada combate, avançar pelo mapa e vencer o Professor na sétima etapa.
- O jogador inicia a tentativa com **80 de vida** e possui **5 pontos de energia por turno**. A energia é restaurada no início de cada turno e não acumula entre turnos.
- Cada carta possui um custo em energia. Combine cartas para montar uma trajetória que atinja os inimigos, ou utilize efeitos para auxiliar o personagem.
- Ao selecionar **Fim do turno**, a jogada é confirmada e os inimigos sobreviventes realizam suas ações. As cartas jogadas e as que permaneceram na mão são descartadas, e uma nova mão é comprada no próximo turno.
- O combate termina em vitória quando todos os inimigos são derrotados. Caso a vida do jogador chegue a zero, a tentativa termina em derrota.
- A vida restante é mantida entre combates. Os nós de descanso recuperam **24 de vida**, sem ultrapassar o máximo de 80.
- Ao vencer um combate, escolha uma carta para adicionar ao baralho durante a tentativa, ou pule a recompensa.
- Ao passar o mouse por cima de um inimigo, é possível verificar seu nome, vida e escudo. A barra de vida fica azul enquanto ele possui escudo, e o marcador de veneno aparece enquanto ele estiver envenenado.

## Conteúdo

- 30 cartas: deslocamentos, parábolas, ondas, cura, bloqueio, veneno, perfuração, vulnerabilidade, força e espinhos.
- Baralho inicial de 12 cartas; compra de 5 por turno, descarte de toda a mão, embaralhamento quando a compra esgota e recompensas persistentes durante a run.
- Mapa de 7 etapas com bifurcações, descanso, encontros comuns, elite e chefe. Cada semente conserva suas opções durante a partida.
- 8 arquétipos de inimigos, com comportamentos próprios, estratégias próprias e atributos escalados pela dificuldade do encontro.

O **GDD atualizado** deve ser consultado pelo link indicado a seguir: **[INSERIR LINK DO GDD ATUALIZADO ANTES DA ENTREGA]**.

As regras, valores e pontos para avaliação estão em [docs/new-content.md](docs/new-content.md). O documento da reestruturação anterior foi mantido como histórico.

A apresentação utiliza os backgrounds, papéis, botões e ícones originais. O mapa desenha caminhos tracejados sobre `background_map.png`, sem usar a imagem do mapa pré-montado. O menu usa layout centralizado, sem câmera ou sobreposição entre botões.

## Limitações da versão atual

- A campanha atual possui sete etapas por tentativa, terminando no Professor. Os demais mundos ainda não foram implementados.
- Não há salvamento e retomada de uma tentativa em andamento. Ao sair do jogo, não é possível continuar do mesmo ponto.
- Os eventos aleatórios ainda não foram implementados.
- Não é possível remover ou melhorar cartas do baralho durante a tentativa.
- Os encontros de elite ainda não oferecem recompensas diferenciadas em relação aos combates comuns.
- As ações principais são realizadas com o mouse. O jogo possui **Esc** para pausar, mas os demais atalhos de teclado previstos ainda não foram implementados.
- O jogo ainda não possui tutorial interno. Utilize as orientações deste guia para iniciar e jogar.

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

A primeira suíte valida scripts/cenas, 60 sementes de mapa, cartas, pilhas, efeitos, entrada de mouse, resultados e navegação até a conclusão. A segunda executa os mesmos casos com renderização e salva capturas. A terceira joga quatro runs com uma heurística, sem alterar HP ou eliminar inimigos artificialmente.

O wrapper retorna falha também se o Godot emitir erros de script/runtime, mesmo quando o processo da engine retorna 0. Testes e documentação ficam excluídos dos presets de exportação.
