# Setup local

Raiz do projeto:

```text
F:\WesternSurvive
```

Estrutura:

```text
F:\WesternSurvive\
  engine\   Godot portatil e dados self-contained
  project\  Projeto do jogo
  builds\   Builds exportadas
  docs\     Documentacao
  tools\    Scripts auxiliares
  cache\    Cache controlado do projeto
```

Para manter tudo na particao F, coloque o executavel do Godot em `F:\WesternSurvive\engine` e mantenha o arquivo `F:\WesternSurvive\engine\_sc_` nessa mesma pasta.

Use `F:\WesternSurvive\tools\Run-Godot.ps1` para abrir o projeto apontando para a pasta correta.

Godot incluido agora:

```text
F:\WesternSurvive\engine\Godot_v4.6.2-stable_win64.exe
```

Fonte oficial usada: https://godotengine.org/download/archive/4.6.2-stable/

O progresso de desbloqueios fica em:

```text
F:\WesternSurvive\cache\progress.json
```

Esse arquivo tambem fica na particao F.

As preferencias de volume, musica, resolucao e tela cheia sao salvas no mesmo `progress.json`.

Para resetar apenas a janela/volume sem apagar desbloqueios, rode:

```text
F:\WesternSurvive\Reset-Settings.ps1
```

Para apagar toda a memoria do jogo, incluindo desbloqueios, apague:

```text
F:\WesternSurvive\cache\progress.json
```

O multiplayer atual e local, no mesmo PC, para ate 4 jogadores. A selecao de quantidade fica no menu inicial do jogo.

Build Windows:

```text
F:\WesternSurvive\builds\WesternSurvive.exe
```

Launcher:

```text
F:\WesternSurvive\Run-Game.ps1
```
