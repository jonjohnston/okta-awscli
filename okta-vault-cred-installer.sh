#!/bin/bash

BASEDIR=$(dirname "$0")
user=$USER
localdir=$(pwd)
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
	if [ $(whoami) != 'root' ]; then 
		echo "Need to run as sudo"
		exit 1
	fi
	AWS='/usr/local/bin/aws'
fi

LOGFILE="${localdir}/installer.log"
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
fi
pythonversion=$(python --version | grep "Python 3")
pip --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo 'Warning: pip is required. Make sure to install that'
        exit 1
fi
py2install='n'
if [ -z "$pythonversion" ]; then
        py2install='y'
fi
git --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo 'Warning: GIT is required. Make sure to install that'
        exit 1
fi

# Download from git and run the installer
git clone -b okta-vault-cli https://github.com/jonjohnston/okta-awscli.git ~/vault-okta-awscli/ >/dev/null 2>&1
cd ~/vault-okta-awscli/
if [ $py2install = 'y' ]; then
        pip2 install -r requirements.txt >/dev/null 2>&1
else
        pip install -r requirements.txt >/dev/null 2>&1
fi

python setup.py install >/dev/null 2>&1

# Copy files
cp ~/vault-okta-awscli/.okta-vault-aws ~/ >/dev/null 2>>$LOGFILE
chmod +x ~/vault-okta-awscli/okta-vault-cli >/dev/null 2>>$LOGFILE
cp ~/vault-okta-awscli/okta-vault-cli /usr/local/bin >/dev/null 2>&1
cd $localdir

# Check for errors
myerrors=$(cat $LOGFILE)
if [ "$myerrors" = "" ]; then
	echo "Install has completed successfully. Run okta-vault-cli"
	rm -f $LOGFILE
else
	echo "Install completed with errors. Please check $LOGFILE"
fi
