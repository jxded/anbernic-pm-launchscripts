#!/bin/sh
echo $0 $*
progdir=`dirname "$0"`

RA_CFG=/.config/retroarch/retroarch.cfg
RA_CORE=/mnt/vendor/deep/retro/cores
RA_WORK=/mnt/vendor/deep/retro

#cd $RA_WORK/
HOME=$RA_WORK/ $RA_WORK/retroarch -c $RA_CFG -v -L $RA_CORE/ecwolf_libretro.so "$progdir/Super_3D_Noahs_Ark/n3d.ecwolf"
