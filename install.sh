#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROFILE=""
ASSUME_YES=false
USER_NAME="$(id -un)"

usage() {
    cat <<'EOF'
Usage: ./install.sh [--profile niri|umbriel] [--yes]

Run after installing and booting Void Linux (glibc). If --profile is omitted,
the installer asks which desktop configuration to deploy.

Options:
  --profile PROFILE  Install the Niri or Umbriel desktop profile
  --yes              Skip the final confirmation (XBPS/Flatpak still use -y)
  -h, --help         Show this help
EOF
}

fail() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

while (($#)); do
    case "$1" in
        --profile)
            (($# >= 2)) || fail "--profile needs a value"
            PROFILE="$2"
            shift 2
            ;;
        --yes|-y)
            ASSUME_YES=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            fail "unknown option: $1 (see --help)"
            ;;
    esac
done

[[ "$PROFILE" == "" || "$PROFILE" == "niri" || "$PROFILE" == "umbriel" ]] ||
    fail "profile must be 'niri' or 'umbriel'"

[[ "$EUID" -ne 0 ]] || fail "run this script as your regular user, not with sudo"
[[ -r /etc/os-release ]] || fail "cannot identify the operating system"
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == "void" ]] || fail "this installer is intended for Void Linux"
getconf GNU_LIBC_VERSION >/dev/null 2>&1 ||
    fail "this installer requires the glibc edition of Void Linux"
[[ -n "$USER_NAME" ]] || fail "could not determine the target user"
id "$USER_NAME" >/dev/null 2>&1 || fail "target user '$USER_NAME' does not exist"
command -v sudo >/dev/null 2>&1 || fail "sudo is required"
command -v xbps-install >/dev/null 2>&1 || fail "xbps-install is not available"

if [[ -z "$PROFILE" ]]; then
    if [[ ! -t 0 ]]; then
        fail "choose a profile with --profile niri or --profile umbriel"
    fi
    printf 'Choose desktop profile [niri/umbriel]: '
    IFS= read -r PROFILE
    [[ "$PROFILE" == "niri" || "$PROFILE" == "umbriel" ]] ||
        fail "enter either 'niri' or 'umbriel'"
fi

USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
[[ -n "$USER_HOME" && -d "$USER_HOME" ]] ||
    fail "could not find the home directory for '$USER_NAME'"

PACKAGE_FILES=(
    "$REPO_DIR/pkglist/base.txt"
    "$REPO_DIR/pkglist/wayland-desktop.txt"
    "$REPO_DIR/pkglist/audio.txt"
    "$REPO_DIR/pkglist/gaming.txt"
    "$REPO_DIR/pkglist/creative-apps.txt"
    "$REPO_DIR/pkglist/desktop-$PROFILE.txt"
)
FLATPAK_FILE="$REPO_DIR/pkglist/flatpak.txt"

for package_file in "${PACKAGE_FILES[@]}"; do
    [[ -f "$package_file" ]] || fail "missing package list: $package_file"
done
[[ -f "$FLATPAK_FILE" ]] || fail "missing Flatpak list: $FLATPAK_FILE"
[[ -d "$REPO_DIR/.config/$PROFILE" ]] || fail "missing profile config: $REPO_DIR/.config/$PROFILE"
[[ -d "$REPO_DIR/.config/fastfetch" ]] ||
    fail "missing shared Fastfetch config: $REPO_DIR/.config/fastfetch"
if [[ "$PROFILE" == "umbriel" ]]; then
    [[ -f "$REPO_DIR/session/umbriel.desktop" ]] ||
        fail "missing Umbriel session entry: $REPO_DIR/session/umbriel.desktop"
fi

mapfile -t PACKAGES < <(awk '!/^[[:space:]]*#/ && NF { print $1 }' "${PACKAGE_FILES[@]}" | sort -u)
[[ "${#PACKAGES[@]}" -gt 0 ]] || fail "the selected package lists are empty"

printf '\nVoid Linux post-install setup\n'
printf '  Desktop profile: %s\n' "$PROFILE"
printf '  Target user:     %s\n' "$USER_NAME"
printf '  Packages:        %s\n' "${#PACKAGES[@]}"
printf '  Actions: enable nonfree/multilib, update and install packages, enable core runit services,\n'
printf '           disable enabled dhcpcd/wpa_supplicant services, add available desktop groups,\n'
printf '           install listed Flatpaks, and link profile configs.\n\n'

if [[ "$ASSUME_YES" != true ]]; then
    printf 'Review the package lists before continuing. Proceed? [y/N] '
    IFS= read -r answer
    [[ "$answer" == "y" || "$answer" == "Y" ]] || {
        printf 'Cancelled; no changes made.\n'
        exit 0
    }
fi

sudo -v
printf '\n==> Updating Void and enabling nonfree/multilib repositories\n'
sudo xbps-install -Syu
sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sudo xbps-install -Syu

printf '\n==> Installing packages for %s\n' "$PROFILE"
sudo xbps-install -y "${PACKAGES[@]}"
sudo ldconfig

enable_service() {
    local service="$1"
    if [[ -d "/etc/sv/$service" && ! -e "/var/service/$service" && ! -L "/var/service/$service" ]]; then
        sudo ln -s "/etc/sv/$service" "/var/service/$service"
    fi
}

printf '\n==> Enabling runit services\n'
for service in dbus NetworkManager sddm zramen bluetoothd; do
    enable_service "$service"
done
# elogind is installed with the base packages and activated by D-Bus.
if [[ "$PROFILE" == "umbriel" && ! -f /usr/share/wayland-sessions/umbriel.desktop ]]; then
    sudo install -Dm644 "$REPO_DIR/session/umbriel.desktop" \
        /usr/share/wayland-sessions/umbriel.desktop
fi

for service in dhcpcd wpa_supplicant; do
    if [[ -L "/var/service/$service" ]]; then
        printf 'Disabling %s because NetworkManager is enabled\n' "$service"
        sudo rm -- "/var/service/$service"
    fi
done

groups_to_add=()
for group in video render audio network; do
    if getent group "$group" >/dev/null; then
        groups_to_add+=("$group")
    fi
done
if ((${#groups_to_add[@]})); then
    group_csv="$(IFS=,; printf '%s' "${groups_to_add[*]}")"
    sudo usermod -aG "$group_csv" "$USER_NAME"
fi

printf '\n==> Installing user Flatpak applications\n'
flatpak remote-add --user --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
mapfile -t FLATPAKS < <(awk '!/^[[:space:]]*#/ && NF { print $1 }' "$FLATPAK_FILE")
if ((${#FLATPAKS[@]})); then
    flatpak install --user -y flathub "${FLATPAKS[@]}"
fi

backup_dir="$USER_HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
backup_created=false
link_config() {
    local name="$1"
    local source="$REPO_DIR/.config/$name"
    local target="$USER_HOME/.config/$name"

    [[ -d "$source" ]] || fail "missing configuration directory: $source"
    if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
        printf 'Already linked: %s\n' "$target"
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ "$backup_created" != true ]]; then
            mkdir -p "$backup_dir"
            backup_created=true
        fi
        mv -- "$target" "$backup_dir/"
        printf 'Backed up: %s\n' "$target"
    fi
    mkdir -p "$(dirname -- "$target")"
    ln -s "$source" "$target"
    printf 'Linked: %s\n' "$target"
}

printf '\n==> Linking %s and shared Fastfetch configuration\n' "$PROFILE"
link_config "$PROFILE"
link_config fastfetch

printf '\nSetup complete. Reboot to start the selected desktop session and apply group changes.\n'
printf 'At the login screen, select the %s session. Existing configs are in %s if a backup was needed.\n' \
    "$PROFILE" "$backup_dir"
