# Sprites do heroi

- `hero_idle.png`: 1536 x 256, 6 frames.
- `hero_run.png`: 2048 x 256, 8 frames.
- `idle/` e `run/`: frames individuais de 256 x 256, PNG transparente.
- `hero_frames.tres`: recurso SpriteFrames para Godot, idle a 6 FPS e run a 10 FPS.

Cada personagem ocupa aproximadamente 192 pixels de altura. Os recortes usam uma escala unica por sequencia, centralizacao horizontal e base em y=224. A margem transparente evita cortes entre celulas. A versao anterior reduzia o personagem para 64 pixels, perdendo detalhes; esta versao e recortada novamente das fontes em maior resolucao. Use filtro Nearest no Godot. O tamanho visual na cena pode ser ajustado pela escala do AnimatedSprite2D. O recurso hero_frames.tres usa os frames individuais e continua valido com as novas dimensoes. As cenas existentes nao foram alteradas por esta preparacao.

O idle foi recortado do original. A corrida foi revisada com a ferramenta integrada imagegen, usando o idle como referencia principal de detalhe e proporcoes, mantendo dois pes completos no quarto frame. Fontes preservadas em `../Original/`. A corrida final usa `hero_run_matched.png` (ordem: primeira linha da esquerda para a direita, depois segunda linha). A geracao aproximou o acabamento, mas ainda ha variacao de desenho entre as fontes; nao equivale a animacao desenhada manualmente a partir do mesmo modelo.

Reproducao da montagem, na raiz do projeto:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Scripts/prepare_hero_sprites.ps1 -RunSource Assets/Hero/Original/hero_run_matched.png
```

O prompt da revisao final esta em `style_match_prompt.txt`. A comparacao em `idle_run_comparison.png` mostra parado a esquerda e corrida a direita, na resolucao atual. Dimensoes e transparencia verificadas nos 14 frames individuais.

Prompt da correcao anterior do pe (ferramenta integrada, sem API/CLI):

> Correct this running sprite sheet for a game. Keep the same exact hero and style. Deliver EIGHT full-body running frames on a TRANSPARENT background arranged in TWO ROWS OF FOUR, each character centered in its own spacious equal cell. Large transparent margins between EVERY character, no touching. IMPORTANT FRAME FOUR (top row far right): preserve the long rear leg extending diagonally down and left ending in its boot as in original, and ADD the missing second lower leg and boot attached to the bent knee on the right. Two clearly distinct visible brown boots, one behind and one below the raised right knee, separated by transparent space. All other frames retain original running poses. Exactly two legs and two boots for every pose. Consistent head size and body scale. No grid lines, no numbers, no labels, no background, no shadows.

Validacao: dimensoes de ambas as folhas e dos 14 frames conferidas; cantos com alpha zero; inspecao visual das folhas e da correcao. A reproducao dentro do Godot ainda precisa ser avaliada.
