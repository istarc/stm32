#!/bin/bash

##
# Basic Descripton
#
# This is a GitLab & GitLab CI deployment utility. You can now setup 
#  private git repository management system with continuous integration
#  for STM32 embedded systems development on a single host.
#
# - GitLab server offers "git repository management, code reviews, 
#    issue tracking, activity feeds, wikis".
#
# - GitLab Continuous Integration (CI) server "integrates with your 
#    GitLab installation to run tests for your projects". It supports
#    GNU Tools for ARM Embedded Processors
#    (see https://launchpad.net/gcc-arm-embedded).

##
# Some Further Details
#
# - This GitLab & GitLab CI system is deployed as a docker container
#    to decrease host system pollution. Only ruby, ruby-mechanize,
#    wget, curl, nc and lxc-docker-1.3.2 packages are installed. The latter
#    is installed from a 3rd party repository maintained by docker.com.
#
# - Docker containers store GitLab and GitLab CI data on host computer 
#    to avoid data loss, when they are stopped or deleted. "/opt" directory 
#    is used to store the data. The GitLab and GitLab CI services are resumed
#    by running this script again.

##
# Prerequisites: Ubuntu 14.04 LTS

###
# Check My Blog
#  http://istarc.wordpress.com

###
# 0. Define Variables
# 0.1 Stop on first error
set -e 
# 0.2 Be verbose
# set -x
# 0.3 PostgreSQL Configuration
# 0.3.1 GitLab DB
export DB_NAME="gitlab"
export DB_USER="gitlab"
export DB_PASS="gitlab" # Use apg to generate the password, e.g. "apg -a0 sNCL -m 16 -x 16 -t"
# 0.3.2 GitLab CI DB
export DBCI_NAME="gitlab_ci"
export DBCI_USER="gitlab_ci"
export DBCI_PASS="gitlab_ci" # Use apg to generate the password, e.g. "apg -a0 sNCL -m 16 -x 16 -t"
# 0.4 GitLab Configuration
export GITLAB_IP=192.168.255.2
if [ $(ip addr | grep $GITLAB_IP | wc -l) == 0 ]; then
	export DEVICE="$(ls /sys/class/net | grep eth | head -n1):1"
	echo "Error: GitLab network device not detected."
	echo "Try: sudo ifconfig $DEVICE $GITLAB_IP netmask 255.255.255.0 up"
	exit 1
fi
export GITLAB_PORT="80"
if [ $(nc -z $GITLAB_IP $GITLAB_PORT; echo $?) == 0 ]; then
	echo "Error: GitLab HTTP port $GITLAB_PORT already in use."
	echo "Try: change the GITLAB_PORT value."
	exit 1
fi
export GITLAB_SSH_PORT="22"
if [ $(nc -z $GITLAB_IP $GITLAB_SSH_PORT; echo $?) == 0 ]; then
	echo "Error: GitLab SSH port $GITLAB_SSH_PORT already in use."
	echo "Try: change the GITLAB_SSH_PORT value."
	exit 1
fi
# 0.5 GitLab CI Configuration
export GITLABCI_IP=192.168.255.3
if [ $(ip addr | grep $GITLABCI_IP | wc -l) == 0 ]; then
	export DEVICE="$(ls /sys/class/net | grep eth | head -n1):2"
	export NETMASK="255.255.255.0"
	echo "Error: GitLab CI network device not detected."
	echo "Try: sudo ifconfig $DEVICE $GITLABCI_IP netmask 255.255.255.0 up"
	exit 1
fi
export GITLAB_CI_PORT="80"
if [ $(nc -z $GITLABCI_IP $GITLAB_CI_PORT; echo $?) == 0 ]; then
	echo "Error: GitLab HTTP port $GITLAB_CI_PORT already in use."
	echo "Try: change the GITLAB_CI_PORT value."
	exit 1
fi
# 0.6 GitLab CI Runner Configuration
export CI_SERVER_URL="http://$GITLABCI_IP:$GITLAB_PORT"
export CI_RUNNERS_COUNT=2
# 0.7 Install software dependencies
if [ -z "$(cat /etc/os-release | grep "Ubuntu 14.04")" ]; then
	echo "Software dependencies are automatically installed on"
	echo "Ubuntu 14.04 LTS, but your system is"
	echo ""
	cat /etc/os-release
	echo ""
	echo "Before you continue you should manually install the following packages:"
	echo ""
	echo "lxc-docker-1.3.2 ruby ruby-mechanize wget curl netcat"
	echo ""
	read -r -p "Continue? [y/N] " response
	case $response in
	    [yY][eE][sS]|[yY])
	        ;;
	    *)
					exit 0
	        ;;
	esac
else
	# 0.7.1 Install platform dependencies
	export DEBIAN_FRONTEND=noninteractive
	if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
		sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
		sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
	fi
	sudo apt-get update -q
	# 0.7.2 Install Docker 1.3.2
	sudo apt-get install -y lxc-docker-1.3.2
	# 0.7.3 Install Ruby et al.
	sudo apt-get install -y ruby ruby-mechanize wget curl netcat
fi
# 0.8 Get Existing Docker Containers ID
#
# DANGER ZONE
#  Stop and remove all containers
#   sudo docker stop $(sudo docker ps -a -q) 
#   sudo docker rm $(sudo docker ps -a -q)
#  Remove all untagged images
#   sudo docker rmi $(sudo docker images | grep "^<none>" | awk '{print $3}')
#
export CONTAINER_IDS=$(sudo docker ps -a -q)
if [ ! -z "$CONTAINER_IDS" ]; then
	export POSTGRES_ID=$(sudo docker inspect --format '{{.Name}} {{.Config.Hostname}}' $CONTAINER_IDS | grep -e '^/postgresql ' | cut -d' ' -f2)
	export GITLAB_ID=$(sudo docker inspect --format '{{.Name}} {{.Config.Hostname}}' $CONTAINER_IDS | grep -e '^/gitlab ' | cut -d' ' -f2)
	export GITLABCI_ID=$(sudo docker inspect --format '{{.Name}} {{.Config.Hostname}}' $CONTAINER_IDS | grep -e '^/gitlab-ci ' | cut -d' ' -f2)
	export GITLABCI_RUNNER_ID=$(sudo docker inspect --format '{{.Name}} {{.Config.Hostname}}' $CONTAINER_IDS | grep -e '^/gitlab-ci-runner ' | cut -d' ' -f2)
fi
# 0.9 Check Existing Data Store
if [ -d "/opt/postgresql" ] || [ -d "/opt/gitlab" ] || [ -d "/opt/gitlab-ci" ] || [ -d "/opt/gitlab-ci-runner" ]; then
	echo ""
	echo "Wipe out the previous deployment?"
	echo ""
	echo " - /opt/postgresql"
	echo " - /opt/gitlab"
	echo " - /opt/gitlab-ci"
	echo " - /opt/gitlab-ci-runner"
	echo " - corresponding docker containers"
	echo ""
	read -r -p "Are you sure? [y/N] " response
	echo ""
	case $response in
	    [yY][eE][sS]|[yY])
					sudo rm -rf /opt/postgresql
					if [ ! -z "$POSTGRES_ID" ]; then sudo docker stop $POSTGRES_ID && sudo docker rm $POSTGRES_ID && POSTGRES_ID=""; fi
					sudo rm -rf /opt/gitlab
					if [ ! -z "$GITLAB_ID" ]; then sudo docker stop $GITLAB_ID && sudo docker rm $GITLAB_ID && GITLAB_ID=""; fi
					sudo rm -rf /opt/gitlab-ci
					if [ ! -z "$GITLABCI_ID" ]; then sudo docker stop $GITLABCI_ID && sudo docker rm $GITLABCI_ID && GITLABCI_ID=""; fi
					sudo rm -rf /opt/gitlab-ci-runner
					if [ ! -z "$GITLABCI_RUNNER_ID" ]; then sudo docker stop $GITLABCI_RUNNER_ID && sudo docker rm $GITLABCI_RUNNER_ID && GITLABCI_RUNNER_ID=""; fi
	        ;;
	    *)
	        ;;
	esac
fi

# 2. Deploy PostgreSQL
echo -e "Deploying PostgreSQL"
if [ ! -d "/opt/postgresql/data" ]; then
# 2.1A Create Data Store
	sudo mkdir -p /opt/postgresql/data
# 2.2A Run new Image on new Data Store
	sudo docker run --name=postgresql -d -v /opt/postgresql/data:/var/lib/postgresql sameersbn/postgresql:latest
# 2.3A Wait for PostgreSQL to Start
	echo -en "waiting for PostgreSQL\n."
	sudo docker exec -it postgresql bash -c 'until $(: </dev/tcp/127.0.0.1/5432); do echo -n .; sleep 1; done 2>/dev/null'
# 2.4A Create GitLab DB
	sudo docker exec -it postgresql sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
	sudo docker exec -it postgresql sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
	sudo docker exec -it postgresql sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
# 2.5A Create GitLab-CI DB
	sudo docker exec -it postgresql sudo -u postgres psql -c "CREATE USER $DBCI_USER WITH PASSWORD '$DBCI_PASS';"
	sudo docker exec -it postgresql sudo -u postgres psql -c "CREATE DATABASE $DBCI_NAME;"
	sudo docker exec -it postgresql sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DBCI_NAME TO $DBCI_USER;"
elif [ ! -z "$POSTGRES_ID" ]; then
# 2.1B Run Existing Container on Existing Data Source
	sudo docker start postgresql
# 2.2B Wait for PostgreSQL to Start
	echo -en "waiting for PostgreSQL\n."
	sudo docker exec -it postgresql bash -c 'until $(: </dev/tcp/127.0.0.1/5432); do sleep 1; done 2>/dev/null'
else 
# 2.1C Run new Image on Existing Data Store
	sudo docker run --name=postgresql -d -v /opt/postgresql/data:/var/lib/postgresql sameersbn/postgresql:latest
# 2.2C Wait for PostgreSQL to Start
	echo -en "waiting for PostgreSQL\n."
	sudo docker exec -it postgresql bash -c 'until $(: </dev/tcp/127.0.0.1/5432); do sleep 1; done 2>/dev/null'
fi

# 3. Deploy GitLab https://github.com/sameersbn/docker-gitlab
echo -e "\n\nDeploying GitLab"
if [ ! -d "/opt/postgresql/data" ]; then
# 3.1A Create Data Store
	sudo mkdir -p /opt/gitlab/data
# 3.2A Run new Image on new Data Store
	sudo docker run --name="gitlab" -d --link=postgresql:postgresql -e "DB_NAME=$DB_NAME" -e "DB_USER=$DB_USER" -e "DB_PASS=$DB_PASS" -e "GITLAB_HOST=$GITLAB_IP" -e "GITLAB_PORT=$GITLAB_PORT" -p "$GITLAB_IP:$GITLAB_PORT:$GITLAB_PORT" -e "GITLAB_SSH_PORT=$GITLAB_SSH_PORT" -p "$GITLAB_IP:$GITLAB_SSH_PORT:$GITLAB_SSH_PORT" -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /opt/gitlab/data:/home/git/data istarc/docker-gitlab:7.5.2
elif [ ! -z "$GITLAB_ID" ]; then
	# 3.1B Run Existing Container on Existing Data Source
	sudo docker start gitlab
else
	# 3.1C Run new Image on Existing Data Store
	sudo docker run --name="gitlab" -d --link=postgresql:postgresql -e "DB_NAME=$DB_NAME" -e "DB_USER=$DB_USER" -e "DB_PASS=$DB_PASS" -e "GITLAB_HOST=$GITLAB_IP" -e "GITLAB_PORT=$GITLAB_PORT" -p "$GITLAB_IP:$GITLAB_PORT:$GITLAB_PORT" -e "GITLAB_SSH_PORT=$GITLAB_SSH_PORT" -p "$GITLAB_IP:$GITLAB_SSH_PORT:$GITLAB_SSH_PORT" -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /opt/gitlab/data:/home/git/data istarc/docker-gitlab:7.5.2
fi

# 4. Deploy GitLab-CI https://github.com/sameersbn/docker-gitlab-ci
echo -e "\nDeploying GitLab CI"
if [ ! -d "/opt/gitlab-ci/data" ]; then
# 4.1A Create Data Store
	sudo mkdir -p /opt/gitlab-ci/data
# 4.2A Run new Image on new Data Store
	sudo docker run --name="gitlab-ci" -d --link=postgresql:postgresql -e "DB_NAME=$DBCI_NAME" -e "DB_USER=$DBCI_USER" -e "DB_PASS=$DBCI_PASS" --link=gitlab:gitlab -e "GITLAB_CI_PORT=$GITLAB_CI_PORT" -p "$GITLABCI_IP:$GITLAB_CI_PORT:$GITLAB_CI_PORT" -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /opt/gitlab-ci/data:/home/gitlab_ci/data sameersbn/gitlab-ci:5.2.0
elif [ ! -z "$GITLABCI_ID" ]; then
# 4.1B Run Existing Container on Existing Data Source
	sudo docker start gitlab-ci
else
# 4.1C Run new Image on Existing Data Store
	sudo docker run --name="gitlab-ci" -d --link=postgresql:postgresql -e "DB_NAME=$DBCI_NAME" -e "DB_USER=$DBCI_USER" -e "DB_PASS=$DBCI_PASS" --link=gitlab:gitlab -e "GITLAB_CI_PORT=$GITLAB_CI_PORT" -p "$GITLABCI_IP:$GITLAB_CI_PORT:$GITLAB_CI_PORT" -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /opt/gitlab-ci/data:/home/gitlab_ci/data sameersbn/gitlab-ci:5.2.0
fi

# 5. Deploy GitLab CI Runner https://github.com/istarc/docker-gitlab-ci-runner
echo -e "\nDeploying GitLab CI Runner"
echo -en "waiting for GitLab\n."
sudo docker exec -it gitlab bash -c 'until $(: </dev/tcp/127.0.0.1/80); do echo -n .; sleep 1; done 2>/dev/null'
echo -en "\nwaiting for the GitLab Nginx"
curl --retry-delay 2 --retry 60 -sSf "http://$GITLAB_IP:$GITLAB_PORT" > /dev/null
echo -en "waiting for GitLab CI\n."
sudo docker exec -it gitlab-ci bash -c 'until $(: </dev/tcp/127.0.0.1/80); do echo -n .; sleep 1; done 2>/dev/null'
echo -en "\nwaiting for the GitLab CI Nginx"
curl --retry-delay 2 --retry 60 -sSf "http://$GITLABCI_IP:$GITLAB_CI_PORT" > /dev/null
if [ ! -d "/opt/gitlab-ci-runner" ]; then
# 5.1A Create Data Store
	sudo mkdir -p /opt/gitlab-ci-runner
# 5.2A Donwload the CI registration Token Retrieval Script
	wget -O getcitoken.rb https://raw.githubusercontent.com/sammcj/getcitoken/master/getcitoken.rb
# 5.3A Provide Appropriate Configuration File
	cat <<-EOF > config.yml
	gitlab_ci_url: 'http://$GITLABCI_IP:$GITLAB_CI_PORT'
	gitlab_username: 'root'
	gitlab_password: '5iveL!fe'
	EOF
# 5.4A Run the Script and Save the Token
	export REGISTRATION_TOKEN=$(ruby getcitoken.rb)
# 5.5A Run the Image
	sudo docker run --name="gitlab-ci-runner" -d -e "CI_SERVER_URL=$CI_SERVER_URL" -e "REGISTRATION_TOKEN=$REGISTRATION_TOKEN" -e "CI_RUNNERS_COUNT=$CI_RUNNERS_COUNT" -v /opt/gitlab-ci-runner:/home/gitlab_ci_runner/data istarc/docker-gitlab-ci-runner:5.0.0-1
# 5.6A Clean Up
	rm -f getcitoken.rb
	rm -f config.yml
elif [ ! -z "$GITLABCI_RUNNER_ID" ]; then
# 5.1B Run Existing Container on Existing Data Source
	sudo docker start gitlab-ci-runner
else
# 5.1C Run new Image on Existing Data Store
	sudo docker run --name="gitlab-ci-runner" -d -e "CI_RUNNERS_COUNT=$CI_RUNNERS_COUNT" -v /opt/gitlab-ci-runner:/home/gitlab_ci_runner/data istarc/docker-gitlab-ci-runner:5.0.0-1
fi

# 6. Usage Instructions
cat <<- EOF

	Usage Instructions:

	GitLab:
	 - http://$GITLAB_IP:$GITLAB_PORT (U: root P: 5iveL!fe)
	 - sudo docker exec -it gitlab bash # Attach to the running container
	 - sudo docker start gitlab # Start the container
	 - sudo docker stop gitlab # Stop the container

	GitLab CI:
	 - http://$GITLABCI_IP:$GITLAB_CI_PORT (U: root P: 5iveL!fe)
	 - sudo docker exec -it gitlab-ci bash
	 - sudo docker start gitlab-ci
	 - sudo docker stop gitlab-ci

	GitLab CI Runner:
	 - sudo docker exec -it gitlab-ci-runner bash 
	 - sudo docker start gitlab
	 - sudo docker stop gitlab

	PostgreSQL:
	 - docker exec -it postgresql bash 
	 - docker exec -it postgresql sudo -u postgres psql -c "\l" # List DB
	 - sudo docker start postgresql
	 - sudo docker stop postgresql
EOF