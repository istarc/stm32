###
# Create stm32 development environment from scratch via Dockerfile
#
# VERSION         1.0
# DOCKER_VERSION  1.1.2
# AUTHOR          Iztok Starc <iz***.st***@gmail.com>
# DESCRIPTION     Problem.  You would like to use stm32 repository that is configured to work with Ubuntu 14.04 LTS.
#                           However, you use some other Linux distribution (or even Win or Mac OS X).
#
#                 Solution. Use Docker to setup the required development environment.
#                           It works even under Windows or Mac OS X. 
#                           However, you'll have to tailor steps (I) and (II) to your host system.
#

###
# I.  Install software dependencies
#
# 1. cd ~
# 2. sudo apt-get update 
# 3. sudo apt-get install git docker.io
# 3. sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
# 4. sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
# 5. sudo docker pull ubuntu
# 6. git clone https://github.com/istarc/stm32.git
# 7. cd ~/stm32
# 8. git submodule update --init # Optional
#
# II. Use Docker
#
# 1. cd ~/stm32
# 2. sudo docker build -t stm32 - < Dockerfile
# 3. CONTAINER_ID=$(sudo docker run -P -d stm32)
#    # Other options:
#    #  sudo docker run -P -i -t stm32 /bin/bash # Interactive
# 4. ssh -p $(sudo docker port $CONTAINER_ID 22 | cut -d ':' -f2) admin@localhost
#    # Password: admin
# 5. firefox http://localhost:$(sudo docker port $CONTAINER_ID 8010 | cut -d ':' -f2)
#    # Username: admin
#    # Password: admin
#    # Click -> Waterfall (link) -> test-build (link) -> Force Build (button) -> Refresh (F5)
# 6. sudo docker stop $CONTAINER_ID
#  
# Powerful one-liners (use them with care :-))
# 7. docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) # Stop and remove all containers
# 8. sudo docker rmi $(sudo docker images | grep "^<none>" | awk '{print $3}') # Remove all untagged images

###
# Docker script

###
# Initial docker image
from ubuntu:14.04

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
run useradd -s /bin/bash -m -d /home/admin -p sa1aY64JOY94w admin
run sed -Ei 's/adm:x:4:/admin:x:4:admin/' /etc/group
run sed -Ei 's/(\%admin ALL=\(ALL\) )ALL/\1 NOPASSWD:ALL/' /etc/sudoers

# Clone stm32 repository
run cd /home/admin; git clone https://github.com/istarc/stm32.git
run cd /home/admin/stm32; git submodule update --init

# Setup ssh server
run mkdir -p /var/run/sshd
run /bin/echo -e "[program:sshd]\ncommand=/usr/sbin/sshd -D\n" > /etc/supervisor/conf.d/sshd.conf

# Create buildbot configuration
run mkdir -p /home/admin/stm32bb
run buildbot create-master /home/admin/stm32bb/master
run cp /home/admin/stm32/test/buildbot/master/master.cfg /home/admin/stm32bb/master/master.cfg
run buildslave create-slave /home/admin/stm32bb/slave localhost:9989 arm-none-eabi pass-MonkipofPaj1
run /bin/echo -e "[program:buildmaster]\ncommand=twistd --nodaemon --no_save -y buildbot.tac\ndirectory=/home/admin/stm32bb/master\nuser=admin\n" > /etc/supervisor/conf.d/buildbot.conf
run /bin/echo -e "[program:buildworker]\ncommand=twistd --nodaemon --no_save -y buildbot.tac\ndirectory=/home/admin/stm32bb/slave\nuser=admin\n" >> /etc/supervisor/conf.d/buildbot.conf

# Setup privileges
run chown -R admin:admin /home/admin

# Expose container port 22 and 9989 to a random port in the host.
expose 22 
expose 8010

# Commands to be run at start
cmd ["/usr/bin/supervisord", "-n"]

