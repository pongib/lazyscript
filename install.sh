#!/bin/bash
# run as root
# Predefind function here
install_jenkins(){
	if [[ $EUID -ne 0 ]]; then
		echo "This script must run as root" 1>&2
		exit 1
	fi
	NAME=$(whoami)
	ARCH=$(uname -m)
	HOST=$(uname -n)
	VERSION=$(lsb_release -d)
	echo "install with $NAME on $HOST : $VERSION with $ARCH architecture"
	echo "-------------------INSTALL---------------------"
	apt-get update
	apt-get install -y openjdk-7-jdk
	apt-get install -y openjdk-7-jre
	wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
	echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
	apt-get update
	apt-get install -y jenkins
}
# ----------------------------------------------------------------
update_jenkins(){
	apt-get update
	apt-get install -y jenkins
}
# ----------------------------------------------------------------
install_plugins_jenkins(){
	echo "install"
}
# ----------------------------------------------------------------
install_phantomjs() {

# it quite specific file name to download
# be careful when phantomjs update

	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 1>&2
		exit 1
	fi

	PHANTOM_VERSION="phantomjs-1.9.8"
	ARCH=$(uname -m)

	if ! [ $ARCH = "x86_64" ]; then
		$ARCH="i686"
	fi

	PHANTOM_JS="$PHANTOM_VERSION-linux-$ARCH"

	apt-get update
	apt-get install build-essential chrpath libssl-dev libxft-dev -y
	apt-get install libfreetype6 libfreetype6-dev -y
	apt-get install libfontconfig1 libfontconfig1-dev -y

	cd ~
	wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
	tar xvjf $PHANTOM_JS.tar.bz2

	mv $PHANTOM_JS /usr/local/share
	ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin
	phantomjs --version
}
# ----------------------------------------------------------------
install_global_npm_packages() {
	if [ -x /usr/local/bin/node ] && [ -x /usr/local/bin/npm ]; then
		apt-get update
		npm install -g npm
		npm --version
		
	else
		curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -
		apt-get update
		apt-get install --yes nodejs
		apt-get install -y build-essential
		node --version
		npm --version
	fi
}
# ----------------------------------------------------------------
update_nodejs(){
	npm cache clean -f
	npm install -g n
	n stable
	node --version
	npm install -g npm
	npm --version
}
# ----------------------------------------------------------------
# Implement
if [[ $EUID -ne 0 ]]; then
	echo "This script must run as root" 1>&2
	exit 1
fi
while true
do
clear
	echo "Hello lazy stranger, let me help you do lazy thing!"
	echo "What type you want to install"
	echo ""
	echo "1) Fist time install jenkins"
	echo "2) Update new verion of jenkins"
	echo "3) Install common jenkins plugins"
	echo "4) Install PhantomJs"
	echo "5) Install useful global npm package"
	echo "6) Update nodejs and npm"
	echo "7) Exit"
	echo ""
	read -p "Select an option [1-7]: " option
	case $option in
		1)
		echo ""
		echo "First time install jenkins"
		install_jenkins
		read -p "Finish!, Press any key to continue" press
		;;
		2)
		echo ""
		echo "Update new version of jenkins"
		update_jenkins
		read -p "Finish!, Press any key to continue" press
		;;
		3)
		echo ""
		echo "Install plugins jenkins"
		install_plugins_jenkins
		read -p "Finish!, Press any key to continue" press
		;;
		4)
		echo ""
		echo "Install PhantomJs"
		install_phantomjs
		read -p "Finish!, Press any key to continue" press
		;;
		5)
		echo ""
		echo "Install global npm package"
		install_global_npm_packages
		read -p "Finish!, Press any key to continue" press
		;;
		6)
		echo ""
		echo "Update nodejs and npm"
		update_nodejs
		read -p "Finish!, Press any key to continue" press
		;;
		7) exit;;
	esac
done
