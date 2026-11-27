# ~/.config/fish/config.fish
#==============================================================================
# ---  WehttamSnaps Niri Configuration
# ---  Author: Matthew (Crowdrocker)
# ---  Hardware: AM5 Build - Ryzen 5 9600X, XFX RX 7600 8GB, 16GB DDR5 RAM, 850W PSU
#==============================================================================

# ── ENVIRONMENT VARIABLES ──
set -gx EDITOR nano
set -gx VISUAL nano
set -gx SUDO_EDITOR nano
set -gx ffconfig minimal
set -gx LIBVIRT_DEFAULT_URI "qemu:///system"

fish_add_path -g "$HOME/.local/bin" "$HOME/bin" "$HOME/.opencode/bin"

if status is-interactive
    # No default Fish greeting
    set -g fish_greeting

    # Apply terminal color sequences (Material You from wallpaper)
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Fastfetch startup
    if command -q fastfetch
        if test -f "$HOME/.local/share/fastfetch/presets/$ffconfig.jsonc"
            command fastfetch --config "$HOME/.local/share/fastfetch/presets/$ffconfig.jsonc"
        else
            command fastfetch
        end
    end

    # Custom system cheat sheet MOTD
    if test -x ~/.config/niri/scripts/motd.sh
        ~/.config/niri/scripts/motd.sh
    end

    # Initialize Starship & Zoxide
    if command -q starship
        starship init fish | source
    end

    if command -q zoxide
        zoxide init fish | source
    end

    # ── iNiR & NIRI AUDIO PIPELINE ACTIONS ──
    alias q 'inir run'
    alias set-game '~/.config/niri/scripts/audio-routing.sh gaming'
    alias set-chill '~/.config/niri/scripts/audio-routing.sh music_only'
    alias audio-graph 'qpwgraph &'
    alias audio-reset 'pkill -x pipewire wireplumber; sleep 1; pipewire & sleep 0.5; wireplumber & sleep 1; ~/.config/niri/scripts/audio-routing.sh gaming'

    alias hud-full '~/.config/niri/scripts/mangohud-style.sh full'
    alias hud-fps '~/.config/niri/scripts/mangohud-style.sh minimal'
    alias projectdir 'cat ~/.config/projectdir.state'
    alias tipme '~/.config/niri/scripts/tips.sh random'
    alias alltips '~/.config/niri/scripts/tips.sh list'

    # ── VOID LINUX PACKAGE MANAGEMENT (XBPS) ──
    alias up 'sudo xbps-install -Su'
    alias update 'sudo xbps-install -Su'
    alias in 'sudo xbps-install -Sy'
    alias un 'sudo xbps-remove -Ry'
    alias search 'xbps-query -Rs'
    alias installed 'xbps-query -l'
    alias pkginfo 'xbps-query -R'
    alias clean 'sudo xbps-remove -Oo; and sudo vkpurge rm all'
    alias grubup 'sudo update-grub'

    function cu --description "Check available Void XBPS updates"
        set -l upd (xbps-install -Mun 2>/dev/null | count)
        printf "[ UPDATES ]\n:: You have \e[1;32m%d\e[0m Void updates available\n" $upd
    end

    function ss --description "Interactive Void XBPS package search & install"
        if command -q fzf
            xbps-query -Rs '' | awk '{print $2}' | sed 's/-[0-9].*//' | sort -u | \
                fzf --multi --prompt="Void XBPS > " --preview "xbps-query -R {1}" --preview-window=down:75% | \
                xargs -ro sudo xbps-install -Sy
        else if test (count $argv) -gt 0
            xbps-query -Rs $argv
        else
            echo "Usage: ss <package_name>"
            return 1
        end
    end

    # ── VOID LINUX SERVICE MANAGEMENT (RUNIT) ──
    alias svstat 'sudo sv status /var/service/*'
    alias svup 'sudo sv up'
    alias svdown 'sudo sv down'
    alias svrestart 'sudo sv restart'

    function sven --description "Enable a runit service"
        sudo ln -s "/etc/sv/$argv[1]" /var/service/
    end

    function svdis --description "Disable a runit service"
        sudo rm "/var/service/$argv[1]"
    end

    # ── LISTING (EZA) & CAT (BAT) ──
    if command -q eza
        alias ls 'eza -T --level=1 --color=always --icons=always --group-directories-first'
        alias la 'eza -a --icons=always --group-directories-first'
        alias ll 'eza -l -a --icons=always --no-time --group-directories-first'
        alias lst 'eza -T --level=2 --color=always --icons=always --group-directories-first'
        alias lsf 'eza -f -a --color=always --icons=always --group-directories-first'
        alias lstd 'eza -D -T --level=2 --color=always --icons=always --group-directories-first'
        alias tree 'eza -T --level=3 --color=always --icons=always --group-directories-first'
    end

    if command -q bat
        alias cat 'bat --style header,snip,changes'
    end

    # ── TERMINAL, NAVIGATION & SYSTEM ──
    alias clear "printf '\033[2J\033[3J\033[1;1H'" # fix: kitty scrollback clear
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias clr 'clear'
    alias cls 'clear'
    alias c 'clear'

    alias .. 'cd ..'
    alias ... 'cd ../..'
    alias . 'cd /'

    alias src 'source ~/.config/fish/config.fish'
    alias fishconf 'nano ~/.config/fish/config.fish'
    alias ff 'clr; and fastfetch --config "$HOME/.local/share/fastfetch/presets/$ffconfig.jsonc"'
    alias sys 'btop'
    alias exe 'chmod +x'
    alias snv 'sudo -E nano'
    alias ed 'nano'

    # ── GIT ──
    alias add 'git add .'
    alias clone 'git clone'
    alias cloned 'git clone --depth=1'
    alias branch 'git branch -M main'
    alias commit 'git commit -m'
    alias pushm 'git push -u origin main'
    alias pusho 'git push origin'
    alias pull 'git pull'

    if command -q lazygit
        alias lg 'lazygit'
    end

    # ── CHANGE SHELL ──
    alias cb 'chsh -s /usr/bin/bash; and clr; and exec bash'
    alias cz 'chsh -s /usr/bin/zsh; and clr; and exec zsh'
end
