# let's be up to date
sudo apt-get update
sudo apt-get -y upgrade

# install docker
sudo apt-get install -y linux-image-extra-`uname -r`
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main\
  > /etc/apt/sources.list.d/docker.list"

sudo apt-get update
sudo apt-get install -y lxc-docker

# allow docker port fowarding if its disabled
sudo sed -i.bak s/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/g /etc/default/ufw
sudo ufw reload

# add vagrant user to docker group to avoid requiring sudo
sudo groupadd docker
sudo gpasswd -a vagrant docker
sudo service docker restart

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# get the docker-compose.yml
su -l vagrant -c "wget https://raw.githubusercontent.com/duse-io/setup/master/docker-compose.yml"
