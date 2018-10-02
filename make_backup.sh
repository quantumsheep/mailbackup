#!/bin/bash

# Automatic mail backup for Debian, Ubuntu, CentOS, Fedora and Arch Linux
# https://github.com/quantumsheep/mailbackup

if [ "$(id -u)" != "0" ]; then
	echo "You must start this script with root privileges."
	exit 1
fi

function checkOS () {
	if [[ -e /etc/debian_version ]]; then
		OS="debian"

		source /etc/os-release
		if [[ $ID == "ubuntu" ]]; then
			OS="ubuntu"
		fi
	elif [[ -e /etc/fedora-release ]]; then
		OS=fedora
	elif [[ -e /etc/centos-release ]]; then
		OS=centos
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS or Arch Linux system"
		exit 1
	fi
}


function installDependency () {
	echo -ne "Check if $1 is installed..."

	if [[ $(command -v $1) = "" ]]; then
		echo -ne "\nInstall $1..."

		if [[ $OS =~ (debian|ubuntu) ]]; then
			apt-get install -y $1 > /dev/null
		elif [[ $OS = "centos" ]]; then
			yum install -y $1 > /dev/null
		elif [[ $OS = "fedora" ]]; then
			dnf install -y $1 > /dev/null
		elif [[ $OS = "arch" ]]; then
			pacman -Syu --noconfirm $1 > /dev/null
		fi
	fi

	echo " Done"
}


echo -ne "Directorie(s) to save (separated by white spaces): "
read directories

echo -ne "MailBackup email (ex: backup@example.com): "
read email

echo -ne "MailBackup email contact name (ex: Backup): "
read contact

echo -ne "MailBackup email title prefix (ex: VPS Backup): "
read title

echo -ne "Your email: "
read to


checkOS

installDependency zip
installDependency sendmail
installDependency gpgsm
installDependency mutt

date=`date '+%Y/%m/%d %H:%M:%S'`
mindate=`date '+%Y-%m-%d--%H:%M:%S'`
filename="/tmp/backup--$mindate.zip"

zip -r $filename $directories
echo "" | mutt -a $filename -e "my_hdr From:$contact <$email>" -s "$title - $date" -- $to

echo "Backup sent to $to"