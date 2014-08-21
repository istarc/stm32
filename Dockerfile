###
# stm32 Repo Dockerfile
#
# VERSION         1.0
# DOCKER_VERSION  1.1.2
# AUTHOR          Iztok Starc <iz***.st***@gmail.com>
# DESCRIPTION     So ... you use different OS STM32 Repository Dockerfile is used to deploy the build environment 
#

###
# I.  Install software dependencies
#
# 1.  cd ~
# 2.  sudo apt-get update && sudo apt-get install docker.io
# 3.  sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
# 4.  sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
# 5.  sudo docker pull ubuntu
#
# To install docker on other system than Ubuntu 14.04 LTS, e.g. Windows, Mac OS X, follow the appropraite guide below, however you'll have to tailor the remaining steps to your host OS.
# https://docs.docker.com/installation/mac/
# https://docs.docker.com/installation/windows/

###
# II. Install software dependencies
#
# 6.  cd ~
# 7.  sudo apt-get install git
# 8.  git clone https://github.com/istarc/stm32.git
# 9.  cd ~/stm32
# 10. git submodule update --init # Optional

###
# III.Build the image
#
# 11. cd ~/stm32
# 12. sudo docker build -t stm32 - < Dockerfile

###
# IV. Run the image
#
# 13. CONTAINER_ID=$(sudo docker run -P -d stm32)

# V.  Connect to the container (image instance):
#
# 14. ssh -p $(sudo docker port $CONTAINER_ID 22 | cut -d ':' -f2) admin@localhost
# 15. Enter: admin/admin

###
# VI. Stop the container
# 
# 16. sudo docker stop $CONTAINER_ID

###
# Docker script

###
# Initial docker image
from ubuntu:14.04

###
# Variables
run export HOME=/home/admin

# Install platform dependancies
run export DEBIAN_FRONTEND=noninteractive
run sudo apt-get update -q
run sudo apt-get install -y supervisor sudo ssh openssh-server software-properties-common vim

# Install project dependancies
run sudo add-apt-repository -y ppa:terry.guo/gcc-arm-embedded
run sudo apt-get update -q
run sudo apt-cache policy gcc-arm-none-eabi
run sudo apt-get install -y build-essential git openocd gcc-arm-none-eabi=4-8-2014q2-0trusty10 
run sudo apt-get install -y buildbot buildbot-slave

# Add user admin (password: admin)
run useradd -s /bin/bash -m -d $HOME -p sa1aY64JOY94w admin
run sed -Ei 's/adm:x:4:/admin:x:4:admin/' /etc/group
run sed -Ei 's/(\%admin ALL=\(ALL\) )ALL/\1 NOPASSWD:ALL/' /etc/sudoers

# Clone stm32 repository
run cd $HOME; git clone https://github.com/istarc/stm32.git
run cd $HOME/stm32; git submodule update --init

# Setup ssh server
run mkdir -p /var/run/sshd
run echo -e "[program:sshd]\ncommand=/usr/sbin/sshd -D\n" > /etc/supervisor/conf.d/sshd.conf

# Create buildbot configuration
run mkdir -p $HOME/stm32bb
run buildbot create-master $HOME/stm32bb/master
run cp $HOME/stm32/test/buildbot/master/master.cfg $HOME/stm32bb/master/master.cfg
run buildslave create-slave $HOME/stm32bb/slave localhost:9989 arm-none-eabi admin
run echo -e "[program:buildmaster]\ncommand=/usr/bin/buildbot start /home/admin/stm32bb/master\nuser=admin\n" > /etc/supervisor/conf.d/buildbot.conf
run echo -e "[program:buildworker]\ncommand=/usr/bin/buildbot start /home/admin/stm32bb/slave\nuser=admin\n" >> /etc/supervisor/conf.d/buildbot.conf

# Expose container port 22 and 9989 to a random port in the host.
expose 22

# Commands to be run at start
cmd ["/usr/bin/supervisord", "-n"]

