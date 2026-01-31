#!/bin/bash
export HOME=/root
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

export SDL_AUDIODRIVER=alsa

# PortMaster control folder (stock OS variants)
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source "$controlfolder/control.txt"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Stock-OS safe paths: use script directory
SHDIR="$(cd "$(dirname "$0")" && pwd)"
GAMEDIR="$SHDIR/undertale"
GMLOADER_JSON="$GAMEDIR/gmloader.json"

cd "$GAMEDIR" || exit 1
: > "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# basic perms
$ESUDO chmod 666 /dev/tty1 2>/dev/null || true
$ESUDO chmod 666 /dev/uinput 2>/dev/null || true

export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/lib:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

$ESUDO chmod +x "$GAMEDIR/gmloadernext.aarch64" 2>/dev/null || true

# launch
$GPTOKEYB "gmloadernext.aarch64" -c "undertale.gptk" &
pm_platform_helper "$GAMEDIR/gmloadernext.aarch64"
"$GAMEDIR/gmloadernext.aarch64" -c "$GMLOADER_JSON"

pm_finish
