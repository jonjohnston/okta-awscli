#!/bin/bash

BASEDIR=$(dirname "$0")
user=$USER
local=$(pwd)
unameOut="$(uname -s)"
case "${unameOut}" in
	Linux*)     machine=Linux;;
	Darwin*)    machine=Mac;;
	CYGWIN*)    machine=Cygwin;;
	MINGW*)     machine=MinGw;;
	*)          machine="UNKNOWN:${unameOut}"
esac

if [ $machine != "Mac" ]; then
	if [ $(whoami) != 'root' ]; then 
		echo "Need to run as sudo"
		exit 1
	fi
fi

LOGFILE="${local}/installer.log"
> $LOGFILE
# Check prerequisites to make sure they are installed
aws --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	rm -f ~/.aws/config ~/.aws/credentials >/dev/null 2>&1
	aws --version > /dev/null 2>&1
	if [ $? -ne 0 ]; then
        	echo 'Warning: AWS CLI is not installed. Make sure to install that'
        	exit 1
	fi
fi
python --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo 'Warning: Python is required. Make sure to install that'
        exit 1
fi
pip --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo 'Warning: pip is required. Make sure to install that'
        exit 1
fi
py2install='n'
pipversion=$(pip --version | grep python2)
if [ -z "$pipversion" ]; then
	py2install='y'
fi
git --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo 'Warning: GIT is required. Make sure to install that'
        exit 1
fi
aliyuncheck=$(which aliyun)
if [ -z "$aliyuncheck" ]; then
	echo "Warning: Aliyun and jq are required if using Alibaba CLI"
	read -n 1 -s -r -p "Press any key to continue"
	echo ""
fi

# Download from git and run the installer
if [ ! -d ~/okta-awscli ]; then
	git clone https://github.com/jonjohnston/okta-awscli.git ~/okta-awscli/ >/dev/null 2>&1
	cd ~/okta-awscli/
	if [ $py2install = 'y' ]; then
		pip2 install -r requirements.txt >/dev/null 2>&1
	fi
	python setup.py install >/dev/null 2>&1
fi

# Copy files
cp .okta-aws ~/ >/dev/null 2>>$LOGFILE
if [ ! -d ~/.aliyun ]; then
	mkdir -p ~/.aliyun 2>>$LOGFILE
fi
chmod +x ./okta-cli >/dev/null 2>>$LOGFILE
chmod +x ./aliyun-cli >/dev/null 2>>$LOGFILE
cp ./okta-cli /usr/local/bin >/dev/null 2>&1
cp ./aliyun-cli /usr/local/bin >/dev/null 2>>$LOGFILE
cp ./aliyun.py /usr/local/bin >/dev/null 2>>$LOGFILE
cp ./aliyun-config.json ~/.aliyun/ >/dev/null 2>>$LOGFILE
cp ./okta-cred-installer.sh $local/ >/dev/null 2>>$LOGFILE
cd $local
rm -rf ~/okta-awscli
# Check for errors
errors=$(cat $LOGFILE)
if [ "$errors" = "" ]; then
	echo "Install has completed successfully. Run okta-cli"
	rm -f $LOGFILE
else
	echo "Install completed with errors. Please check $LOGFILE"
fi
