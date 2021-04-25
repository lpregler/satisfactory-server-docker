#!/usr/bin/env python

configBasePath = "/home/steam/compatdata/pfx/drive_c/users/steamuser/Local Settings/Application Data/FactoryGame/Saved/Config/WindowsNoEditor/"

engineIniFile = configBasePath + "Engine.ini"
engineIniLines = [
    "[/Script/EngineSettings.GameMapsSettings]",
    "GameDefaultMap=/Game/FactoryGame/Map/GameLevel01/Persistent_Level",
    "LocalMapOptions=??sessionName=SatisfactoryServer?Visibility=SV_FriendsOnly?loadgame=SatisfactoryServer_autosave_0?listen?bUseIpSockets?name=Host",
    "",
    "[/Script/Engine.Player]",
    "ConfiguredInternetSpeed=104857600",
    "ConfiguredLanSpeed=104857600",
    "",
    "[/Script/OnlineSubsystemUtils.IpNetDriver]",
    "MaxClientRate=104857600",
    "MaxInternetClientRate=104857600",
    "",
    "[/Script/SocketSubsystemEpic.EpicNetDriver]",
    "MaxClientRate=104857600",
    "MaxInternetClientRate=104857600"
]

gameIniFile = configBasePath + "Game.ini"
gameIniLines = [
    "[/Script/Engine.GameNetworkManager]",
    "TotalNetBandwidth=104857600",
    "MaxDynamicBandwidth=104857600",
    "MinDynamicBandwidth=10485760"
]

scalabilityIniFile = configBasePath + "Scalability.ini"
scalabilityIniLines = [
    "[NetworkQuality@3]",
    "TotalNetBandwidth=104857600",
    "MaxDynamicBandwidth=104857600",
    "MinDynamicBandwidth=10485760"
]


def append_multiple_lines(file_name, lines_to_append):
    # Open the file in append & read mode ('a+')
    with open(file_name, "a+") as file_object:
        append_eol = False
        # Move read cursor to the start of file.
        file_object.seek(0)
        # Check if file is not empty
        data = file_object.read(100)
        if len(data) > 0:
            append_eol = True
        # Iterate over each string in the list
        for line in lines_to_append:
            # If file is not empty then append '\n' before first line for
            # other lines always append '\n' before appending line
            if append_eol:
                file_object.write("\n")
            else:
                append_eol = True
            # Append element at the end of file
            file_object.write(line)


print("Start to process ini file modifications.")
append_multiple_lines(engineIniFile, engineIniLines)
append_multiple_lines(gameIniFile, gameIniLines)
append_multiple_lines(scalabilityIniFile, scalabilityIniLines)
print("Completed processing ini file modifications.")
