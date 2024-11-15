#!/bin/bash
# Built from https://github.com/nosro1/re3 (branch miami-sdl2)

PORTNAME="Grand Theft Auto Vice City"
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

source $controlfolder/control.txt
get_controls

CUR_TTY=/dev/tty0
$ESUDO chmod 666 $CUR_TTY

GAMEDIR="/$directory/ports/gtavc"
GAMEDIR="$SHDIR/gtavc"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

if [[ ! -d "$GAMEDIR/data" ]]; then
  echo "Missing game files. Copy original game files to roms/ports/gtavc." > $CUR_TTY
  sleep 5
  $ESUDO systemctl restart oga_events &
  printf "\033c" >> $CUR_TTY
  exit 1
fi

# Check if reVC project files are already installed
# (needs to be done after the game files are copied, since it overwrites certain files)
if [[ -d "$GAMEDIR/reVC-data" ]]; then
  echo "Installing reVC files..." > $CUR_TTY
  cp -rf "$GAMEDIR/reVC-data"/* "$GAMEDIR" && rm -rf "$GAMEDIR/reVC-data"
fi

OPENGL=$(glxinfo | grep "OpenGL version string")
if [ ! -z "${OPENGL}" ]; then
  LIBS=""
  REVC="reVC_gl"
  GAMEPAD=$(cat /sys/class/input/js0/device/name)
  sed -i "/JoystickName/c\JoystickName = ${GAMEPAD}" ${GAMEDIR}/reVC.ini
else
  LIBS="libs"
  REVC="reVC"
fi

cd "$GAMEDIR"
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/${LIBS}":$LD_LIBRARY_PATH
$GPTOKEYB "${REVC}" &

SIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  AUDIODEV=hw:2,0 ./${RE3} 2>&1 | tee log.txt
else


./${REVC} 2>&1 | tee log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> $CUR_TTY
