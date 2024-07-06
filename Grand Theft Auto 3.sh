#!/bin/bash
# Built from https://github.com/nosro1/re3 (branch sdl2)

PORTNAME="Grand Theft Auto 3"
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

#GAMEDIR="/$directory/ports/gta3"
GAMEDIR="$SHDIR/gta3"
echo "--directory=$directory---,HOTKEY=$HOTKEY--"

if [[ ! -d "$GAMEDIR/data" ]]; then
  echo "Missing game files. Copy original game files to roms/ports/gta3." > $CUR_TTY
  sleep 5
  $ESUDO systemctl restart oga_events &
  printf "\033c" >> $CUR_TTY
  exit 1
fi

# Check if re3 project files are already installed
# (needs to be done after the game files are copied, since it overwrites certain files)
if [[ -d "$GAMEDIR/re3-data" ]]; then
  echo "Installing re3 files..." > $CUR_TTY
  cp -rf "$GAMEDIR/re3-data"/* "$GAMEDIR" && rm -rf "$GAMEDIR/re3-data"
fi

OPENGL=$(glxinfo | grep "OpenGL version string")
if [ ! -z "${OPENGL}" ]; then
  LIBS=""
  RE3="re3_gl"
  GAMEPAD=$(cat /sys/class/input/js0/device/name)
  sed -i "/JoystickName/c\JoystickName = ${GAMEPAD}" ${GAMEDIR}/re3.ini
else
  LIBS="libs"
  RE3="re3"
fi

cd "$GAMEDIR"
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$GAMEDIR/${LIBS}":$LD_LIBRARY_PATH
$GPTOKEYB "${RE3}" &

DSIPLAY_ID="$(cat /sys/class/power_supply/axp2202-battery/display_id)"
if [[ $DSIPLAY_ID == "1" ]]; then
  AUDIODEV=hw:2,0 ./${RE3} 2>&1 | tee log.txt
else
  ./${RE3} 2>&1 | tee log.txt
fi

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" >> $CUR_TTY
