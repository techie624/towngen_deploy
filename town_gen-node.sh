#!/usr/bin/env bash
#-----------------------------------------------------------------------------#
### Script Purpose
# This script is the result of creating a container to run a local version
# of a town generator created by Bram van den Heuvel (bram.blmgroep@gmail.com)
# All 
# Official Site: http://town.noordstar.me/
#-----------------------------------------------------------------------------#
### Script Author
# @author: RLPetrie (rlp243@cornell.edu)
#-----------------------------------------------------------------------------#
### Environment Sets

set -e # Abort script at first error, when a command exits with non-zero status
set -u # Attempt to use undefined variable outputs error message, and forces 
# an exit
set -x # xtrace: Similar to -v, but expands commands [to unset and hide docker exec -u gadm $DOCKER_WEB_NAME bash -c "

#-----------------------------------------------------------------------------#
### Time set start

start=$(date +%s.%N)

#-----------------------------------------------------------------------------#
### Variable(s) Set

# Used for logging and timestamps
TAG=$(date +"%Y%m%d_%H%M%S")

# Set for container name to be used
DOCKER_NODE_0="ubuntu-node"

# Set User(s)
USER_0="gygax"

# if set to "askme" the script will prompt for silent input
USER_0_PASS="gary"

# Set root pass 
# if set to "askme" the script will prompt for silent input
ROOT_PASS="tree"

# Set Group(s)
GROUP_0="dnd"

# Set NOPASSWD for sudo
NOPASSWD="$USER_0     ALL=(ALL) NOPASSWD:ALL"

#-----------------------------------------------------------------------------#
### Docker (Ports, Volumes, Names, Networks, etc)

# Container Name (Docker)
DOCKER_CONT_NAME="ubuntu-node"

# Container Hostname (Internal container hostname)
CONT_HOSTNAME="ubuntu-node"

# Host Port
HOST_PORT_0="8080"

# Container Port
CONT_PORT_0="8080"

# Docker Network Name
DOCKER_NETWORK_NAME="dnd-net"

#-----------------------------------------------------------------------------#
### Prompt for silent input

# askes for input but does not echo input for variable [silent]
if [[ $USER_0_PASS = "askme" ]]; then
  read -sp "Please enter $USER_0 password: " OC_GADM_PASSWORD
fi
echo;

if [[ $ROOT_PASS = "askme" ]]; then
  read -sp "Please enter root password: " OC_GADM_PASSWORD
fi
echo;

#-----------------------------------------------------------------------------#
### Create Docker Network and fail silently if one already exists

docker network create $DOCKER_NETWORK_NAME || true;

#-----------------------------------------------------------------------------#
### Container Run

docker run -dti \
--name $DOCKER_CONT_NAME \
-h $CONT_HOSTNAME \
-p $HOST_PORT_0:$CONT_PORT_0 \
--network=$DOCKER_NETWORK_NAME \
--entrypoint /bin/bash \
ubuntu

#-----------------------------------------------------------------------------#
### Docker Network IP

CONT_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $DOCKER_CONT_NAME)

#-----------------------------------------------------------------------------#
### Installs

docker exec $DOCKER_NODE_0 bash -c "
apt update
";

docker exec $DOCKER_NODE_0 bash -c "
apt install -y software-properties-common sudo
";

docker exec $DOCKER_NODE_0 bash -c "
add-apt-repository ppa:deadsnakes/ppa
";

docker exec $DOCKER_NODE_0 bash -c "
apt install -y git vim sudo python3-pip python-pip python3.8 python-flask
";

# Updates default python version used
docker exec $DOCKER_NODE_0 bash -c "
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 10
";

#-----------------------------------------------------------------------------#
### Configuration

docker exec $DOCKER_NODE_0 bash -c "
useradd -m $USER_0
";

docker exec $DOCKER_NODE_0 bash -c "
groupadd $GROUP_0
";

docker exec $DOCKER_NODE_0 bash -c "
usermod -aG $GROUP_0 $USER_0
";

docker exec $DOCKER_NODE_0 bash -c "
usermod -g $GROUP_0 $USER_0
";

docker exec $DOCKER_NODE_0 bash -c "
usermod --shell /bin/bash $USER_0
";

docker exec $DOCKER_NODE_0 bash -c "
usermod -d /home/$USER_0 $USER_0
";

docker exec $DOCKER_NODE_0 bash -c "
echo -e \"$ROOT_PASS\n$ROOT_PASS\" | passwd root
";

docker exec $DOCKER_NODE_0 bash -c "
echo -e \"$USER_0_PASS\n$USER_0_PASS\" | passwd $USER_0
";

docker exec -u $USER_0 $DOCKER_NODE_0 bash -c "
mkdir /home/$USER_0/workspace
";

docker exec $DOCKER_NODE_0 bash -c "
usermod -aG sudo $USER_0 
";

docker exec $DOCKER_NODE_0 bash -c "
echo \"$NOPASSWD\" >> /etc/sudoers
";

docker cp ~/.bashrc $DOCKER_NODE_0:/home/$USER_0/.bashrc

#-----------------------------------------------------------------------------#
### Build Generator

docker exec -u $USER_0 $DOCKER_NODE_0 bash -c "
cd /home/$USER_0/workspace && git clone https://github.com/BramvdnHeuvel/dnd5e-town-generator.git
";

# docker exec -u $USER_0 $DOCKER_NODE_0 bash -c "
# cd /home/$USER_0/workspace/dnd5e-town-generator && git checkout dev
# ";

docker exec -u $USER_0 $DOCKER_NODE_0 bash -c "
cd /home/$USER_0/workspace/dnd5e-town-generator && sed -i \"s/debug=True/host=\'$CONT_IP\',port=$CONT_PORT_0/g\" main.py
";

docker exec -u $USER_0 $DOCKER_NODE_0 bash -c "
cd /home/$USER_0/workspace/dnd5e-town-generator && pip install -r requirements.txt
";

docker exec -u $USER_0 $DOCKER_NODE_0 bash -c "
cd /home/$USER_0/workspace/dnd5e-town-generator && sudo python3.8 main.py
";

#-----------------------------------------------------------------------------#
### Time set end

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`

#-----------------------------------------------------------------------------#
### Script Completion & Info
echo;
echo "Docker Container name: $DOCKER_CONT_NAME"
echo "Docker Container IP: $CONT_IP" 
echo;

echo "#-----------------------------------------------------------------------------#"
echo "Script Completion."
echo "Execution Time: $execution_time"
echo "Good Bye!"
echo "#-----------------------------------------------------------------------------#"
echo;
