# kosm_tuios

tuios for kosm: a theme of its own for tuios' terminals and its window manager's chrome.

The app writes the theme whole to `~/.config/tuios/themes/kosm.json` and selects it by setting
`appearance.theme = "kosm"` in `~/.config/tuios/config.toml`, keeping the rest of the config
byte for byte. With the theme's `files = .per_kosmos` the theme is named after the kosmos
instead (`krystallos.dark.json`, `appearance.theme = "krystallos.dark"`), so each kosmos applied
keeps its own; tuios shows the theme's `name` (`Theme.name`), or the kosmos' name when it is null. The key must be in the config already; set `config = null` to leave the config
alone and select the theme yourself (`tuios --theme kosm`). Restart tuios to see a change.

`from(theme)` sets the terminal's foreground and background from white and black (swapped in
light mode), the 8 ANSI colors from the wheel (tuios calls magenta `purple`) and the bright
ones a `lightness.bright` step brighter. The chrome's accent is cyan, its states green, yellow
and red.

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/tuios/themes/{name}.json`; `{name}` is `kosm`, or the kosmos' name with `files = .per_kosmos` |
| `files` | the theme's `files`: `.shared` or `.per_kosmos` |
| `config` | `~/.config/tuios/config.toml`; null leaves it alone |
| `id` | the theme file's name without `.json`: the name `appearance.theme` selects |
| `display_name` | the theme's `name`, or the name kosm applies the kosmos under |
| `colors` | `fg`, `bg`, `cursor`, `selection_bg`, `black` .. `white`, `bright_black` .. `bright_white`; null leaves each to tuios |
| `chrome` | `accent`, `success`, `warning`, `error`, `info`, `surface`; null leaves each to tuios |
