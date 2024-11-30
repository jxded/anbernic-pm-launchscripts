# anbernic-pm-launchscripts
These scripts should replace the official portmaster scripts to make the ports run on anbernic's official firmware (Allwinner H700: RG35XX* v20240626+ 64-bit.)
Credits to Portmaster team and @cbepx-me for the scripts. 


you can grab the required files from [Portmaster](http://portmaster.games/games.html) . Please note that there are no copyrighted files being shared, here or at PM. 

# To use:

1. Grab the files for your wished game from portmaster.games
2. Move the files over to roms/PORTS/ folder on your SDcard. 
3. Grab the required .sh file from here and replace the ones from portmaster.

# How to do it manually for most games:
1. Remove or comment(#) line with "GAMEDIR="$PORTDIR/GameName""
2. Add new line "SHDIR=$(dirname "$0")" and next line "GAMEDIR="$SHDIR/GameName"
3. Change "GameName" for real folder with game.

Feel free to pr and add other games. 
