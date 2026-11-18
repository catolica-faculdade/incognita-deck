# INCÓGNITA DECK

*Plano de ação geral, documentação consolidada e planejamento de desenvolvimento*

**Versão de planejamento • 16/11/2026**

**Base:** GDD original de 49 páginas, decisões pós-GDD, implementações futuras registradas no documento e ideias discutidas nesta conversa.

Este material servirá como referência para continuarmos o desenvolvimento do Incógnita Deck, incluindo as próximas implementações, expansões de conteúdo, mecânicas, inimigos, áreas, interfaces e ajustes necessários.

## 0. Convenções deste planejamento

Para que uma IA consiga distinguir decisões tomadas de ideias ainda não aprovadas, todos os itens utilizarão a seguinte classificação:

- **[GDD]** Requisito ou informação presente no documento original.
- **[ATUALIZADO]** Decisão posterior registrada no próprio GDD, que substitui uma especificação antiga.
- **[DEFINIDO]** Decisão expressa pelo desenvolvedor durante nossas conversas.
- **[PROPOSTA]** Ideia sugerida, ainda não aprovada como funcionalidade definitiva.
- **[PENDENTE]** Informação incompleta, contraditória ou que precisa ser decidida.

Os campos pendentes devem permanecer visivelmente em branco, sem que uma IA tome decisões pelo desenvolvedor.

**Modelo de campo pendente**

Decisão: __________________________________

Pergunta ao desenvolvedor: __________________

O checklist representa o **planejamento**, e não uma confirmação de que determinada funcionalidade já foi programada. O status real de implementação deverá ser conferido no projeto.

---

## 1. Identidade do projeto

- [ ] **Nome:** Incógnita Deck.
- [ ] **Gênero:** jogo educacional de estratégia por turnos.
- [ ] **Subgêneros:** deckbuilding, puzzle matemático e serious game.
- [ ] **Plataforma:** PC.
- [ ] **Modo:** single-player.
- [ ] **Monetização:** gratuito.
- [ ] **Público-alvo:** estudantes do Ensino Fundamental II e Médio, além de professores.
- [ ] **Classificação indicativa planejada:** livre.
- [ ] **Estado documentado:** protótipo.
- [ ] **Tecnologia utilizada:** Godot, conforme conversas anteriores.

### 1.1. Conceito principal [GDD]

O jogador utiliza cartas para construir funções e trajetórias em um plano cartesiano, buscando atingir e derrotar inimigos em coordenadas específicas.

O jogo combina raciocínio matemático, estratégia por turnos, gerenciamento de recursos, escolha de caminhos e construção progressiva de baralho.

### 1.2. Pilares fundamentais [GDD]

- [ ] Criatividade na combinação de cartas.
- [ ] Estratégia na escolha de cartas, ataques e caminhos.
- [ ] Exploração recompensadora, com risco e recompensa.
- [ ] Gerenciamento de energia e efeitos.
- [ ] Controle de área e posicionamento.
- [ ] Aprendizado matemático integrado naturalmente ao combate.

### 1.3. Restrição fundamental de design [DEFINIDO]

**Todos os mundos continuarão utilizando o plano cartesiano como arena principal.**

Não transformar as áreas em ambientes convencionais com movimentação livre, plataformas ou cenários que substituam a mecânica central.

As diferenças entre áreas deverão surgir principalmente de:

- Elementos visuais e desenhos decorativos.
- Inimigos exclusivos ou predominantes.
- Obstáculos posicionados no plano.
- Efeitos especiais aplicados ao combate.
- Regras locais que alteram a interação com trajetórias.

---

## 2. Narrativa, universo e personagens

### 2.1. Contexto narrativo [GDD]

- [ ] O protagonista é um estudante do Ensino Médio.
- [ ] O professor elaborou uma atividade envolvendo álgebra e funções.
- [ ] Os alunos competem entre si utilizando o jogo criado no papel.
- [ ] Os adversários representam desafios concebidos pelos colegas.
- [ ] O melhor aluno enfrentará o professor.
- [ ] O professor atua como chefe final e possui conhecimentos superiores sobre matemática.

A narrativa é secundária em relação à jogabilidade.

### 2.2. Personagens conhecidos [GDD]

- Jogador: estudante protagonista.
- Professor: chefe final.
- Fantasma: inimigo comum.
- Calculadora: inimigo comum.
- Slime: inimigo comum.
- Cubo: inimigo comum.

### 2.3. Novos personagens considerados [DEFINIDO como candidatos]

- Tesoura.
- Régua.
- Diretor.
- Aluno.
- Lápis.

A inclusão na lista de candidatos não significa que suas habilidades, aparência ou classificação já estejam definidas.

- [ ] Nome ou identidade do protagonista: Não necessário.
- [ ] Papel narrativo do diretor: Ser o oponente absoluto final (independente da ordem dos atos).
- [ ] Existência de diálogos ou interações entre personagens: Nenhuma.
- [ ] Chefes intermediários dos novos mundos: Entre um mundo e outro, deve haver um boss (normalmente presente no último nível, exceto o diretor, que está após o último boss no último nível - fora do mapa)
- [ ] A narrativa será ampliada ou permanecerá simples? Simples, não há narrativa, é um jogo sobre aprender funções.

---

## 3. Sistemas fundamentais de combate

### 3.1. Estrutura de turnos [GDD]

- [ ] Iniciar combate.
- [ ] Comprar cartas do baralho.
- [ ] Restaurar energia.
- [ ] Selecionar cartas.
- [ ] Combinar seus efeitos e funções.
- [ ] Exibir preview da trajetória.
- [ ] Permitir cancelar cartas antes da confirmação.
- [ ] Confirmar a ação.
- [ ] Executar o ataque.
- [ ] Aplicar danos e efeitos.
- [ ] Executar as ações inimigas.
- [ ] Verificar vitória ou derrota.
- [ ] Iniciar turno seguinte ou encerrar combate.

### 3.2. Energia [ATUALIZADO]

**Energia padrão atual: 5** (Anteriormente: 3)

**Vida máxima atual: 80 HP** (Anteriormente: 70 HP)

O próprio GDD registra que ambos os valores foram aumentados após testes de balanceamento.

- [ ] Restaurar energia no início de cada turno.
- [ ] Deduzir energia ao utilizar cartas.
- [ ] Impedir uso de cartas sem energia suficiente.
- [ ] Não acumular automaticamente energia restante.

### 3.3. Dano e efeitos [GDD]

- [ ] Dano direto.
- [ ] Escudo.
- [ ] Envenenamento.
- [ ] Cura.
- [ ] Efeitos positivos e negativos.
- [ ] Morte e remoção de inimigos.
- [ ] Atualização de atributos e interface.

**Pendências:**

- [ ] Fórmula atual de dano: __________
- [ ] Duração e acúmulo de escudo: __________
- [ ] Funcionamento exato do veneno: __________
- [ ] Ordem de processamento de efeitos: __________
- [ ] Limites de duração e acúmulo de efeitos: __________

### 3.4. Posicionamento [GDD]

- [ ] Jogador posicionado na origem do plano.
- [ ] Inimigos distribuídos em coordenadas.
- [ ] Cartas determinam a trajetória de ataque.
- [ ] Acertos são identificados por interseções entre trajetória e inimigos.
- [ ] Alguns inimigos podem alterar sua posição durante o combate.

**Pendências:**

- [ ] Limites exatos dos eixos X e Y: Não sei quanto um limite, mas, acredito que 3x a largura e altura da arena.
- [ ] Regras atuais de movimentação inimiga: somente para teleportes ou em habilidades de movimento, elas não se mexem a não ser a flutuação *idle* delas
- [ ] Tamanho da área de colisão dos personagens: O tamanho da arte delas.

---

## 4. Sistema de cartas e deckbuilding

### 4.1. Cartas existentes e documentadas [GDD]

O documento apresenta exemplos de cartas como:

| Categoria | Exemplos |
|---|---|
| Deslocamento horizontal | `+2x`, `-2x` |
| Deslocamento vertical | `+3y`, `-1y`, `+5y` |
| Funções quadráticas | `x²`, `2x²` |
| Funções trigonométricas | `sin(x)` |
| Efeitos | Cura, escudo e veneno |

Os exemplos não constituem um catálogo completo e atualizado do jogo.

### 4.2. Construção de trajetórias [GDD]

- [ ] Selecionar uma ou mais cartas.
- [ ] Acumular os efeitos matemáticos.
- [ ] Atualizar instantaneamente o gráfico.
- [ ] Destacar possíveis acertos.
- [ ] Exibir a função ou composição resultante.
- [ ] Permitir experimentação antes de confirmar.

### 4.3. Recompensas [GDD]

- [ ] Receber opções de cartas após combates.
- [ ] Escolher uma carta para adicionar ao baralho.
- [ ] Utilizar raridade ou critérios de seleção.
- [ ] Permitir aquisição de cartas por eventos.
- [ ] Permitir remoção de cartas por mecanismos específicos.

### 4.4. Compra e descarte

O GDD descreve compra, descarte e reciclagem do baralho. Entretanto, nas decisões pós-GDD, o descarte automático de toda a mão ao finalizar o turno aparece como **funcionalidade em teste**.

- [ ] Confirmar se o descarte automático permanece habilitado.
    Resposta: Desabilitar, ao terminar um turno, mantém todas as cartas nõa jogadas. Porém, ao terminar um turno, ele pode escolher até 2 cartas para descartar sem acontecer nada.
- [ ] Confirmar se cartas não utilizadas são descartadas.
- [ ] Confirmar como funciona o embaralhamento da pilha de descarte.
    Ao acabar as de compras e ele tentar comprar, as cartas de descarte vão, embaralhadas, para o de compra, estilo Slay the Spire.
- [ ] Implementar ou ampliar descarte manual de cartas.
- [ ] Determinar se descarte manual permite comprar substitutas.
- [ ] Determinar limite e custo do descarte manual.

**Regras ainda não especificadas:**

- [ ] Quantidade de descartes manuais por turno: 2 (após fim do turno)
- [ ] Custo em energia: 1, custo base, quanto maior e mais forte o efeito, mais caro, com um limite do máximo de energia.
- [ ] Compra de carta substituta: Não, somente se a carta tiver este efeito
- [ ] Quantidade padrão de cartas na mão: 6, limite de 12
- [ ] Possibilidade de conservar cartas entre turnos: Sim

---

## 5. Novo sistema de projéteis e trajetórias

**Prioridade alta**

**[DEFINIDO]** O objetivo é transformar a trajetória calculada em um percurso efetivamente realizado pelo projétil, com interações acontecendo durante seu movimento.

O GDD já descreve a animação do disparo, mas as novas propostas ampliam seu papel no combate.

### 5.1. Projétil percorrendo a trajetória

- [ ] Criar ou revisar a entidade de projétil.
- [ ] Fazer o projétil seguir o percurso calculado pelas cartas.
- [ ] Detectar colisões ao longo do movimento.
- [ ] Aplicar o efeito correspondente quando o projétil atingir um inimigo.
- [ ] Permitir que um disparo interaja com múltiplos inimigos.
- [ ] Processar colisões na ordem em que ocorrerem.
- [ ] Animar os efeitos conforme o projétil avança.
- [ ] Garantir que o preview represente o disparo real.

### 5.2. Regras do projétil

- [ ] O projétil atravessa todos os inimigos por padrão? Sim, caso eles estejam com um efeito de *Rigidez* o inimigo "come" o projétil
- [ ] Pode atingir o mesmo inimigo mais de uma vez? Sim, toda vez que passar
- [ ] Existe limite de duração ou distância? Não, somente o limite de 3x o tamanho do mapa.
- [ ] O que acontece quando atinge a borda? ela some, caso ela possua algo que faça ela retornar (caso seja o futuro da trajetória, e isso ainda for dentro do mapa, ela retornará e continuará o caminho, caso esteja a mais de 15 segundos passando na tela, o jogador pode "pular animação" para só dar o dano em todo mundo que passaria)
- [ ] A trajetória é percorrida em velocidade fixa? Sim
- [ ] O dano varia conforme as cartas utilizadas? Sim, as cartas podem aumentar o dano e etc.
- [ ] Efeitos de veneno e outros são aplicados por acerto ou por disparo? Por acerto, porém, cada acerto depois do primeiro, adiciona somente +1 veneno invés do valor da carta, o mesmo vale pra outros efeitos.
- [ ] Obstáculos podem destruir o projétil? Sim, depende do obstáculo

### 5.3. Separação conceitual [PROPOSTA]

Seria interessante distinguir três conceitos:

1. **Função matemática:** resultado da composição das cartas.
2. **Trajetória prevista:** percurso calculado, considerando modificadores e elementos da arena.
3. **Projétil:** objeto que percorre a trajetória e aplica efeitos de colisão.

Essa separação permitiria adicionar reflexões, paredes, portais e ricochetes sem precisar reinventar cada função.

---

## 6. Novas cartas de funções matemáticas

### 6.1. Espiral [DEFINIDO como direção desejada]

A intenção é uma carta que crie uma trajetória espiralada, com o projétil percorrendo efetivamente o desenho.

*Exemplo ilustrativo de uma espiral percorrida do centro para fora.*

**Possibilidades:**

- [ ] Espiral crescente a partir da origem.
- [ ] Espiral em torno de uma coordenada.
- [ ] Espiral com número limitado de voltas.
- [ ] Espiral com raio ou velocidade de expansão modificáveis.
- [ ] Espiral combinável com outras cartas.

**Pendências:**

- [ ] Tipo matemático de espiral: Arquimedes
- [ ] Centro inicial: Onde a carta for jogada, ou, o final do alcance da carta, caso este seja o efeito dela.
- [ ] Número de voltas: 10
- [ ] Raio máximo: Tela
- [ ] Custo energético: Depende da carta, pode se basear nas outras
- [ ] Regra de composição com outras funções: Tentar implemnetar ambas ao mesmo tempo, algumas cartas de espiral são "executadas" após o fim da trajetória base, ou seja, ela iria até o fim do trajeto e então começaria, como se lá fosse o ponto 0.

### 6.2. Outras funções candidatas [PROPOSTA]

- [ ] **Circunferência:** trajetória circular ao redor de um ponto.
- [ ] **Senoide:** trajetória oscilatória baseada em seno.
- [ ] **Cossenoide:** trajetória oscilatória baseada em cosseno.
- [ ] **Função modular:** trajetória com mudança brusca de inclinação.
- [ ] **Função cúbica:** curva com possibilidade de alteração de concavidade.
- [ ] **Função exponencial:** crescimento acelerado do valor da função.
- [ ] **Função logarítmica:** crescimento progressivamente mais lento.
- [ ] **Função por partes:** sequência de segmentos com regras diferentes.
- [ ] **Elipse:** trajetória fechada com eixos horizontal e vertical diferentes.
- [ ] **Hipérbole:** trajetória com ramos separados e assíntotas.

Não implementar automaticamente todas essas funções. Elas são candidatas para avaliação, especialmente porque funções fechadas e parametrizadas podem exigir regras de composição diferentes das cartas atuais.

---

## 7. Cartas de modificação de trajetória

*[PROPOSTA] Catálogo inicial para discussão e balanceamento*

Estas cartas não precisam necessariamente criar uma função nova. Elas podem modificar o resultado das demais cartas durante um turno.

| Carta | Efeito sugerido |
|---|---|
| Espelho Vertical | Reflete a trajetória em relação ao eixo Y |
| Espelho Horizontal | Reflete a trajetória em relação ao eixo X |
| Simetria | Cria uma cópia refletida do ataque |
| Ricochete | Permite rebater em uma borda |
| Rebote Superior | Reflete o projétil ao atingir o teto |
| Rebote Inferior | Reflete o projétil ao atingir o chão |
| Rotação | Gira o percurso por um ângulo determinado |
| Translação | Desloca a trajetória no plano |
| Inversão | Inverte o sentido em que o percurso é realizado |
| Duplicação | Cria um segundo projétil |
| Perfuração | Permite atravessar obstáculos que normalmente bloqueariam o projétil |
| Órbita | Acrescenta um trecho circular à trajetória |
| Expansão | Aumenta o alcance ou a região atingida |
| Repetição | Repete uma transformação ou trecho do percurso |
| Corte | Limita ou interrompe o percurso em um ponto |
| Traço Pesado | Aumenta o dano em troca de alcance |

### 7.1. Pontos fundamentais para decidir

- [ ] Modificadores ocupam cartas comuns no baralho? Sim, a não ser que sejam modificadores do mapa
- [ ] Custam energia como as demais? Depende do efeito, normalmente é 1
- [ ] Podem afetar todos os disparos de um turno? Sim, depende da carta
- [ ] Existe limite de modificadores simultâneos? Não
- [ ] A ordem de utilização altera o resultado? Sim
- [ ] É possível combinar diferentes tipos de reflexão? Sim
- [ ] As cartas podem ser melhoradas? Não

### 7.2. Exemplos de combinações a avaliar

- [ ] Parábola + Espelho Horizontal.
- [ ] Reta + Ricochete Superior.
- [ ] Senoide + Duplicação.
- [ ] Espiral + Aumento de Dano.
- [ ] Circunferência + Translação.
- [ ] Função Quadrática + Rotação.
- [ ] Espiral + Espelho posicionado por um inimigo.

**Regra importante:** cada combinação deve ter resultado matematicamente previsível e visualmente compreensível.

---

## 8. Obstáculos e elementos interativos do plano

### 8.1. Espelhos [DEFINIDO como mecânica desejada]

Espelhos podem ser elementos fixos da arena ou objetos colocados por determinados inimigos.

- [ ] Criar obstáculos refletores.
- [ ] Permitir diferentes posições e orientações.
- [ ] Detectar o contato do projétil com o espelho.
- [ ] Aplicar reflexão ao percurso restante.
- [ ] Exibir o resultado no preview.
- [ ] Permitir que inimigos posicionem espelhos.
- [ ] Definir duração e remoção de espelhos.
- [ ] Permitir aproveitamento estratégico de espelhos adversários.

**Pendências:**

- [ ] Orientações permitidas: 8 eixos
- [ ] Quantidade máxima simultânea: 4
- [ ] Duração dos espelhos: Turno
- [ ] Espelhos podem ser destruídos? Não
- [ ] Refletem todos os tipos de trajetória? Sim

### 8.2. Outros obstáculos [PROPOSTA]

| Elemento | Função sugerida |
|---|---|
| Parede | Bloqueia ou interrompe o disparo |
| Barreira apagável | Desaparece após receber determinado efeito |
| Zona de borracha | Interrompe ou enfraquece uma trajetória |
| Portal | Transporta o projétil para outro ponto |
| Zona magnética | Desvia parcialmente o percurso |
| Superfície refletora | Altera direção do projétil |
| Região de amplificação | Aumenta o dano ao atravessá-la |
| Região de redução | Diminui o dano do projétil |
| Obstáculo móvel | Modifica sua posição entre turnos |
| Área de bloqueio | Impede determinadas interações ou efeitos |

### 8.3. Regras comuns

- [ ] Obstáculos são posicionados em coordenadas inteiras? Também, qualquer uma
- [ ] Ocupam pontos, segmentos ou regiões? Pontos e segmentos
- [ ] Podem existir sobre personagens? Não
- [ ] Podem ser afetados por cartas? Sim, cartas de teleporte ou cartas que atravessam ou que quebram obstáculos
- [ ] Persistem após o término do combate? Duram o turno ou o combate (até serem quebradas) caso seja do mapa/nível
- [ ] Possuem prioridade sobre colisões com inimigos? Não, inimigo primeiro

---

## 9. Catálogo consolidado de inimigos

### 9.1. Inimigos documentados originalmente [GDD]

| Inimigo | Características documentadas |
|---|---|
| Fantasma | Inimigo comum; não utiliza veneno |
| Calculadora | Inimigo comum; não utiliza veneno |
| Cubo | Inimigo comum; não utiliza veneno |
| Slime | Inimigo comum |
| Professor | Chefe final; pode atacar, defender, envenenar e teleportar |

As animações de Fantasma, Calculadora, Slime, Cubo e Professor aparecem nas páginas 34 a 37 do GDD.

### 9.2. Novos inimigos mencionados pelo desenvolvedor

- [ ] **Tesoura:** candidata a interromper trajetórias ou realizar ataques duplos.
- [ ] **Régua:** candidata a criar barreiras retas.
- [ ] **Diretor:** candidato a inimigo especial ou chefe intermediário.
- [ ] **Aluno:** candidato a adversário humano básico com diferentes variações.
- [ ] **Lápis:** candidato a desenhar obstáculos ou utilizar ataques simples.

As habilidades acima são propostas. Somente os nomes foram escolhidos pelo desenvolvedor.

### 9.3. Dez inimigos adicionais propostos

| Inimigo | Mecânica sugerida | Papel |
|---|---|---|
| Borracha | Apagar ou interromper trechos do percurso | Controle |
| Apontador | Aumentar o dano de aliados | Suporte |
| Caderno | Criar escudos e absorver ataques | Tanque |
| Cola | Aplicar efeitos negativos ou restrições | Debuff |
| Compasso | Criar regiões circulares ou mudar de coordenada | Mobilidade |
| Relógio | Ataque poderoso após determinado número de turnos | Pressão |
| Espelho | Posicionar segmentos refletores | Controle de trajetória |
| Ímã | Criar zonas de desvio do projétil | Controle espacial |
| Portal | Criar pontos conectados no plano | Controle espacial |
| Transferidor | Alterar ângulos e orientação de obstáculos | Especialista |

### 9.4. Outros inimigos candidatos

- [ ] Giz.
- [ ] Mochila.
- [ ] Livro.
- [ ] Esquadro.
- [ ] Grampeador.
- [ ] Caneta.
- [ ] Marca-texto.
- [ ] Clipe de Papel.
- [ ] Carimbo.
- [ ] Pasta de documentos.

## 10. IA e comportamento dos inimigos

### 10.1. Sistema original [GDD]

O comportamento dos inimigos utiliza probabilidades ponderadas e informações sobre o estado do combate.

Entradas possíveis:

- [ ] Vida do próprio inimigo.
- [ ] Vida do jogador.
- [ ] Vida dos aliados.
- [ ] Ação anterior do jogador.
- [ ] Ações anteriores do inimigo.
- [ ] Estado geral do confronto.

Ações:

- [ ] Atacar.
- [ ] Defender.
- [ ] Curar.
- [ ] Aplicar veneno.
- [ ] Proteger aliados.
- [ ] Executar habilidade específica.

Estados descritos:

- [ ] Idle.
- [ ] Attacking.
- [ ] Taking Damage.
- [ ] Death.

O GDD apresenta fluxos para escolha de ação, suporte e reação ao dano. A implementação exata deverá ser conferida no projeto atual.

### 10.2. Expansões de comportamento [PROPOSTA]

- [ ] Inimigos capazes de criar obstáculos.
- [ ] Inimigos capazes de remover obstáculos.
- [ ] Inimigos que alteram suas coordenadas estrategicamente.
- [ ] Inimigos que favorecem outros inimigos.
- [ ] Inimigos que alteram regras do plano.
- [ ] Inimigos que executam ataques periódicos.
- [ ] Inimigos que reagem ao posicionamento de espelhos.
- [ ] Inimigos conhecem a trajetória prevista do jogador? Não
- [ ] Inimigos reagem apenas após o disparo? No turno deles
- [ ] Existe indicação prévia da próxima ação inimiga? Sim, implementar
- [ ] Inimigos podem bloquear regiões inteiras? Não, somente segmentos ou pontos
- [ ] Habilidades têm tempos de recarga? Não, somente o turno.

---

## 11. Mundos, áreas e variações do plano cartesiano

**[GDD + DEFINIDO]** A campanha planejada possui três mundos, sendo o último concluído com a derrota do professor.

O documento pós-GDD registra que o protótipo possui sete etapas por tentativa e prevê acrescentar dois mapas, totalizando três.

O GDD também utiliza o nome **Fundamentos** para o Mundo 1 em um exemplo de gameplay. Os demais nomes não estão fechados.

### 11.1. Direção visual definida

- [ ] Preservar a grade cartesiana.
- [ ] Preservar os eixos X e Y.
- [ ] Preservar a leitura das coordenadas.
- [ ] Manter as cartas como principal forma de interação com o plano.
- [ ] Diferenciar mundos com desenhos de fundo, efeitos e elementos interativos.
- [ ] Evitar decoração que dificulte a visualização das funções.

### 11.2. Três mundos propostos

**Mundo 1: Fundamentos / Plano Limpo**

Introduz funções, cartas, energia, inimigos comuns e construção do baralho.

Visual: papel quadriculado, contas e pequenos rabiscos. Mecânica predominante: trajetórias diretas e posicionamento.

Inimigos candidatos: Aluno, Lápis, Cubo, Slime, Calculadora e Borracha.

**Mundo 2: Rascunhos / Interferências** 

Introduz obstáculos, espelhos, barreiras e inimigos que modificam o ambiente.

Visual: rasuras, linhas mais fortes e construções geométricas. Mecânica predominante: manipulação de trajetórias.

Inimigos candidatos: Régua, Tesoura, Espelho, Compasso, Caderno e Apontador.

**Mundo 3: Correção / Prova Final** 

Combina as mecânicas anteriores em confrontos mais complexos.

Visual: marcações de correção, anotações em vermelho e funções complexas. Mecânica predominante: domínio e combinação das regras.

Inimigos candidatos: Diretor, Transferidor, Relógio, Ímã, Portal e inimigos anteriores.

Chefe final: Professor.

### 11.3. Outras áreas temáticas candidatas

Estas alternativas podem representar subdivisões de um mundo, variações de arena ou conteúdo futuro. Não significam que a campanha terá mais de três mundos. (O nível pode ser um deste)

| Área | Diferencial visual | Regra sugerida |
|---|---|---|
| Sala de Aula | Caderno simples | Sem regra especial |
| Plano Rabiscado | Riscos e anotações | Barreiras fixas |
| Plano Espelhado | Reflexos e simetrias | Espelhos fixos |
| Caderno Amassado | Dobras no papel | Regiões de desvio |
| Folha Rasurada | Áreas apagadas | Zonas de interrupção |
| Papel Recortado | Bordas e recortes | Segmentos bloqueados |
| Plano Corrigido | Marcações vermelhas | Modificadores de trajetória |
| Prova Final | Questões e correções | Combinação de efeitos |

Outros temas discutidos, como biblioteca, laboratório, sala de artes e quadra, podem ser usados como **motivos visuais** dentro do plano, sem transformar o combate em outro tipo de cenário.

- [ ] Nome oficial do Mundo 1: O plano cartesiano
- [ ] Nome oficial do Mundo 2: Sala de Aula
- [ ] Nome oficial do Mundo 3: Diretoria
- [ ] Quantidade de etapas do Mundo 1: 6
- [ ] Quantidade de etapas do Mundo 2: 7
- [ ] Quantidade de etapas do Mundo 3: 8
- [ ] Inimigos exclusivos de cada mundo: 4 ou 5
- [ ] Chefe intermediário do Mundo 1: Professor
- [ ] Chefe intermediário do Mundo 2: Alunos 
- [ ] Chefe do Mundo 3: Diretor 
- [ ] Chefe final após tudo: ENEM (Exame Nacional do Ensino Médio) 
- [ ] Regras fixas ou aleatórias por arena: Sim, mas caso elas tenham, deve aparecer no mapa.
- [ ] Frequência de obstáculos fixos: Depende do efeito do nível/mapa
- [ ] Possibilidade de reutilizar áreas em diferentes mundos: Sim, nada é absoluto

---

## 12. Progressão, campanha e mapa de nós

### 12.1. Mapa ramificado [GDD]

- [ ] Gerar caminhos ramificados.
- [ ] Permitir escolha entre nós acessíveis.
- [ ] Identificar o tipo de encontro pelo ícone.
- [ ] Marcar nós concluídos.
- [ ] Impedir seleção de nós não conectados.
- [ ] Fazer caminhos convergirem para chefes.
- [ ] Preservar vida e baralho durante a tentativa.
- [ ] Reiniciar a run após derrota.

### 12.2. Tipos de nós

| Tipo | Planejamento |
|---|---|
| Combate comum | Enfrentar inimigos e obter recompensas |
| Elite | Combate mais difícil e recompensa superior |
| Descanso | Recuperação e futuras opções adicionais |
| Evento | Escolhas e acontecimentos aleatórios |
| Recompensa | Aquisição de cartas ou outros benefícios |
| Chefe | Confronto principal do mundo |

### 12.3. Elites [GDD, implementação futura]

- [ ] Criar ou revisar classificação Elite.
- [ ] Aumentar dificuldade dos confrontos.
- [ ] Oferecer recompensas de maior poder ou raridade.
- [ ] Diferenciar visualmente o nó Elite.
- [ ] Definir critérios para geração no mapa.

**Pendências:**

- [ ] Elites possuem versões próprias de inimigos? Sim
- [ ] Modificam atributos ou habilidades? Não
- [ ] Garantem uma carta rara? Sim

### 12.4. Descanso [GDD, implementação futura]

O descanso atual registrado no GDD recupera uma porcentagem fixa da vida. A expansão planejada adiciona escolhas.

- [ ] Recuperar vida.
- [ ] Remover uma carta do baralho.
- [ ] Melhorar uma carta.
- [ ] Criar interface de seleção de benefício.
- [ ] Aplicar somente a opção escolhida.

**Pendências:**

- [ ] Percentual de cura: 40%
- [ ] Quantidade de cartas removíveis: 1

### 12.5. Eventos aleatórios [GDD, implementação futura]

- [ ] Criar estrutura de eventos.
- [ ] Permitir eventos que iniciem combates.
- [ ] Permitir recompensas sem combate.
- [ ] Permitir escolhas com benefícios ou penalidades.
- [ ] Criar eventos com diferentes resultados.
- [ ] Exibir consequências de escolhas quando apropriado.

**Exemplos propostos:**

- **Folha Rasgada:** remover uma carta ou receber alguma penalidade.
- **Resposta Correta:** resolver um desafio opcional por recompensa.
- **Cola na Prova:** obter uma vantagem com consequência negativa.
- **Caderno Emprestado:** trocar uma carta por outra.
- **Correção Surpresa:** melhorar ou modificar cartas.
- **Desafio do Monitor:** enfrentar um combate opcional mais difícil.

Esses eventos ainda não estão aprovados.

### 12.6. Progressão de dificuldade

- [ ] A dificuldade aumenta somente pela força inimiga? A dificuldade é a remoção dos símbolos e o escalonamento dos inimigos conforme o jogo passa.
- [ ] Áreas introduzem novas mecânicas gradualmente? Sim
- [ ] O jogador pode rever mundos anteriores? Não
- [ ] O baralho é preservado entre mundos? Sim

---

## 13. Interfaces, telas e experiência do usuário

### 13.1. Interface de combate [ATUALIZADO]

O projeto passou por mudanças de interface após a versão inicial do GDD.

**Alterações registradas:**

- O painel lateral de inimigos foi removido.
- Informações aparecem ao passar o mouse sobre os inimigos.
- A energia foi movida para a parte inferior esquerda.
- O turno deixou de aparecer constantemente e passou a ser consultado pela pausa.
- O veneno possui indicação visível sem necessidade de passar o mouse.

**Checklist de revisão:**

- [ ] Conferir tooltip dos inimigos.
- [ ] Conferir vida, escudo e efeitos.
- [ ] Conferir indicador de energia atual.
- [ ] Conferir legibilidade das cartas.
- [ ] Conferir visualização de custos.
- [ ] Conferir preview da função.
- [ ] Conferir feedback de acerto.
- [ ] Conferir feedback de efeitos negativos.
- [ ] Conferir clareza das informações do turno.

### 13.2. Interface para novas mecânicas [PROPOSTA]

- [ ] Preview de ricochetes.
- [ ] Visualização de espelhos.
- [ ] Indicadores de objetos interativos.
- [ ] Feedback de transformação da trajetória.
- [ ] Destaque dos inimigos que serão atingidos.
- [ ] Indicação de inimigos atingidos múltiplas vezes.
- [ ] Diferenciação visual entre trajetória original e modificada.
- [ ] Exibição clara de cartas de efeitos temporários.
- [ ] Indicador de descarte manual disponível.

### 13.3. Telas documentadas [GDD]

- [ ] Menu principal: Jogar, Continuar, Configurações, Créditos.
- [ ] Mapa de progressão: nós, caminhos e vida.
- [ ] Combate: plano, mão, energia, personagens e ações.
- [ ] Recompensa: escolha entre cartas.
- [ ] Visualização do deck: pilhas e cartas disponíveis.
- [ ] Pausa: continuar, opções e abandonar run.
- [ ] Game Over: progresso alcançado e reinício.
- [ ] Vitória: resumo da run e opções de retorno.
- [ ] Descanso: cura e futuras opções adicionais.
- [ ] Eventos: interface ainda a especificar.

### 13.4. Controles [GDD + implementação futura]

Atalhos especificados originalmente:

| Controle | Ação prevista |
|---|---|
| Mouse | Seleção e interação principal |
| E ou Espaço | Confirmar ação ou turno |
| TAB | Visualizar baralho |
| CTRL | Revisar cartas utilizadas no turno |
| ESC | Pausar o jogo |

O pós-GDD registra que o mouse ainda é o principal meio de interação e que existe intenção de expandir o suporte ao teclado.

**Pendências:**

- [ ] Confirmar atalhos já implementados: __________
- [ ] Definir atalhos para seleção de cartas: __________
- [ ] Definir atalho para descarte: __________
- [ ] Permitir remapeamento de teclas? __________
- [ ] Suporte a controle/gamepad? __________

---

## 14. Direção de arte, animações e áudio

### 14.1. Direção de arte [GDD]

- [ ] Estética doodle, com aparência de desenho feito à mão.
- [ ] Predominância de preto e branco.
- [ ] Uso restrito de cores para informações importantes.
- [ ] Verde para efeitos positivos.
- [ ] Vermelho para dano e situações negativas.
- [ ] Personagens simples e expressivos.
- [ ] Cenários semelhantes a papel ou caderno.
- [ ] Interface legível mesmo com múltiplas funções.

O GDD cita referências de animações clássicas e jogos com aparência de desenho, incluindo *Chicory: A Colorful Tale* e *Hidden Through Time*.

### 14.2. Animações previstas [GDD]

**Jogador:**

- [ ] Idle.
- [ ] Escolher carta.
- [ ] Usar carta.
- [ ] Receber dano.
- [ ] Receber cura.
- [ ] Receber dano por veneno.
- [ ] Morrer.

**Inimigos:**

- [ ] Idle.
- [ ] Ataque.
- [ ] Receber dano.
- [ ] Morte.
- [ ] Teleporte do professor.

O GDD especifica durações e quantidades de frames para diversas animações, incluindo animações curtas de aproximadamente 2 a 5 frames e um ciclo de idle de 4 frames.

### 14.3. Novas animações 

- [ ] Projétil percorrendo a função.
- [ ] Colisão entre projétil e inimigo.
- [ ] Reflexão em espelho.
- [ ] Ricochete em borda.
- [ ] Destruição de obstáculos.
- [ ] Colocação de barreira.
- [ ] Apagamento de trecho de trajetória.
- [ ] Ativação de portal.
- [ ] Espiral em movimento.
- [ ] Duplicação de ataque.
- [ ] Descarte manual.
- [ ] Transformação temporária da arena.

### 14.4. Áudio [GDD]

Trilhas originais documentadas:

- [ ] Main Theme: menu e mapa.
- [ ] Combat Theme: combates gerais.
- [ ] Boss Combat Theme: confronto com o professor.

Efeitos sonoros previstos:

- [ ] Ataque.
- [ ] Morte.
- [ ] Cura.
- [ ] Impacto em escudo.
- [ ] Impacto comum.
- [ ] Veneno.
- [ ] Teleporte.

### 14.5. Áudio futuro

- [ ] Som de ricochete.
- [ ] Som de reflexão.
- [ ] Som de papel sendo rasgado.
- [ ] Som de borracha apagando.
- [ ] Som de lápis desenhando.
- [ ] Som de descarte.
- [ ] Som de portal.
- [ ] Efeitos exclusivos de chefes.
- [ ] Variações musicais para os novos mundos.

**Pendências:**

- [ ] Cada mundo terá música própria? Não, use a atual
- [ ] Existirão temas para chefes intermediários? Não, use a do professor
- [ ] Quais sons novos serão produzidos originalmente? Nenhum.

---

## 15. Salvamento, continuidade e estabilidade

### 15.1. Salvamento [GDD, implementação futura]

- [ ] Permitir sair de uma run em andamento.
- [ ] Salvar o estado atual do jogo.
- [ ] Restaurar a run sem perda de progresso.
- [ ] Restaurar vida e energia.
- [ ] Restaurar baralho, mão e pilhas.
- [ ] Restaurar progressão do mapa.
- [ ] Restaurar posições e estados dos inimigos.
- [ ] Restaurar efeitos ativos.
- [ ] Restaurar obstáculos e interações da arena.
- [ ] Restaurar turno e ações relevantes.
- [ ] Salvamento automático ou manual? Ao sair, ao entrar em um nível ou manual.
- [ ] O jogador pode salvar no meio de um combate? Sim (ele retornará no começo do combate, reseta)
- [ ] Será utilizado somente um slot? Só há 1 slot
- [ ] O salvamento é apagado após derrota? Sim
- [ ] Existe botão de reiniciar combate? Não

### 15.3. Testes necessários

- [ ] Validar colisões em trajetórias rápidas.
- [ ] Validar múltiplos alvos em um disparo.
- [ ] Validar reflexões consecutivas.
- [ ] Evitar ciclos infinitos de ricochetes.
- [ ] Validar funções com descontinuidades.
- [ ] Validar trajetórias fechadas e espirais.
- [ ] Garantir coincidência entre preview e disparo.
- [ ] Testar salvamento com efeitos e obstáculos ativos.
- [ ] Testar runs completas em cada mundo.
- [ ] Testar combinações inesperadas de cartas.
- [ ] Avaliar legibilidade em diferentes resoluções.
- [ ] Medir desempenho com muitas interações simultâneas.

---

## 16. Ordem recomendada de desenvolvimento

Este é o roteiro que eu utilizaria para organizar as próximas sessões. As fases são recomendações de execução, não prazos obrigatórios.

### Fase 1: Revisão do estado atual

Comparar o projeto executável com o GDD e registrar o que já existe.

- [ ] Revisar combate e cálculo de funções
- [ ] Conferir energia, vida e efeitos
- [ ] Revisar compra, descarte e recompensas
- [ ] Conferir inimigos e mapa atual
- [ ] Catalogar problemas e funcionalidades incompletas

### Fase 2: Projétil e colisões

Estabelecer a base para que as novas mecânicas interajam com a trajetória.

- [ ] Implementar ou revisar projétil visível
- [ ] Aplicar efeitos ao colidir com inimigos
- [ ] Processar múltiplas colisões em ordem
- [ ] Garantir correspondência com o preview
- [ ] Testar trajetórias e alvos variados

### Fase 3: Gerenciamento de cartas

Consolidar o funcionamento do baralho antes de ampliar as combinações.

- [ ] Definir regras de descarte manual
- [ ] Implementar descarte e possíveis compras substitutas
- [ ] Validar ciclo do deck
- [ ] Implementar ou revisar remoção de cartas
- [ ] Preparar suporte a melhorias de cartas

### Fase 4: Novas trajetórias e modificadores

Expandir opções matemáticas e estratégicas.

- [ ] Definir regras da espiral
- [ ] Implementar e testar espiral
- [ ] Criar carta de espelhamento
- [ ] Criar ricochete em borda
- [ ] Testar combinações de modificadores
- [ ] Avaliar outras funções especiais

### Fase 5: Interações com a arena

Introduzir elementos que modificam os percursos.

- [ ] Criar espelhos fixos
- [ ] Criar barreiras e obstáculos simples
- [ ] Integrar obstáculos ao preview
- [ ] Implementar colocação e remoção de objetos
- [ ] Testar regras de colisão e reflexão

### Fase 6: Inimigos e balanceamento

Transformar as mecânicas em desafios próprios.

- [ ] Definir habilidades dos novos inimigos
- [ ] Implementar inimigos simples
- [ ] Implementar inimigos com obstáculos
- [ ] Criar ou revisar inimigos Elite
- [ ] Planejar chefes intermediários
- [ ] Balancear vida, dano e probabilidades

### Fase 7: Mundos e progressão

Ampliar a campanha mantendo o plano cartesiano.

- [ ] Definir os três mundos
- [ ] Criar identidade visual de cada área
- [ ] Implementar regras especiais de arena
- [ ] Ampliar encontros e caminhos
- [ ] Revisar recompensa de Elites
- [ ] Expandir descanso e eventos

### Fase 8: Finalização e polimento

Integrar sistemas, completar a experiência e testar.

- [ ] Expandir controles de teclado
- [ ] Implementar salvamento e retomada
- [ ] Revisar menus e HUD
- [ ] Finalizar animações e áudio
- [ ] Testar campanhas completas
- [ ] Atualizar GDD e documentação técnica

---

## 17. Pontos do GDD que precisam ser revisados

Algumas partes do documento descrevem versões anteriores do jogo ou apresentam diferenças que merecem esclarecimento antes de implementar novas funcionalidades.

| Assunto | Situação identificada | Ação |
|---|---|---|
| Energia | 3 inicialmente, posteriormente 5 | Usar 5 como referência atual |
| Vida máxima | 70 inicialmente, posteriormente 80 | Usar 80 como referência atual |
| Descarte | Descarte automático em teste | Confirmar regra definitiva |
| HUD | Painel lateral substituído por tooltips | Priorizar especificação pós-GDD |
| Mão inicial | Exemplo utiliza 5 cartas, mas não define universalmente o limite | Conferir implementação |
| Campanha | Três mundos planejados, sete etapas na versão documentada | Definir estrutura final |
| Nomes dos mundos | Apenas Fundamentos aparece em exemplo | Definir nomes oficiais |
| Recompensas | Trechos mencionam 3 ou 4 opções | Definir quantidade atual |
| Gameplay Example | Algumas combinações e quantidades de cartas não são internamente consistentes | Revisar exemplos matemáticos |
| Inimigos | O GDD possui catálogo antigo, enquanto novos inimigos estão sendo considerados | Atualizar catálogo |
| IA | Documento descreve escolhas probabilísticas e uma árvore de comportamentos | Conferir implementação real |

**Importante:** não tratar o exemplo narrativo do combate no capítulo 17 como especificação matemática definitiva. Algumas trajetórias e sequências de cartas exigem revisão para que não sejam copiadas incorretamente para o código.

---

## 18. Registro das decisões pendentes

Este é o principal conjunto de perguntas para nossa próxima sessão. Não precisam ser todas respondidas de uma vez.

| Código | Decisão necessária |
|---|---|

---

## 19. Instruções para futuras sessões de desenvolvimento com IA

Este bloco define como interpretar e utilizar este planejamento.

1. **Consultar o GDD original como fonte histórica e funcional**, mas priorizar decisões posteriores explicitamente registradas.
2. **Não confundir propostas com funcionalidades aprovadas.** Ideias novas precisam da decisão do desenvolvedor.
3. **Não presumir que uma tarefa está concluída** somente porque aparece no GDD ou neste planejamento.
4. **Verificar o código atual** antes de propor refatorações, correções ou novas implementações.
5. **Preservar o plano cartesiano** como fundamento das arenas, salvo decisão explícita em contrário.
6. **Preservar a natureza educativa** do jogo. Mecânicas novas devem favorecer raciocínio, legibilidade e experimentação.
7. **Não inventar parâmetros de balanceamento.** Valores ausentes devem ser marcados como pendentes.
8. **Dar prioridade à reutilização de sistemas existentes** e à implementação incremental.
9. **Não fornecer implementações completas sem solicitação.** Priorizar explicação, planejamento, esclarecimentos técnicos e revisão de código.
10. **Atualizar a documentação quando uma decisão for tomada**, registrando mudanças e seus impactos sobre sistemas existentes.

---

## 20. Prioridade sugerida para nossa próxima sessão

Eu começaria pela **Fase 1**, revisando o que já existe no jogo. Depois, concentraria a primeira implementação nova no projétil percorrendo sua trajetória.

Isso cria uma base para praticamente todas as ideias mais interessantes que surgiram: espelhos, ricochetes, espirais, obstáculos, inimigos que manipulam a arena e modificadores de disparo.

O maior risco seria implementar cada mecânica separadamente e depois descobrir que elas não funcionam juntas. O melhor caminho é estabelecer primeiro as regras de trajetória, colisão e composição.

**Estado deste documento:** consolidação de planejamento concluída; decisões pendentes identificadas; implementação real ainda não auditada.

Quando retomarmos, podemos usar os códigos `DEC-01` a `DEC-12` como referência para decidir cada assunto, sem precisar rediscutir tudo desde o início.
