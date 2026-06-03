# Guia de Desenvolvimento - WesternSurvive no Codex

Ultima consolidacao: 2026-06-03

Este guia mostra a evolucao do projeto ao longo do tempo, com base nas conversas locais do Codex, historico Git e arquivos atuais do projeto.

## Linha do tempo resumida

### Fase 1 - Inicio do prototipo

Conversas relacionadas:

- `Dia 1`
- `Dia 2`

Objetivo:

- criar um jogo estilo arena survival com ambientacao de velho oeste;
- definir uma pasta de trabalho fora do workspace padrao;
- montar o projeto em `F:\WesternSurvive`;
- criar a base jogavel em Godot.

Resultado:

- projeto Godot criado;
- estrutura inicial de scripts, cenas e README;
- personagens, fases, armas, XP, upgrades, inimigos e menu comecaram a existir;
- multiplayer local entrou no escopo.

### Fase 2 - Organizacao local e setup

Arquivos relacionados:

- `F:\WesternSurvive\docs\SETUP.md`
- `F:\WesternSurvive\Run-Game.ps1`
- `F:\WesternSurvive\tools\Run-Godot.ps1`
- `F:\WesternSurvive\Reset-Settings.ps1`
- `F:\WesternSurvive\Reset-Game-Memory.ps1`

Decisoes:

- manter Godot portatil em `engine/`;
- manter cache e progresso em `cache/`;
- manter builds em `builds/`;
- deixar o projeto Godot em `project/`;
- usar scripts PowerShell para abrir, resetar configuracoes e resetar memoria.

### Fase 3 - GitHub e repositorio leve

Conversa relacionada:

- `GitHub/estrutura`
- ID principal: `019e4a64-6938-7032-9803-d99bbddfdb2e`

Objetivo:

- decidir se fazia sentido subir o jogo no GitHub;
- evitar subir engine, cache e builds pesadas;
- criar README publico.

Resultado:

- repositorio inicializado;
- `.gitignore` criado/ajustado;
- `.gitattributes` criado;
- `engine/`, `cache/`, `builds/`, `.godot/` e `export_presets.cfg` ficaram fora do Git;
- README raiz criado;
- remoto configurado depois pelo GitHub Desktop:

```text
https://github.com/Xaxadox/WesternSurvive.git
```

Commits relevantes:

```text
5dac9ef 2026-05-21 Initial Western Survive project
c1968b3 2026-05-21 Add project README
```

### Fase 4 - Refatoracao estrutural

Conversa relacionada:

- `Analisar WesternSurvive`
- ID: `019e4b2a-6dce-7f01-bee0-b22112c10458`

Ponto de partida:

- outra IA sugeriu reduzir verbosidade e melhorar manutencao;
- a analise precisava ser validada contra o codigo real.

Conclusao:

- a direcao geral era valida;
- a execucao deveria ser incremental;
- reduzir linhas nao era o objetivo principal;
- o objetivo real era reduzir responsabilidade concentrada, duplicacao e acoplamento.

Etapas que aparecem no historico Git:

```text
d6a5712 Extract spatial query helpers
6f4cf30 Extract content data registry
7b7ce61 Extract weapon fire module
32b65cc Move pause menu layout to scene
f2630d3 Move level up layout to scene
97691cb Extract procedural music data
23f234f Move start menu layout to scene
e3e3e8c Use registry for weapon firing
```

Resultado pratico:

- `GameData.gd` passou a concentrar dados de conteudo;
- `SpatialUtils.gd` reduziu duplicacao espacial;
- `WeaponFire.gd` separou logica de disparo;
- cenas de UI foram criadas para menu inicial, pausa e level up;
- `MusicData.gd` separou dados musicais.

### Fase 5 - Gameplay, armas, buffs e upgrades

Conversa relacionada:

- `Lista: Buffs, Armas e Upgrades`
- ID: `019e4fde-cc9f-7d42-a076-9fb04b4e4ebe`

Objetivo:

- listar e organizar armas, buffs e upgrades.

Contexto consolidado:

- armas base e secretas existem com progressao ate nivel 5;
- desbloqueios dependem de arma/fase;
- buffs melhoram atributos como vida, cooldown, XP, regeneracao e velocidade conforme dados atuais;
- o sistema de escolhas de upgrade e tratado pelo fluxo de level up no HUD e em `Main.gd`;
- limite atual citado no codigo: `MAX_WEAPON_LEVEL = 5`, `MAX_ACTIVE_WEAPONS = 4`, `MAX_BUFF_LEVEL = 5`, `MAX_ACTIVE_BUFFS = 4`.

Arquivos principais dessa frente:

- `project/scripts/GameData.gd`
- `project/scripts/Main.gd`
- `project/scripts/HUD.gd`
- `project/scripts/weapons/WeaponFire.gd`
- `project/scripts/UpgradeIcon.gd`

### Fase 6 - Imagens e assets visuais

Conversa relacionada:

- `Imagens`
- ID: `019e4c5c-4911-7b03-be4d-34df8fc2c12b`

Objetivo:

- aplicar imagens geradas por IA aos 4 personagens e 2 monstros.

Resultado:

- assets foram adicionados em `project/assets/characters`, `project/assets/enemies`, `project/assets/menu` e `project/assets/stages`;
- spritesheets e imagens originais ficaram em `F:\WesternSurvive\Sprites`;
- menu passou a usar imagens/atlas;
- inimigos e personagens passaram a ter frames e animacoes.

Commits relevantes:

```text
779c2ae Add images
1d43809 Add Sprites
a5008aa Add stage prop sprites
8f1c04c Stabilize sprite animation frames
e98f945 Stabilize player sprite gait selection
702b919 Normalize side-facing character frames
```

### Fase 7 - Musica e audio procedural

Conversa relacionada:

- `Musica`
- ID: `019e4a1b-e460-7b53-add9-fb17da256b9d`

Objetivo:

- criar musica do jogo e depois evoluir para audio procedural mais completo.

Resultado:

- musica por codigo para menu e fases;
- transicoes/fades;
- pulso visual do HUD no beat;
- perfis musicais por fase;
- sketch em LMMS;
- buses de audio;
- ambience procedural;
- stingers;
- sons de armas;
- feedback sonoro de combate;
- cena de teste de audio.

Commits relevantes:

```text
860f25f Add music beat UI pulse
d9014ca Add music fade transitions
97691cb Extract procedural music data
6e8cfd2 Rework procedural stage music
48eba9a Add LMMS music style sketch
eb47c96 Add audio bus routing
1cc8631 Add procedural stage ambience
a5ff000 Add procedural event stingers
9b92be3 Add adaptive music intensity
7c5b6cb Add combat audio feedback
f0b259c Add audio test scene
```

### Fase 8 - Obstaculos, itens e regras de fase

Objetivo:

- dar mais identidade mecanica e visual as fases;
- adicionar interacoes de mundo.

Resultado:

- obstaculos de fase;
- props por ambiente;
- bombas e alimentos;
- colisao de projeteis com paredes/obstaculos;
- Mina Abandonada com visao limitada e lampioes.

Commits relevantes:

```text
2fadeca Add stage obstacles
336b907 Block mine wall projectiles
```

### Fase 9 - Padronizacao de sprites

Conversa relacionada:

- `Padronizar sprites dos personagens`
- ID: `019e8e83-6cae-7ba0-8d2d-e85271b550ae`

Problema observado:

- frames laterais misturavam orientacao visual;
- alguns personagens alternavam entre andar curto e andar largo;
- armas e simbolos sumiam em alguns frames;
- curandeiro/shaman teve instabilidade visual mais evidente.

Relatorio existente:

```text
F:\WesternSurvive\Sprites\RELATORIO DE SPRITES.txt
```

Estado atual:

- a padronizacao foi consolidada no commit `c91b84d Padroniza sprites de personagens`;
- o commit mexeu em sprites do Pistoleiro e do Curandeiro/Shaman;
- tambem ajustou `Enemy.gd`, `GameData.gd`, `Main.gd` e `Player.gd`;
- o repositorio local esta alinhado com `origin/main` depois desse commit;
- os arquivos novos de documentacao devem ser commitados separadamente.

Mudancas principais:

- `Player.gd` e `Enemy.gd` trocaram controle por FPS (`animation_fps`) por ciclo fixo (`sprite_walk_cycle_seconds`);
- os frames em movimento agora sao escolhidos pela posicao proporcional dentro do ciclo de caminhada;
- `GameData.gd` passou a declarar `sprite_walk_cycle_seconds` por personagem;
- `Main.gd` passou a declarar `sprite_walk_cycle_seconds` nos dados visuais dos inimigos;
- `Player.gd` ganhou `sprite_weapon_overlay` para desenhar arma procedural sobre sprites quando necessario;
- a estabilizacao hardcoded de frames dentro de `Player.gd` foi removida, deixando a consistencia depender dos assets normalizados.

Commit relevante:

```text
c91b84d 2026-06-03 Padroniza sprites de personagens
```

Comando para verificar:

```powershell
git -C F:\WesternSurvive status --short --branch
```

## Historico Git completo consolidado

```text
c91b84d 2026-06-03 Padroniza sprites de personagens
f0b259c 2026-06-03 Add audio test scene
7c5b6cb 2026-06-03 Add combat audio feedback
9b92be3 2026-06-03 Add adaptive music intensity
a5ff000 2026-06-03 Add procedural event stingers
1cc8631 2026-06-03 Add procedural stage ambience
eb47c96 2026-06-03 Add audio bus routing
48eba9a 2026-06-03 Add LMMS music style sketch
6e8cfd2 2026-06-03 Rework procedural stage music
702b919 2026-05-22 Normalize side-facing character frames
e8d325b 2026-05-22 Update .ignore
e98f945 2026-05-22 Stabilize player sprite gait selection
8f1c04c 2026-05-22 Stabilize sprite animation frames
a5008aa 2026-05-22 Add stage prop sprites
1d43809 2026-05-22 Add Sprites
c5c20e3 2026-05-21 Add weapon sfx script UID
480b876 2026-05-21 Boost procedural weapon sounds
fb7c547 2026-05-21 Add procedural weapon sounds
779c2ae 2026-05-21 Add images
0f8d0e3 2026-05-21 Add generated script UIDs
336b907 2026-05-21 Block mine wall projectiles
2fadeca 2026-05-21 Add stage obstacles
0a1d0c0 2026-05-21 Limit upgrades and strengthen bombs
84915d4 2026-05-21 Update start menu controls
a5709ba 2026-05-21 Standardize damage handling
23f234f 2026-05-21 Move start menu layout to scene
e3e3e8c 2026-05-21 Use registry for weapon firing
1bf797f 2026-05-21 Translate README.md to English and update content
97691cb 2026-05-21 Extract procedural music data
cd0b433 2026-05-21 Clean music profile schema
860f25f 2026-05-21 Add music beat UI pulse
d9014ca 2026-05-21 Add music fade transitions
f2630d3 2026-05-21 Move level up layout to scene
32b65cc 2026-05-21 Move pause menu layout to scene
7b7ce61 2026-05-21 Extract weapon fire module
6f4cf30 2026-05-21 Extract content data registry
d6a5712 2026-05-21 Extract spatial query helpers
9687c73 2026-05-21 Pause Increment
c1968b3 2026-05-21 Add project README
5dac9ef 2026-05-21 Initial Western Survive project
```

## Regras para continuar o desenvolvimento

1. Sempre checar `git status` antes de editar.
2. Nao sobrescrever alteracoes locais de sprites/scripts sem revisao.
3. Para sprites, trabalhar em commits separados.
4. Para audio, validar com `audio_test.tscn` quando aplicavel.
5. Para gameplay, rodar smoke test headless apos mudancas.
6. Para refatoracao, mexer em uma frente por vez.
7. Para GitHub/build, confirmar que `engine/`, `cache/` e `builds/` continuam ignorados.

## Organizacao recomendada das conversas no Codex

Manter poucas conversas fixas:

```text
WesternSurvive - Geral
WesternSurvive - Gameplay
WesternSurvive - Codigo e Bugs
WesternSurvive - Arte e Sprites
WesternSurvive - Musica e Som
WesternSurvive - GitHub e Build
WesternSurvive - Historico
```

Quando uma conversa crescer demais:

```text
WesternSurvive - Gameplay 02
WesternSurvive - Arte e Sprites 02
```

Ao abrir conversa nova, colar:

```text
Leia F:\WesternSurvive\docs\Contexto_Codex.md.
Foco: [tema].
Nao altere outras frentes sem avisar.
```
