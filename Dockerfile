FROM cm2network/steamcmd:root

ARG guard_code=<PUT_STEAM_GUARD_CODE_HERE>
ARG user=<PUT_STEAM_USERNAME_HERE>
ARG password=<PUT_STEAM_PASSWORD_HERE>

# add python script for ini configuration from context to image
ADD configure-ini-files.py /home/steam/configure-ini-files.py
# change owner of file to user steam
RUN chown steam:steam /home/steam/configure-ini-files.py
# make python script executable
RUN chmod +x /home/steam/configure-ini-files.py

# install Proton requirements
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install libfreetype6:i386 -y
RUN apt-get install libfreetype6 -y
RUN apt-get install python3 -y

USER steam
WORKDIR /home/steam/steamcmd

# install Proton 5.0 (appId = 1245040) using steamcmd
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType linux +set_steam_guard_code ${guard_code} +login ${user} ${password} "+app_update 1245040" +quit
# install Satisfactory - Experimental (appId = 526870) using steamcmd
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +set_steam_guard_code ${guard_code} +login ${user} ${password} "+app_update 526870 --beta experimental" +quit

# Create compatdata directory used by Proton
RUN mkdir /home/steam/compatdata
RUN touch /home/steam/compatdata/pfx.lock
ENV STEAM_COMPAT_DATA_PATH=/home/steam/compatdata

WORKDIR '/home/steam/Steam/steamapps/common/Proton 5.0'
# Start the game in order to create the ini files
RUN (timeout 20 ./proton run ../Satisfactory/FactoryGame.exe -nosplash -nullrhi -nosound -NoSteamClient; exit 0)

# use the provided python script to configure the relevant ini files in order to force the given map to load
# and adjust multiplayer network settings as suggested by https://satisfactory.fandom.com/wiki/Multiplayer
RUN python3 /home/steam/configure-ini-files.py
# make adjusted ini files readonly to prevent the game to overwrite the configuration
RUN chmod 444 /home/steam/compatdata/pfx/drive_c/users/steamuser/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Engine.ini
RUN chmod 444 /home/steam/compatdata/pfx/drive_c/users/steamuser/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Game.ini
RUN chmod 444 /home/steam/compatdata/pfx/drive_c/users/steamuser/Local\ Settings/Application\ Data/FactoryGame/Saved/Config/WindowsNoEditor/Scalability.ini

# Create Save Game directory which is used for mounting "local" save game data
RUN mkdir /home/steam/compatdata/pfx/drive_c/users/steamuser/Local\ Settings/Application\ Data/FactoryGame/Saved/SaveGames

# Run Satisfactory Experimental via Proton (on Container Startup)
ENTRYPOINT [ "./proton", "run", "../Satisfactory/FactoryGame.exe", "-nosplash", "-nullrhi", "-nosound", "-NoSteamClient" ]
