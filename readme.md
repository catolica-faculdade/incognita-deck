# Incógnita Deck

Jogo de cartas, estratégia por turnos e composição de funções em **Godot 4.6 / GDScript**.

## Jogar

1. Abra `project.godot` no Godot 4.6.3 e pressione **F5**.
2. Clique em iniciar e escolha **Normal** ou **Difícil** antes de cada run. Difícil esconde as ilustrações das cartas e mantém fórmulas, alvos e custos.
3. No mapa, escolha um nó disponível. Os encontros têm dificuldades sorteadas e composições geradas; apenas rotas adjacentes ficam disponíveis.
4. Arraste cartas para a área de preparo acima da mão para montar trajetória e efeitos. O número amarelo é o custo em energia. Devolva cartas ou use **Limpar** para desfazer.
5. **Fim do turno** confirma a jogada. Efeitos ofensivos precisam de inimigos atingidos pela trajetória; cura e bloqueio afetam você.
6. Ao vencer, escolha **uma de três cartas** para o baralho, ou pule a recompensa. O chefe da sétima etapa encerra a run.

Use **Ver baralho** para revisar suas cartas e **Esc** para pausar. O modo difícil também vale nas recompensas e na visualização do baralho.

## Conteúdo

- 30 cartas: deslocamentos, parábolas, ondas, cura, bloqueio, veneno, perfuração, vulnerabilidade, força e espinhos.
- Baralho inicial de 12 cartas; compra de 5 por turno, descarte de toda a mão, embaralhamento quando a compra esgota e recompensas persistentes durante a run.
- Mapa de 7 etapas com bifurcações, descanso, encontros comuns, elite e chefe. Cada semente conserva suas opções durante a partida.
- 8 arquétipos de inimigos, com intenções visíveis, estratégias próprias e atributos escalados pela dificuldade do encontro.

As regras, valores e pontos para avaliação estão em [docs/new-content.md](docs/new-content.md). O documento da reestruturação anterior foi mantido como histórico.

A apresentação utiliza os backgrounds, papéis, botões e ícones originais. O mapa desenha caminhos tracejados sobre `background_map.png`, sem usar a imagem do mapa pré-montado. O menu usa layout centralizado, sem câmera ou sobreposição entre botões.

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
