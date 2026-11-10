# kosm_tuios

tuios for kosm: a theme of its own for tuios' terminals and its window manager's chrome.

The app writes the theme whole to `~/.config/tuios/themes/kosm.json` and selects it by setting
`appearance.theme = "kosm"` in `~/.config/tuios/config.toml`, keeping the rest of the config
byte for byte. The key must be in the config already; set `config = null` to leave the config
alone and select the theme yourself (`tuios --theme kosm`). Restart tuios to see a change.

`from(theme)` sets the terminal's foreground and background from white and black (swapped in
light mode), the 8 ANSI colors from the wheel (tuios calls magenta `purple`) and the bright
ones a `lightness.bright` step brighter. The chrome's accent is cyan, its states green, yellow
and red.

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/tuios/themes/kosm.json` |
| `config` | `~/.config/tuios/config.toml`; null leaves it alone |
| `id` | `kosm`: the name `appearance.theme` selects |
| `display_name` | `kosm` |
| `colors` | `fg`, `bg`, `cursor`, `selection_bg`, `black` .. `white`, `bright_black` .. `bright_white`; null leaves each to tuios |
| `chrome` | `accent`, `success`, `warning`, `error`, `info`, `surface`; null leaves each to tuios |
