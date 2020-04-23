#!/bin/bash

BASEDIR=$(dirname "$0")
user=$USER
local=$(pwd)
unameOut="$(uname -s)"
AWS=$(which aws)
case "${unameOut}" in
	Linux*)     machine=Linux;;
	Darwin*)    machine=Mac;;
	CYGWIN*)    machine=Cygwin;;
	MINGW*)     machine=MinGw;;
	*)          machine="UNKNOWN:${unameOut}"
esac

if [ $machine != "Mac" ]; then
	if [ $(whoami) != root ]; then 
		echo "Need to run as sudo"
		exit 1
	fi
	AWS='/usr/local/bin/aws'
fi

LOGFILE="${local}/installer.log"
> $LOGFILE
# Check prerequisites to make sure they are installed
$AWS --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	rm -f ~/.aws/config ~/.aws/credentials >/dev/null 2>&1
	$AWS --version > /dev/null 2>&1
	if [ $? -ne 0 ]; then
        	echo 'Warning: AWS CLI is not installed. Make sure to install that'
        	exit 1
	fi
fi
python --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo 'Warning: Python is required. Make sure to install that'
        exit 1
#else
#	pythonversion=$(python --version 2>/dev/null | grep "Python 3")
#	if [ -z "$pythonversion" ]; then
#		echo 'Python needs to be version 3'
#		exit 1
#	fi
fi
git --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo 'Warning: GIT is required. Make sure to install that'
        exit 1
fi

# Download from git and run the installer
if [ ! -d ~/okta-awscli ]; then
	git clone -b okta-vault-cli https://github.com/jonjohnston/okta-awscli.git ~/vault-okta-awscli/ >/dev/null 2>&1
	cd ~/vault-okta-awscli/
	python setup.py install >/dev/null 2>&1
	rm -rf ~/vault-okta-awscli
fi

cd $local
# Copy files
if [ ! -f ~/.okta-aws ]; then
	cp $BASEDIR/.okta-aws ~/ >/dev/null 2>>$LOGFILE
fi
chmod +x $BASEDIR/okta-vault-cli >/dev/null 2>>$LOGFILE
cp $BASEDIR/okta-vault-cli /usr/local/bin >/dev/null 2>&1

# Check for errors
errors=$(cat $LOGFILE)
if [ "$errors" = "" ]; then
	echo "Install has completed successfully. Run okta-vault-cli"
	rm -f $LOGFILE
else
	echo "Install completed with errors. Please check $LOGFILE"
fi
