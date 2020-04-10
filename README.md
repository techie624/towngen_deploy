# towngen_deploy
Public Repo for using scripts to deploy Town Generator Locally within a Ubuntu Container. All creation of 

All credit and creation of the Generator belongs to Bram van den Heuvel (noordstar.me).

# Docker Hub Image(s)
https://hub.docker.com/repository/docker/techie624/dnd_towngen_ubuntu

# Image Deployment
```bash
bash town_gen-node_Deploy.sh
```
All Variables within the creation town_gen-node.sh script can create your own image and how you want it deployed. By default the deployment will state the docker network IP address that can be reached locally and is defaulted at port 80.