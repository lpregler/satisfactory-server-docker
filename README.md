# Satisfactory Experimental Server (Steam Version Only)
## Introduction
Currently Satisfactory does not provide a dedicated game server. Although
the game already provides an awesome experience and I love to tinker with
my factories to my hearts content, I prefer building with some friends.
At the moment we are only able to play whenever the person hosting the game
is online as well (we don't want to send save games around all the time).
When searching for available workarounds, I came across an inspiring
[Reddit article](https://www.reddit.com/r/SatisfactoryGame/comments/m7yek2/satisfactory_dedicated_server_guide/).

Following this article I was in fact able to get a "public" server up and
running. Ease of use in mind I also tried to check out the proposed solution
using `docker`. Unfortunately neither the
[forked Dockerfile](https://github.com/zig-for/satisfactory-docker/blob/main/Dockerfile)
, nor the
[original Dockerfile](https://github.com/Dirtypaws/satisfactory-docker/blob/main/Dockerfile)
worked for me without modifications.

The only reason for me to provide my own version of their inspiring and inventive
approach is for others to have an easier time getting their own server up and running.

## What do you need
To get started you need some root server or VPS (virtual private server).
You do not need an overpowered server for this to work (take this 'with a grain
of salt' because I did only load a very minimal save-game so far). The VPS I used
personally did have the following specs:

| CPU     | RAM  | Storage | Price        |
| ------- | ---- | ------- | ------------ |
| 4 cores | 8 GB | 160 GB  | ~15€ / month |

With `git` and `docker` installed on the server (see
[official instructions](https://docs.docker.com/engine/install/#server)
for more detailed information) you should be good to go.

**Note:** In addition to installing docker I highly encourage you to setup another
user, other than root, and take at least minimal security measures (see example for
[securing a linux server](https://www.digitalocean.com/community/tutorials/an-introduction-to-securing-your-linux-vps)
). Installing and configuring a firewall (e.g.
[The Uncomplicated Firewall - ufw](https://wiki.archlinux.org/index.php/Uncomplicated_Firewall)
) might be a good idea as well. For your Satisfactory Server to be reachable you
need to allow incoming traffic on port `7777/udp`. Most of you should ensure the
following ports to be open:

| Port | Protocol | Used for     | Notes                                                   |
| ---- | -------- | ------------ | ------------------------------------------------------- |
| 22   | TCP      | SSH          | If you use another port for SSH open that port instead  |
| 7777 | UDP      | Satisfactory | I currently do not know how to change the default port  |

Example of adding a user (called *steam*) on an **Ubuntu** server and granting it
`sudo` privileges:
```shell
# create user 'steam'
adduser steam
# add user 'steam' to the 'sudoers' group
adduser steam sudo
```

## Building the docker image
In the following example, I will assume a user (with `sudo` privileges) called
*steam* is used. Simply replace that username with your actual user's name.
Once you cloned this git repository, you should be able to build
the Satisfactory *Server* Docker Image using the provided Dockerfile(s).
```shell
# switch to your user instead of using the root user directly if not already done
su steam
# switch to your user's home directory
cd /home/steam
# clone this git repository
git clone https://github.com/lpregler/satisfactory-server-docker.git
# change into the cloned git repository
cd satisfactory-server-docker
```

### Generate a Steam Guard Code
**Caution** be aware that you have to be careful when using your **Steam password**.
**Do not** unnecessarily **expose it**. I prefer the first option out of the following
two because it will not expose the password to the command history of your terminal.
Nonetheless I assume an active Steam Guard as well. In order to have access to a
valid **Steam Guard Code**, we need to actively trigger the Steam guard first.
This can be done, using the explicit helper Dockerfile called `SteamGuardTriggerDockerfile`.
For this both options apply as well:
1. Update the `ARG`s provided in the `SteamGuardTriggerDockerfile` with your
   personal Steam credentials:
```text
...
ARG user=<PUT_STEAM_USERNAME_HERE>
ARG password=<PUT_STEAM_PASSWORD_HERE>
...
```
Run the following command to build and trigger the Steam Guard (note that the build
is supposed to fail and its only purpose is to generate the Steam Guard Code)
```shell
sudo docker build --tag steam-guard-trigger:1.0.0 --file SteamGuardTriggerDockerfile .
```
2. Provide `build-args` to the command line (obviously you will have to use your
   own Steam credentials):
```shell
sudo docker build --build-arg user=foo --build-arg password=bar --tag steam-guard-trigger:1.0.0 --file SteamGuardTriggerDockerfile .
```

### Build the Docker image of the server (tedious!)
For this step you need to be patient. The build process takes quite some time (for
me it took about 20 minutes). After you have received a **Steam Guard Code**
(probably via mail or mobile app), you need to provide it through one of the following
two options when building the actual Docker image of the server:
1. Update the `ARG`s provided in the `Dockerfile`:
```text
...
ARG guard_code=<PUT_STEAM_GUARD_CODE_HERE>
ARG user=<PUT_STEAM_USERNAME_HERE>
ARG password=<PUT_STEAM_PASSWORD_HERE>
...
```
Run the following command to build the Docker image of the server:
```shell
sudo docker build --tag satisfactory-server:1.0.0 .
```
2. Provide `build-args` to the command line (again use your personal Steam user
   information):
```shell
sudo docker build --build-arg guard_code=42Y24 --build-arg user=foo --build-arg password=bar --tag satisfactory-server:1.0.0 .
```

Once you built your image with one of the two presented options, verify the image
exists by listing your existing docker images:
```shell
sudo docker image ls

REPOSITORY              TAG       IMAGE ID        CREATED           SIZE
satisfactory-server     1.0.0     a56577441eb9    11 minutes ago    19.5GB
...
```

## Usage
With the image ready to use, you can easily start the server using the provided
`docker-compose.yml` file (note you need to
[install `dockercompose`](https://docs.docker.com/compose/install/)
 for this to work). There is one more thing left for you to do before that, though.
You have to prepare some save-game files (e.g. a game you started and saved locally).
```shell
# change back into the root of your user's home directory
cd /home/steam
# create save-game files mounting directory
mkdir -p ./SaveGames/common
# copy the save-game files you want to use into the common directory (e.g. using scp)
# here is an example of a game-save file
ls SaveGames/common
YourFancyLocalSaveGame.sav
# rename the local save-game file(s) to match the Dockerfile configuartion
mv SaveGames/common/YourFancyLocalSaveGame.sav SaveGames/common/ServerSave_autosave_1.sav
# and verify the result
ls SaveGames/common
ServerSave_autosave_1.sav
```

Update the mounted directory in the `docker-compose.yml` file to point to your
actual `SaveGames` directory:
```yaml
    ...
    source: "/home/<PUT_YOUR_USERNAME_HERE>/SaveGames"
    ...
```

### Start the server
Now finally you are able to **start** the Satisfactory server:
```shell
# change back into the cloned git repository
cd satisfactory-server-docker
# start the server using docker-compose
sudo docker-compose up -d
# verify the server is actually running
sudo docker ps

CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS          PORTS                                       NAMES
b3602a5b981b   satisfactory-server:1.0.0   "./proton run ../Sat…"   30 seconds ago   Up 27 seconds   0.0.0.0:7777->7777/udp, :::7777->7777/udp   satisfactory-server-docker_satisfactory-server_1
```

If the server was able to start up successfully, start Satisfactory on your local
machine and open the console. By default the console should open when pressing \`
(*backtick*) on your keyboard (see
[the related wiki page](https://satisfactory.fandom.com/wiki/Console)).
Enter the following command (`open`) with your server's IP into the open console
and your game should automatically connect to the "server" (*example given localhost*):
```shell
open 127.0.0.1
```

### Stop the server
Whenever you want to **stop** the Satisfactory "server", you can do it via
`docker-compose` as well (but keep in mind that only autosaves will be preserved,
wait for a few minutes if you want to make sure your recent in-game progress is
actually saved):
```shell
sudo docker-compose down
```

## Additional notes
I hope these instructions helped you getting started with your very own public
Satfisfactory server. In this section I wanted to add some additional, possibly
useful information as well as known "possible issues".

### Creating a non Experimental Server
If you prefer to play the stable *Early Access* version of Satisfactory instead
of the experimental Beta, you can easily adjust the `Dockerfile`. You simply need
to remove the `--beta experimental` flag from the `steamcmd` install instruction:
```text
...
# install Satisfactory - Early Access (appId = 526870) using steamcmd
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType windows +set_steam_guard_code ${guard_code} +login ${user} ${password} "+app_update 526870" +quit
...
```

### Where to find the save-game files
If you are not aware how to locate your save files it is probably a good idea to
simply check out
[this official Satisfactory tweet](https://twitter.com/satisfactoryaf/status/1123255603063869440)
or the
[related wiki page](https://satisfactory.fandom.com/wiki/Save_files).
Personally I play Satisfactory on a Linux machine, using Steam and Proton with
default settings. For me the save-games are located at:

`/home/<PUT-YOUR-USERNAME-HERE>/.steam/steam/steamapps/compatdata/526870/pfx/drive_c/users/steamuser/Local Settings/Application Data/FactoryGame/Saved/SaveGames/76861198042467360`

Although the last part of this path might be different for you, you should get
an idea where to find your saves.

### Limitations
As far as I know there are some limitations when it comes to playing as a client
instead of hosting a Satisfactory session. According to the
[following reddit comment](https://www.reddit.com/r/satisfactory/comments/e3hmm9/shadow_as_a_dedicated_server_for_satisfactory/f9pg9kh?utm_source=share&utm_medium=web2x&context=3)
it seems you are only able to create vehicle auto-pilot paths as well as train
tracks when actively hosting a session. Unfortunately I cannot verify this myself
because I currently do not have a save with either vehicles or trains.
