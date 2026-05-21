# Western Survive

**Western Survive** e um prototipo 2D feito em Godot, inspirado em jogos de arena survival, com tema de velho oeste, progressao por upgrades, multiplayer local e fases com regras proprias.

O projeto foi organizado para subir leve no GitHub: entram apenas os arquivos do jogo, scripts, cenas, shaders, testes e documentacao. Builds exportadas, cache local e a engine portatil ficam fora do repositorio.

## Destaques

- Arena survival 2D com ambientacao western.
- 4 fases iniciais: Cidade Fantasma, Forte Quebrado, Canyon Vermelho e Mina Abandonada.
- 1 fase bonus: Trilho do Eclipse.
- 4 personagens jogaveis: Pistoleiro, Xerife, Cacadora e Curandeiro.
- 8 armas base e 4 armas secretas desbloqueaveis.
- Sistema de upgrades ate nivel 5 por arma.
- Multiplayer local para 1 a 4 jogadores.
- Itens de cenario, como alimentos e bombas.
- Mina Abandonada com visao limitada e lampioes.
- Musica gerada por codigo, sem arquivos de audio externos.
- Menu com volume, musica, resolucao, tela cheia, idioma e quantidade de jogadores.

## Desbloqueios

| Condicao | Desbloqueio |
| --- | --- |
| Revolver nivel 5 na Cidade Fantasma | Revolver Dourado |
| Espingarda nivel 5 no Forte Quebrado | Escopeta de Carruagem |
| Rifle nivel 5 no Canyon Vermelho | Lanca-Trilhos |
| Garrafa de Fogo nivel 5 na Mina Abandonada | Lampiao Fantasma |
| Todas as 4 armas secretas liberadas | Trilho do Eclipse |

## Sinergias

| Personagem | Sinergia |
| --- | --- |
| Pistoleiro | Revolver Dourado |
| Xerife | Escopeta de Carruagem |
| Cacadora | Lanca-Trilhos, com rifle inicial |
| Curandeiro | Lampiao Fantasma |

## Controles

- Jogador 1: WASD ou setas.
- Jogador 2: IJKL.
- Jogador 3: TFGH.
- Jogador 4: teclado numerico 8456.
- Controle: analogico esquerdo, um controle por jogador.
- Jogador 1 mira com o mouse.
- Esc pausa o jogo.

As armas base do jogador 1 disparam na direcao do ponteiro do mouse. Jogadores extras miram pela direcao de movimento ou controle. Armas secretas usam mira automatica no inimigo mais proximo.

No multiplayer local, o grupo compartilha XP, upgrades, armas e desbloqueios. A rodada termina quando todos os jogadores caem.

## Como abrir no Godot

1. Instale Godot 4.x.
2. Abra a pasta `project/`.
3. Rode a cena principal:

```text
res://scenes/main.tscn
```

## Estrutura do repositorio

```text
WesternSurvive/
  project/   Projeto Godot versionado
  docs/      Documentacao auxiliar
  tools/     Scripts e utilitarios de apoio
  *.ps1      Launchers e scripts locais
```

Pastas que existem no ambiente local, mas nao entram no Git:

```text
builds/   Builds exportadas
cache/    Cache, preferencias e progresso local
engine/   Godot portatil e arquivos pesados da engine
```

## Smoke test

Com a engine instalada localmente em `engine/`, rode:

```powershell
F:\WesternSurvive\engine\Godot_v4.6.2-stable_win64_console.exe --headless --path F:\WesternSurvive\project --quit-after 4 --fixed-fps 60
```

## Status

Este e um prototipo jogavel em desenvolvimento. O foco atual e validar gameplay, progressao, fases, armas e multiplayer local antes de polir assets finais.
