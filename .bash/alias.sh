# ~/.bash/alias.sh
source ~/.bash/functions.sh

#==============================================================================
# ---  WehttamSnaps Niri Configuration
# ---  Author: Matthew (Crowdrocker)
# ---  Hardware: AM5 Build - Ryzen 5 9600X, XFX RX 7600 8GB, 16GB DDR5 RAM, 850W PSU
#==============================================================================

## ── VOID LINUX PACKAGE MANAGEMENT (XBPS) ── ##
alias up='sudo xbps-install -Su'                     # Full system update
alias in='sudo xbps-install -S'                      # Install package(s)
alias un='sudo xbps-remove -R'                       # Remove package + unused deps
alias search='xbps-query -Rs'                        # Search remote repos
alias installed='xbps-query -l'                      # List all installed packages
alias pkginfo='xbps-query -R'                        # View package details
alias clean='sudo xbps-remove -Oo && sudo vkpurge rm all' # Clean cache, orphans & old kernels
alias grubup='sudo update-grub'                      # Regenerate Void GRUB config

## ── VOID LINUX SERVICE MANAGEMENT (RUNIT) ── ##
alias svstat='sudo sv status /var/service/*'         # Check status of all enabled services
alias svup='sudo sv up'                              # Start a service (e.g., svup ollama)
alias svdown='sudo sv down'                          # Stop a service
alias svrestart='sudo sv restart'                    # Restart a service
# Enable/disable service helper functions:
sven()   { sudo ln -s "/etc/sv/$1" /var/service/; }
svdis()  { sudo rm "/var/service/$1"; }

## ── SYSTEM & DOTFILES QUICK HOOKS ── ##
alias src='source ~/.bashrc'                         # Fixed path from ~/.bash/.bashrc
alias bashrc='nano ~/.bashrc'
alias aliases='nano ~/.bash/alias.sh'
alias ffconf='nano ~/.local/share/fastfetch/presets/minimal.jsonc'
alias starconf='nano ~/.config/starship.toml'

## ── PIPEWIRE AUDIO (VOID / NON-SYSTEMD FIX) ── ##
alias audio-reset='pkill -x pipewire wireplumber; sleep 1; pipewire & sleep 0.5; wireplumber & sleep 1; ~/.config/niri/scripts/audio-routing.sh gaming'

## list ##
alias ls='eza -T --level=1 --color=always --icons=always --group-directories-first'
alias la='eza -a --icons=always --group-directories-first'
alias ll='eza -l -a --icons=always --no-time --group-directories-first'
alias lst='eza -T --level=2 --color=always --icons=always --group-directories-first'
alias lsf='eza -f -a --color=always --icons=always --group-directories-first'
alias lstd='eza -D -T --level=2 --color=always --icons=always --group-directories-first'
alias tree='eza -T --level=3 --color=always --icons=always --group-directories-first'

alias cat='bat --style header --style snip --style changes --style header'

## grub update ##
alias grubup="sudo update-grub" # Arch, Ubuntu
alias susegrub="sudo grub2-mkconfig -o /boot/grub2/grub.cfg" # openSUSE
alias fedbup="sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg" # Fedora

## navigation ##
alias ..='cd ..'
alias ...='cd ../..'
alias .='cd /'

## system & terminal ##
alias src='source ~/.bash/.bashrc'
alias clr='clear'
alias cls='clear'
alias clar='clear'
alias c='clear'
alias q='exit'
alias nrd='npm run dev'

## file operations ##
alias rm='fn_removal' # remove file & directory safely
alias cp='fn_copy_paste'

## system info ##
alias du='du -sh'
alias mem='fn_resources __memory'
alias disk='fn_resources __disk'

## fzf search ##
alias find='nano $(fzf --preview="bat --color=always {}")'

## editors & IDEs ##
# ── EDITORS & IDES (Nano-First with Vi/Vim Fallbacks) ──
export EDITOR="nano"
export VISUAL="nano"
export SUDO_EDITOR="nano"

# Core quick-launch hooks for your preferred workflow
alias open='nano'
alias nvm='nano .'   # Opens the current directory layout instantly in nano

# Safely manage root-level configurations with your preferred editor
alias snv='sudo -E nano'

# Fallback block: Keep vi/vim shortcuts alive for quick muscle memory
if command -v nvim >/dev/null 2>&1; then
    alias vi='nvim'
    alias vim='nvim'
    alias svi='sudo nvim'
    alias vis='nvim "+set si"'
elif command -v vim >/dev/null 2>&1; then
    alias vi='vim'
    alias vim='vim'
    alias svi='sudo vim'
    alias vis='vim "+set si"'
else
    alias vi='nano'
    alias vim='nano'
fi



## package management ##
alias cu='fn_check_updates'
alias dup='sudo zypper dup -y' # openSUSE
alias update='fn_update'
alias in='fn_install'
alias un='fn_uninstall'

## git ##
alias add='git add .'
alias clone='git clone'
alias cloned='git clone --depth=1'
alias branch='git branch -M main'
alias commit='git commit -m'
alias pushm='git push -u origin main'
alias pusho='git push origin'
alias pull='git pull'
alias info='git_info'

## misc ##
alias nc='clr && neofetch'
alias neofetch='clr && neofetch'
alias ff='clr && fastfetch'
alias sys='btop'
alias clock='tty-clock -c -t -D -s'
alias mat='cmatrix'
alias sddt='sddm-greeter-qt6 --test-mode --theme'

## customizations ##
alias prompt="~/.bash/change_prompt.sh"
alias style="~/.bash/change_style.sh"

## change shell ##
alias cf='chsh -s /usr/bin/fish && clear && exec fish'
alias cz='chsh -s /usr/bin/zsh && clear && exec zsh'

## permissions ##
alias exe='chmod +x'

# ── WEHTTAMSNAPS - NIRI AUDIO PIPELINE ACTIONS ──
alias set-game="~/.config/niri/scripts/audio-routing.sh gaming"
alias set-chill="~/.config/niri/scripts/audio-routing.sh music_only"
alias audio-graph="qpwgraph &"
alias audio-reset="killall wireplumber && systemctl --user restart pipewire wireplumber && sleep 1 && ~/.config/niri/scripts/audio-routing.sh gaming"

# ── SNAPS-OS SHORTCUT UPDATES ──
alias pacgui="ghostty --title=pacgui -e aurgui"
alias projectdir="cat ~/.config/projectdir.state"
alias tipme="~/.config/niri/scripts/tips.sh random"
alias alltips="~/.config/niri/scripts/tips.sh list"

