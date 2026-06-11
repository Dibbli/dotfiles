# Dotfiles 👺

My personal configuration for a Wayland desktop on Arch Linux. A tiling, keyboard-driven setup built around [Hyprland](https://hyprland.org/) with a Gruvbox theme.

![Desktop preview](misc/preview.jpg)

## Components

| Tool | Role | Config |
| --- | --- | --- |
| [Hyprland](https://hyprland.org/) | Wayland tiling compositor | [`.config/hypr`](.config/hypr) |
| [Waybar](https://github.com/Alexays/Waybar) | Status bar | [`.config/waybar`](.config/waybar) |
| [Fuzzel](https://codeberg.org/dnkl/fuzzel) | Application launcher | [`.config/fuzzel`](.config/fuzzel) |
| [Dunst](https://dunst-project.org/) | Notification daemon | [`.config/dunst`](.config/dunst) |
| [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal | [`.config/kitty`](.config/kitty) |
| [Neovim](https://neovim.io/) | Editor (Lua config, lazy.nvim) | [`.config/nvim`](.config/nvim) |
| [Zsh](https://www.zsh.org/) | Shell (vi-mode) | [`.zshrc`](.zshrc) |
| [Starship](https://starship.rs/) | Cross-shell prompt | Stock |
| [Lazygit](https://github.com/jesseduffield/lazygit) | Terminal git UI | Stock |
| [uwsm](https://github.com/Vladimir-csp/uwsm) | systemd-managed session | [`.config/uwsm`](.config/uwsm) |

## Highlights

- **Hyprland**: dual-monitor workspaces, VRR, hyprlock screen locking, hyprpaper wallpapers ([`binds.conf`](.config/hypr/binds.conf) for keybindings).
- **Gruvbox**: theming wired into GTK, Qt, Waybar, Kitty, and Neovim.
- **Neovim**: Lua config with a pinned `lazy-lock.json` for reproducible plugin versions.
- **Zsh**: vi-mode editing with `jk` to exit insert mode, smart completion, and a set of [aliases](.bash_aliases).

## Installation

These are personal configs, not an installer. Clone the repo and symlink (or copy) the pieces you want into place.

```sh
git clone https://github.com/Dibbli/dotfiles.git
cd dotfiles

# Example: link a single config
ln -s "$PWD/.config/hypr" ~/.config/hypr
```

Most tools above are available in the Arch repos or the AUR. The Neovim setup will bootstrap its own plugins on first launch via [lazy.nvim](https://github.com/folke/lazy.nvim).

## License

Released under the [GNU GPL v3](LICENSE).
