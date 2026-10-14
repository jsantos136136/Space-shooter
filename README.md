# Space Shooter

Shooter vertical (estilo Galaga/Raiden) feito em Godot 4.7 com GDScript.

## Rodando

1. Abra `D:\Tools\Godot\Godot_v4.7.2-stable_win64.exe`, clique em **Importar** e escolha o `project.godot` desta pasta.
2. Aperte **F5** para jogar (começa na tela de título).
3. Para editar scripts no Cursor: no Godot, `Editor > Configurações do Editor > Editor de Texto > Externo`, marque **Usar Editor Externo** e aponte para o executável do Cursor. A extensão `godot-tools` já está instalada no Cursor e conecta no LSP do Godot (porta 6005) enquanto o editor estiver aberto.

Controles: WASD/Setas movem, Espaço/J atira, Esc/P pausa. Controle (gamepad) também funciona.

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| `assets/` | Sprites, sons e fontes da Kenney (CC0, licenças em `assets/licenses/`), shader de flash e tema da UI |
| `scenes/player/` | Nave do jogador |
| `scenes/enemies/` | `enemy.tscn` base + variantes herdadas (basic, sine, shooter, kamikaze, meteor) e o chefe |
| `scenes/projectiles/` | Tiros do jogador e dos inimigos (mesmo script `bullet.gd`) |
| `scenes/powerups/` | Item que cai (arma, escudo, vida, pontos) |
| `scenes/effects/` | Explosão |
| `scenes/levels/` | `main.tscn` (partida), fundo com parallax, câmera com tremor, gerador de ondas |
| `scenes/ui/` | Título, HUD, pausa, Game Over |
| `scripts/autoload/` | `GameManager` (pontos, vidas, recorde, troca de cena) e `Audio` (efeitos e música) |

Collision layers: 1 player, 2 enemies, 3 player_bullets, 4 enemy_bullets, 5 powerups.

## Ajustes rápidos

- Novo inimigo: no Godot, clique com o direito em `enemy.tscn` > **Nova Cena Herdada**, troque o sprite e os valores no Inspetor. Depois adicione-o em `wave_spawner.gd`.
- Música: coloque um `.ogg` em `assets/audio/music/music.ogg` e ela toca em loop automaticamente.
- Dificuldade: `wave_spawner.gd` (`_difficulty()`, quantidade de grupos, `boss_every`) e os valores exportados de cada inimigo.

## Exportando

Os presets já estão em `export_presets.cfg` (os export templates 4.7.2 já estão instalados). Pelo editor: `Projeto > Exportar`. Ou pela linha de comando:

```powershell
$godot = "D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe"
& $godot --headless --path . --export-release "Windows Desktop" build/windows/SpaceShooter.exe
& $godot --headless --path . --export-release "Web" build/web/index.html
```

Testar a versão Web localmente: `python -m http.server 8060 --directory build/web` e abrir `http://localhost:8060`.

## Publicando no itch.io

1. Crie o projeto em [itch.io/game/new](https://itch.io/game/new), com **Kind of project: HTML**.
2. Compacte o **conteúdo** de `build/web/` (o `index.html` precisa estar na raiz do zip) e envie, marcando **This file will be played in the browser**.
3. Em **Embed options**, defina o tamanho 540 x 960 (ou 405 x 720) e marque **Fullscreen button**.
4. Opcional: envie também um zip de `build/windows/` como download para Windows.

O export Web usa a opção sem threads, então não precisa ativar o "SharedArrayBuffer support" no itch.
