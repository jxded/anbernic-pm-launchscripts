#!/bin/bash

export HOME=/root

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

SHDIR=$(dirname "$0")

# We source the control.txt file contents here
source $controlfolder/control.txt

# With device_info we can get dynamic device information like resolution, cpu, cfw etc.
#source $controlfolder/device_info.txt

get_controls

#export LIBGL_ALWAYS_SOFTWARE=1

export gameassembly="TMNT.exe"
#export gamedir="/$directory/ports/tmntsr"
export gamedir="$SHDIR/tmntsr"

echo "--directory=$directory---,HOTKEY=$HOTKEY--"

# Untar port files
#if [[ ! -f "${gamedir}/MMLoader.exe" ]]; then
#tar -xf "/emuelec/configs/tmntsr.tar.xz" -C "$directory/PORTS"
#fi

# check if required files are installed
if [[ ! -f "${gamedir}/gamedata/${gameassembly}" ]]; then
    text_viewer -e -w -t "ERROR!" -f 24 -m "TMNT:SR Game Data does not exist on ${gamedir}/gamedata\n\nYou need to provide your own game data from your copy of the game"
    exit 0
fi

cd "$gamedir/gamedata"

# Setup mono
monodir="$HOME/mono"
monofile="$controlfolder/libs/mono-6.12.0.122-aarch64.squashfs"
$ESUDO mkdir -p "$monodir"
$ESUDO umount "$monofile" || true
$ESUDO mount "$monofile" "$monodir"

# Remove all the dependencies in favour of system libs - e.g. the included 
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Setup path and other environment variables
# export FNA_PATCH="$gamedir/dlls/PanzerPaladinPatches.dll"
export MONO_IOMAP=all
export XDG_DATA_HOME=~/.config
export MONO_PATH="$gamedir/dlls":"$gamedir/gamedata":"$gamedir/monomod"
export LD_LIBRARY_PATH="$gamedir/libs":"$monodir/lib":"$LD_LIBRARY_PATH"
export PATH="$monodir/bin":"$PATH"

# Setup savedir
if [ ! -L ${XDG_DATA_HOME}/Tribute\ Games/TMNT ]; then
rm -rf ${XDG_DATA_HOME}/Tribute\ Games/TMNT
mkdir -p ${XDG_DATA_HOME}/Tribute\ Games/
ln -sfv "${gamedir}/savedata" ${XDG_DATA_HOME}/Tribute\ Games/TMNT
fi

# Configure the renderpath
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0

#sha1sum -c "${gamedir}/gamedata/.ver_checksum"
#if [ $? -ne 0 ]; then
#	echo "Checksum fail or unpatched binary found, patching game..." |& tee /dev/tty0
#	rm -f "${gamedir}/gamedata/.astc_done"
#	rm -f "${gamedir}/gamedata/.patch_done"
#fi

if [[ ! -f "${gamedir}/gamedata/.astc_done" ]] || [[ ! -f "${gamedir}/gamedata/.patch_done" ]]; then
	chmod +x ../repack.src ../utils/*
	../progressor \
		--log "../repack.log" \
		--font "../FiraCode-Regular.ttf" \
		--title "First Time Setup" \
		../repack.src

	[[ $? != 0 ]] && exit -1
fi

# Fix for a goof on previous on the previous patcher...
if [[ -f "${gamedir}/gamedata/MONOMODDED_ParisEngine.dll.so" ]]; then
	mv "${gamedir}/gamedata/MONOMODDED_ParisEngine.dll.so" "${gamedir}/gamedata/ParisEngine.dll.so"
	mv "${gamedir}/gamedata/MONOMODDED_${gameassembly}.so" "${gamedir}/gamedata/${gameassembly}.so"
fi

printf "\033c" > /dev/tty0
echo "Loading... Please Wait." > /dev/tty0

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 AUDIODEV=hw:2,0  mono --ffast-math -O=all ../MMLoader.exe MONOMODDED_${gameassembly} |& tee ${gamedir}/log.txt
else
  LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.5 mono --ffast-math -O=all ../MMLoader.exe MONOMODDED_${gameassembly} |& tee ${gamedir}/log.txt
fi

kill -9 $(pidof gptokeyb)
umount "$monodir"

# Disable console
printf "\033c" >> /dev/tty1
