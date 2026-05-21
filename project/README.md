# Western Survive

Prototipo 2D em Godot inspirado em arena survival, com ambientacao de velho oeste.

## Como abrir

Para jogar direto:

```powershell
F:\WesternSurvive\Run-Game.ps1
```

Ou abra:

```text
F:\WesternSurvive\builds\WesternSurvive.exe
```

Para editar o projeto:

1. Use Godot 4.x.
2. Abra a pasta `F:\WesternSurvive\project`.
3. Rode a cena principal `res://scenes/main.tscn`.

## Conteudo atual

- 4 fases iniciais: Cidade Fantasma, Forte Quebrado, Canyon Vermelho e Mina Abandonada.
- 1 fase bonus: Trilho do Eclipse, liberada ao abrir as 4 armas secretas.
- 4 personagens: Pistoleiro, Xerife, Cacadora e Curandeiro.
- 8 armas base e 4 armas secretas.
- Armas sobem ate nivel 5 e ganham buff maximo ao chegar la.
- Multiplayer local de 1 a 4 jogadores.
- Itens de cenario: alimentos curam, bombas piscam e explodem atingindo jogador e monstros.
- Mina Abandonada com visao limitada ao redor do jogador e lampioes.
- Musica gerada por codigo para menu e para cada fase.

## Desbloqueios

- Revolver nv 5 na Cidade Fantasma libera Revolver Dourado.
- Espingarda nv 5 no Forte Quebrado libera Escopeta de Carruagem.
- Rifle nv 5 no Canyon Vermelho libera Lanca-Trilhos.
- Garrafa de Fogo nv 5 na Mina Abandonada libera Lampiao Fantasma.
- Liberar as 4 armas secretas libera Trilho do Eclipse.

## Sinergias

- Pistoleiro: Revolver Dourado.
- Xerife: Escopeta de Carruagem.
- Cacadora: Lanca-Trilhos, com rifle inicial.
- Curandeiro: Lampiao Fantasma.

## Controles

- Jogador 1: WASD ou setas
- Jogador 2: IJKL
- Jogador 3: TFGH
- Jogador 4: teclado numerico 8456
- Controles: analogico esquerdo, um controle por jogador
- Jogador 1 mira com o mouse.
- Esc: pausa

As armas base do jogador 1 disparam na direcao do ponteiro do mouse. Jogadores extras ainda miram pela direcao de movimento/controle. As armas secretas desbloqueaveis usam mira automatica no inimigo mais proximo.

No multiplayer local, o grupo compartilha XP, upgrades, armas e desbloqueios. A rodada termina quando todos os jogadores caem.

## Menu

- Volume geral.
- Volume da musica.
- Resolucao: 960x540, 1280x720, 1366x768, 1600x900 ou 1920x1080. No modo janela, o jogo limita e centraliza a janela para caber no monitor.
- Tela cheia.
- Idioma: Portugues ou English.
- Jogadores: 1 a 4.

As musicas sao geradas por codigo em `res://scripts/CodeMusic.gd`, sem arquivo de audio externo. A faixa mais simples fica no menu; cada fase tem andamento, baixo, harmonia e melodia proprios.

## Smoke test

```powershell
F:\WesternSurvive\engine\Godot_v4.6.2-stable_win64_console.exe --headless --path F:\WesternSurvive\project --quit-after 4 --fixed-fps 60
```

## Build Windows

O executavel Windows fica em:

```text
F:\WesternSurvive\builds\WesternSurvive.exe
```
