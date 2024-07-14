#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/tasksetter

get_controls

PORTDIR="$(cd $(dirname "$0"); pwd)"
GAMEDIR="${PORTDIR}/Half-Life"
cd $GAMEDIR

# Grab text output...
$ESUDO chmod 666 /dev/tty0
printf "\033c" > /dev/tty0

## Load directly into a mod
RUNMOD=

# Install half life binaries / config files
if [[ -f "${GAMEDIR}/binaries/valve_first_run" ]]; then
  if [[ ! -f "${GAMEDIR}/valve/halflife.wad" ]]; then
    echo "No game files found." > ./log.txt
    $ESUDO systemctl restart oga_events &
    exit 1
  fi

  echo "Copying valve binaries/config files." > /dev/tty0 2>&1

  $ESUDO cp -rfv "${GAMEDIR}/binaries/valve" "${GAMEDIR}/" > /dev/tty0 2>&1

  # Mark step as done
  $ESUDO rm -fv "${GAMEDIR}/binaries/valve_first_run" > /dev/tty0 2>&1
fi

# Do bshift install if the files exist
if [[ -f "${GAMEDIR}/bshift/halflife.wad" ]] && [[ -f "${GAMEDIR}/binaries/bshift_first_run" ]]; then

  echo "Copying bshift binaries/config files." > /dev/tty0 2>&1

  $ESUDO cp -rfv "${GAMEDIR}/binaries/bshift" "${GAMEDIR}/" > /dev/tty0 2>&1

  # Make mod run script
  $ESUDO cp -v "${PORTDIR}/Half-Life.sh" "${PORTDIR}/Half-Life Blue Shift.sh" > /dev/tty0 2>&1
  $ESUDO sed -i 's/RUNMOD=/RUNMOD="-game bshift"/' "${PORTDIR}/Half-Life Blue Shift.sh"

  # Mark step as done
  $ESUDO rm -fv "${GAMEDIR}/binaries/bshift_first_run" > /dev/tty0 2>&1
fi

# Do opforce install if the files exist
if [[ -f "${GAMEDIR}/gearbox/OPFOR.WAD" ]] && [[ -f "${GAMEDIR}/binaries/gearbox_first_run" ]]; then

  echo "Copying gearbox binaries/config files." > /dev/tty0 2>&1

  $ESUDO cp -rfv "${GAMEDIR}/binaries/gearbox" "${GAMEDIR}/" > /dev/tty0 2>&1

  # Make mod run script
  $ESUDO cp -v "${PORTDIR}/Half-Life.sh" "${PORTDIR}/Half-Life Opposing Forces.sh" > /dev/tty0 2>&1
  $ESUDO sed -i 's/RUNMOD=/RUNMOD="-game gearbox"/' "${PORTDIR}/Half-Life Opposing Forces.sh"

  # Mark step as done
  $ESUDO rm -fv "${GAMEDIR}/binaries/gearbox_first_run" > /dev/tty0 2>&1
fi

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib32:$GAMEDIR/valve/dlls:$GAMEDIR/valve/cl_dlls"

$GPTOKEYB "xash3d" &
$TASKSET ./xash3d -ref gles2 -fullscreen -console $RUNMOD 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset LD_LIBRARY_PATH
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> /dev/tty1
