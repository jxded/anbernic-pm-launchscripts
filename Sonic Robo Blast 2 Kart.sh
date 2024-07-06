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

GAMEDIR="$SHDIR/srb2kart"

if [[ $param_device == 'anbernic' ]]; then
    gptk_file="srb2kart.anbernic.gptk"
	if [[ -e $GAMEDIR/.srb2kart/kartconfig.cfg.anbernic ]]; then
		mv -f $GAMEDIR/.srb2kart/kartconfig.cfg.anbernic $GAMEDIR/.srb2kart/kartconfig.cfg	
	fi
else
	gptk_file="srb2kart.gptk"
	if [[ -e $GAMEDIR/.srb2kart/kartconfig.cfg.anbernic ]]; then
		rm -f $GAMEDIR/.srb2kart/kartconfig.cfg.anbernic
	fi
fi

cd $GAMEDIR

$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "srb2kart" -c "./$gptk_file" &
LD_LIBRARY_PATH=./libs:$LD_LIBRARY_PATH SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./srb2kart
$ESUDO kill -9 $(pidof gptokeyb)
