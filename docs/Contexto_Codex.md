# Contexto Codex - WesternSurvive / Gametop

Ultima consolidacao: 2026-06-03

Este arquivo e a memoria operacional do projeto para novas conversas no Codex. Use-o como ponto de partida antes de pedir alteracoes no jogo.

## Escopo

- Projeto no Codex: `Gametop`
- Projeto real do jogo: `F:\WesternSurvive`
- Engine: Godot 4.x
- Genero: arena survival 2D em velho oeste
- Repositorio Git: `https://github.com/Xaxadox/WesternSurvive.git`
- Branch principal: `main`

## Observacao sobre as conversas analisadas

Foram localizadas sessoes locais do Codex relacionadas ao projeto pelos nomes e IDs abaixo:

| Conversa | ID | Tema |
| --- | --- | --- |
| Dia 1 | `019e4705-f005-7e03-b534-71743c8624ed` | inicio do projeto |
| Dia 2 | `019e4a0c-3778-7960-9799-c02384da69f3` | evolucao inicial |
| Musica | `019e4a1b-e460-7b53-add9-fb17da256b9d` | musica procedural |
| GitHub / estrutura | `019e4a64-6938-7032-9803-d99bbddfdb2e` | Git, README, organizacao e contexto |
| Analisar WesternSurvive | `019e4b2a-6dce-7f01-bee0-b22112c10458` | refatoracao estrutural |
| Imagens | `019e4c5c-4911-7b03-be4d-34df8fc2c12b` | aplicacao de imagens aos personagens e monstros |
| Lista: Buffs, Armas e Upgrades | `019e4fde-cc9f-7d42-a076-9fb04b4e4ebe` | catalogo de gameplay |
| Padronizar sprites dos personagens | `019e8e83-6cae-7ba0-8d2d-e85271b550ae` | padronizacao e correcao de sprites |

Limite: as conversas foram consolidadas a partir dos arquivos locais acessiveis do Codex, historico Git, READMEs, docs e codigo atual. Este arquivo nao copia logs completos; ele transforma as conversas em contexto util para desenvolvimento.

## Estado atual do jogo

WesternSurvive e um prototipo jogavel em Godot com:

- 4 fases iniciais: Cidade Fantasma, Forte Quebrado, Canyon Vermelho e Mina Abandonada.
- 1 fase bonus: Trilho do Eclipse.
- 4 personagens: Pistoleiro, Xerife, Cacadora e Curandeiro.
- 8 armas base e 4 armas secretas.
- Upgrades de armas ate nivel 5.
- Buffs/passivos com evolucao propria.
- Multiplayer local de 1 a 4 jogadores.
- XP, level up, escolha de upgrades, desbloqueios e save local.
- Menu inicial, pausa, game over e configuracoes.
- Idiomas: portugues e ingles.
- Musica, ambience, stingers e efeitos sonoros gerados por codigo.
- Assets visuais ja aplicados para personagens, inimigos, menus, fases e props.

## Estrutura relevante

```text
F:\WesternSurvive\
  project\                 Projeto Godot
  project\scripts\         Scripts principais
  project\scenes\          Cenas Godot
  project\assets\          Assets importados no jogo
  project\music\lmms\      Sketch musical LMMS
  docs\                    Documentacao local
  tools\                   Scripts auxiliares
  Sprites\                 Originais, relatorios e material de sprites
  builds\                  Builds geradas, fora do Git
  cache\                   Progresso/config local, fora do Git
  engine\                  Godot portatil, fora do Git
```

## Arquivos centrais

- `project/scripts/Main.gd`: controlador principal de partida, menu, progresso, spawn, armas, upgrades, fases, musica e estado geral.
- `project/scripts/GameData.gd`: dados de personagens, fases, armas, desbloqueios e upgrades.
- `project/scripts/HUD.gd`: interface, menus, selecao, pausa, level up, game over e configuracoes.
- `project/scripts/Player.gd`: movimento, controles, vida, sprites e desenho do jogador.
- `project/scripts/Enemy.gd`: inimigos, alvo, dano, colisao, animacao e sprites.
- `project/scripts/Bullet.gd`: projeteis, colisao, explosao, ricochete e visual.
- `project/scripts/weapons/WeaponFire.gd`: logica de disparo das armas extraida de `Main.gd`.
- `project/scripts/SpatialUtils.gd`: utilitarios espaciais para reduzir duplicacao.
- `project/scripts/CodeMusic.gd`: gerador musical procedural em runtime.
- `project/scripts/MusicData.gd`: perfis musicais por fase.
- `project/scripts/AudioMix.gd`: roteamento de buses de audio.
- `project/scripts/WeaponSfx.gd`: sons procedurais de armas.
- `project/scripts/CombatSfx.gd`: sons de combate.
- `project/scripts/StageAmbience.gd`: ambiencia procedural por fase.
- `project/scripts/StingerSfx.gd`: stingers/eventos musicais.
- `project/scenes/audio_test.tscn`: cena de teste de audio.

## Decisoes tecnicas ja tomadas

- O jogo usa Godot 4.x.
- `engine/`, `cache/` e `builds/` nao devem entrar no Git.
- O projeto versionado principal fica em `F:\WesternSurvive\project`.
- O progresso fica em `F:\WesternSurvive\cache\progress.json`.
- A musica e boa parte dos efeitos sao gerados por codigo, sem depender de arquivos de audio externos.
- A UI foi parcialmente migrada de construcao puramente via codigo para cenas `.tscn`.
- Dados de gameplay foram extraidos para `GameData.gd`.
- Perfis musicais foram extraidos para `MusicData.gd`.
- Logica de disparo foi extraida para `WeaponFire.gd`.
- Funcoes espaciais repetidas foram centralizadas em `SpatialUtils.gd`.
- O GitHub deve receber somente arquivos do jogo, assets necessarios, docs e scripts leves.

## Gameplay consolidado

### Fases

- Cidade Fantasma / Ghost Town
- Forte Quebrado / Broken Fort
- Canyon Vermelho / Red Canyon
- Mina Abandonada / Abandoned Mine
- Trilho do Eclipse / Eclipse Rail, fase bonus

### Personagens

- Pistoleiro / Gunslinger
- Xerife / Sheriff
- Cacadora / Bounty Hunter
- Curandeiro / Healer ou Shaman, conforme dados atuais

### Desbloqueios

- Revolver nivel 5 na Cidade Fantasma libera Revolver Dourado.
- Espingarda nivel 5 no Forte Quebrado libera Escopeta de Carruagem.
- Rifle nivel 5 no Canyon Vermelho libera Lanca-Trilhos.
- Garrafa de Fogo nivel 5 na Mina Abandonada libera Lampiao Fantasma.
- Liberar as 4 armas secretas libera Trilho do Eclipse.

### Multiplayer

- Suporta 1 a 4 jogadores locais.
- Jogador 1: WASD ou setas; mira pelo mouse.
- Jogador 2: IJKL.
- Jogador 3: TFGH.
- Jogador 4: teclado numerico 8456.
- Controles fisicos usam analogico esquerdo.
- Grupo compartilha XP, upgrades, armas e desbloqueios.
- A rodada termina quando todos os jogadores caem.

## Audio

O audio virou uma frente importante do projeto.

Componentes atuais:

- `CodeMusic.gd`: musica procedural por fase, com intensidade adaptativa.
- `MusicData.gd`: perfis por fase, incluindo menu, ghost town, canyon, broken fort, mine e bonus.
- `AudioMix.gd`: buses `Master`, `Music`, `SFX`, `UI` e `Ambience`.
- `StageAmbience.gd`: ambiencia por fase.
- `StingerSfx.gd`: eventos musicais curtos.
- `WeaponSfx.gd`: sons de armas.
- `CombatSfx.gd`: impactos e feedback de combate.
- `project/music/lmms/WesternSurvive_StyleSketch.mmp`: esboco de estilo no LMMS.
- `project/scenes/audio_test.tscn`: cena para testar audio.

## Sprites e assets

Foram adicionadas imagens geradas para personagens, inimigos, menu, fases e props. A frente de sprites teve problemas de consistencia:

- frames laterais de alguns personagens alternavam orientacao visual;
- alguns ciclos misturavam andar curto e andar largo;
- em certos sprites, armas/simbolos sumiam em frames especificos;
- o curandeiro/shaman teve muitas correcoes de frames;
- foi criado relatorio em `F:\WesternSurvive\Sprites\RELATORIO DE SPRITES.txt`.

Estado consolidado em 2026-06-03:

- a padronizacao de sprites foi commitada em `c91b84d Padroniza sprites de personagens`;
- o repositorio local esta alinhado com `origin/main` depois desse commit;
- os docs atuais ainda estao como novos e devem ser commitados separadamente.

Mudancas tecnicas dessa padronizacao:

- sprites do Pistoleiro e principalmente do Curandeiro/Shaman foram ajustados em `project/assets/characters/frames`;
- `Player.gd` passou de `sprite_animation_fps` para `sprite_walk_cycle_seconds`;
- `Enemy.gd` tambem passou a usar `sprite_walk_cycle_seconds` para ciclos de caminhada;
- `GameData.gd` registra `sprite_walk_cycle_seconds` por personagem;
- `Main.gd` registra `sprite_walk_cycle_seconds` para visuais de inimigos, como bandido e fantasma;
- `Player.gd` ganhou `sprite_weapon_overlay`, permitindo desenhar a arma procedural sobre sprite quando necessario;
- a filtragem hardcoded de frames em `Player.gd` foi removida; a consistencia agora deve vir dos assets e dos dados de animacao.

Antes de nova alteracao de sprites, rodar:

```powershell
git -C F:\WesternSurvive status --short --branch
```

## Refatoracao estrutural ja discutida

A analise externa sugeriu:

- extrair dados grandes de scripts;
- migrar UI feita por codigo para cenas;
- aplicar Strategy/polimorfismo nas armas;
- centralizar funcoes espaciais;
- rever desenhos procedurais de icones.

Validacao feita pelo codigo real:

- Direcao geral correta.
- O objetivo nao e reduzir linhas por si so; e reduzir responsabilidade concentrada, duplicacao e dificuldade de manutencao.
- Refatoracao agressiva unica nao e recomendada.
- Melhor caminho e incremental, com teste Godot apos cada etapa.

Parte ja executada:

- dados extraidos para `GameData.gd`;
- musica extraida para `MusicData.gd`;
- UI parcialmente movida para cenas;
- armas extraidas para `WeaponFire.gd`;
- utilitarios espaciais em `SpatialUtils.gd`.

## Git e publicacao

Repositorio remoto:

```text
https://github.com/Xaxadox/WesternSurvive.git
```

Regras:

- manter `engine/`, `cache/`, `builds/` fora do Git;
- conferir `.gitignore` antes de adicionar assets grandes;
- usar commits pequenos por tema;
- preferir branch quando a mudanca puder quebrar gameplay;
- para docs simples, `main` e aceitavel;
- antes de push, verificar status e diff.

## Comandos uteis

Abrir projeto pelo launcher local:

```powershell
F:\WesternSurvive\Run-Game.ps1
```

Smoke test headless:

```powershell
F:\WesternSurvive\engine\Godot_v4.6.2-stable_win64_console.exe --headless --path F:\WesternSurvive\project --quit-after 4 --fixed-fps 60
```

Status Git:

```powershell
git -C F:\WesternSurvive status --short --branch
```

Historico resumido:

```powershell
git -C F:\WesternSurvive log --oneline --date=short --pretty=format:"%h %ad %s"
```

## Como usar este arquivo em novas conversas

Inicio recomendado de prompt:

```text
Leia F:\WesternSurvive\docs\Contexto_Codex.md.
Projeto real: F:\WesternSurvive.
Foco desta conversa: [Gameplay / Codigo e Bugs / Arte e Sprites / Musica e Som / GitHub e Build].
Nao altere outras frentes sem avisar.
```

## Prioridades praticas atuais

1. Validar em jogo a padronizacao de sprites commitada em `c91b84d`.
2. Rodar smoke test Godot apos qualquer nova mudanca em sprites/scripts.
3. Commitar estes documentos em commit separado de codigo/assets.
4. Manter audio procedural e cena de teste documentados.
5. Criar backlog claro para balanceamento, polimento visual e bugs.
6. Evitar novas grandes refatoracoes antes de estabilizar assets e controles.
