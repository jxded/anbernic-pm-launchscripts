#!/bin/bash

export HOME=/root

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

SHDIR="$(cd $(dirname "$0"); pwd)"

source $controlfolder/control.txt

get_controls

GAMEDIR="$SHDIR/bermuda"
cd $GAMEDIR

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "bs" &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./bs --fullscreen --widescreen=4:3 --datapath="$GAMEDIR/DATA" 2>&1 | tee $GAMEDIR/log.txt
