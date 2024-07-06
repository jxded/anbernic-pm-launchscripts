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
source $controlfolder/tasksetter

get_controls

#gamedir="/$directory/ports/celeste"
gamedir="$SHDIR/celeste"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

gameassembly="Celeste.exe"
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
$ESUDO rm -rf ~/.local/share/Celeste
mkdir -p ~/.local/share
ln -sfv "$gamedir/savedata" ~/.local/share/Celeste

# Remove all the dependencies in favour of system libs - e.g. the included 
# newer version of FNA with patcher included
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll
cp $gamedir/libs/Celeste.exe.config $gamedir/gamedata

# Setup path and other environment variables
export FNA_PATCH="$gamedir/dlls/CelestePatches.dll"
export MONO_PATH="$gamedir/dlls"
export LD_LIBRARY_PATH="$gamedir/libs":"${monodir}/lib":$LD_LIBRARY_PATH
export PATH="$monodir/bin":"$PATH"
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1

# Compress all textures with ASTC codec, bringing massive vram gains
if [[ ! -f "$gamedir/.astc_done" ]]; then
	echo "Optimizing textures..." >> /dev/tty0
	"$gamedir/celeste-repacker" "$gamedir/gamedata/Content/Graphics/" --install >> /dev/tty0
	if [ $? -eq 0 ]; then
		touch "$gamedir/.astc_done"
	fi
fi

# first_time_setup
$GPTOKEYB "mono" &

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 AUDIODEV=hw:2,0 $TASKSET mono Celeste.exe
else
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 $TASKSET mono Celeste.exe
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
$ESUDO umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1
