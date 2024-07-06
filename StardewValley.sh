#!/bin/bash

export HOME=/root

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "/roms/ports" ]; then
  controlfolder="/roms/ports/PortMaster"
 elif [ -d "/roms2/ports" ]; then
  controlfolder="/roms2/ports/PortMaster"
else
  controlfolder="/storage/roms/ports/PortMaster"
fi

SHDIR=$(dirname "$0")

source $controlfolder/control.txt

get_controls

#gamedir="/$directory/ports/stardewvalley"
gamedir="$SHDIR/stardewvalley"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

cd "$gamedir/gamedata"

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Setup savedir
$ESUDO mkdir -p $HOME/.config
$ESUDO rm -rf $HOME/.config/StardewValley
ln -sfv "$gamedir/savedata" $HOME/.config/StardewValley

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of MonoGame with fixes for SDL2
rm -f System*.dll MonoGame*.dll mscorlib.dll

# Copy the fixed monogame config
cp ../dlls/MonoGame.Framework.dll.config .

# Setup path and other environment variables
export MONOGAME_PATCH="$gamedir/dlls/Patch.dll"
export MONO_PATH="$gamedir/dlls"
export PATH="$monodir/bin":"$PATH"
export LIBGL_ES=2
export LIBGL_GL=21
export LIBGL_FB=4
export SDL_VIDEO_GL_DRIVER="$gamedir/libs/libGL.so.1"
export SDL_VIDEO_EGL_DRIVER="$gamedir/libs/libEGL.so.1"

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  AUDIODEV=hw:2,0  mono StardewValley.exe
else
  mono StardewValley.exe
fi

$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1
