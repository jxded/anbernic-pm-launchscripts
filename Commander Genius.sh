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

GAMEDIR="$SHDIR/cgenius"

$ESUDO chmod 666 /dev/tty1
$ESUDO rm -rf ~/.CommanderGenius
ln -sfv $GAMEDIR/.CommanderGenius/ ~/
cd $GAMEDIR
$ESUDO $controlfolder/oga_controls CGeniusExe $param_device &
./CGeniusExe 2>&1 | tee $GAMEDIR/log.txt
$ESUDO kill -9 $(pidof oga_controls)
