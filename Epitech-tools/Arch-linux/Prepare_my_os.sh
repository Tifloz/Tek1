#! /bin/bash

# variables

## script

files="./.files"
dir_tmp="/tmp/install"

login=$1

## fake install ?

fake=0

## colors

ESC="\033["
C_RED=$ESC"0;31m"
C_YELLOW=$ESC"0;33m"
C_BWHITE=$ESC"1;37m"
C_RST=$ESC"0m"


function usage
{
	echo
	echo "Usage: $0 <prenom.nom@epitech.eu>"
	echo
	echo "<prenom.nom@epitech.eu> : Votre login Epitech"
	echo
}

function line
{
	cols=$(tput cols)
	char=$1
	color=$2

	if test "$color" != ""; then
		echo -ne $color
	fi

	for i in $(eval echo "{1..$cols}"); do
		echo -n $char
	done
	echo

	if test "$color" != ""; then
		echo -ne $C_RST
	fi
}

function script_header
{

	color=$2
	if test "$color" = ""; then
		color=$C_RED
	fi

	echo -ne $color
	line "-"
	echo "~##~> "$1
	line "-"
	echo -ne $C_RST
}

function handle_error
{
	result=$1
	if test $result -eq 0; then
		return
	else
		line "#" $C_RED
		line "#" $C_YELLOW
		echo -en $C_RED"[Erreur]"$C_RST" lors de l'installation, voulez-vous arreter le script ? [O/n]  "
		read stop_script
		case $stop_script in
			n|N)	return;;
			*)		exit 1;;
		esac
	fi
}

function get_os_type
{
	which zypper &> /dev/null && os="opensuse"
	which pacman &> /dev/null && os="archlinux"
	which dnf &> /dev/null && os="fedora"
	which apt-get &> /dev/null && os="debian"
	which emerge &> /dev/null && os="gentoo"
}

function script_init
{
	os="void"
	get_os_type

	if test "$os" = "void"; then
		line "#" $C_YELLOW
		script_header "VOTRE DISTRIBUTION N'EST PAS SUPPORTÉE..."
		line "#" $C_YELLOW
		exit 42
	fi

	rm -rf $dir_tmp
	mkdir $dir_tmp
}

function sys_upgrade
{
	if test $fake -eq 1; then
		echo "Upgrade system"
		return
	fi
	case "$os" in
		opensuse)
			sudo zypper -y update
			;;
		archlinux)
			sudo pacman --noconfirm -Syu
			;;
		fedora)
			sudo dnf -y update
			;;
		debian)
			sudo apt-get -y update; sudo apt-get -y upgrade
			;;
		gentoo)
			sudo emerge -u world
			;;
	esac
	handle_error $?
}

function sys_install
{
	package_name=$1

	function get_cmd_install
	{
		case "$os" in
			opensuse)
				echo "zypper -y install"
				;;
			archlinux)
			    echo "pacman --noconfirm -S"
				;;
			fedora)
				echo "dnf -y install"
				;;
			debian)
				echo "apt-get -y install"
				;;
			gentoo)
				echo "emerge"
				;;
		esac
	}

	if test -z "$cmd_install"; then
		cmd_install=$(get_cmd_install)
	fi

	if test $fake -eq 1; then
		echo "Installing" $package_name "(command:" $cmd_install $package_name ")"
		return
	fi

	sudo $cmd_install $package_name
	handle_error $?
}

function script_install
{
	if test $fake -eq 1; then
		echo "Installing" $1 "(script_install)"
		return
	fi
	sudo cp $files/$1 /usr/bin/$1
	handle_error $?
	sudo chmod 755 /usr/bin/$1
	handle_error $?
}

function setup_emacs
{
	if test $fake -eq 1; then
		echo "Setup emacs"
		return
	fi
	SRCDIR=".files"
        DESTDIR="$HOME"

	echo "Installing {EPITECH.} Emacs configuration on your session..."

	echo "Copying configuration files..."
	cat "$SRCDIR/.emacs" >> "$DESTDIR/.emacs"
	mkdir -p "$DESTDIR/.emacs.d/lisp"
	cp "$SRCDIR/.emacs.d/lisp/std.el" "$DESTDIR/.emacs.d/lisp/"
	cp "$SRCDIR/.emacs.d/lisp/std_comment.el" "$DESTDIR/.emacs.d/lisp/"

	echo
	echo "Installation complete."
}

if test $UID -eq 0; then
	echo ">> Ne pas lancer ce script en tant que sudo <<"
	usage
	exit 1
fi
if test -z "$login"; then
	usage
	exit 1
fi

script_init

script_header "INSTALLATION DE BLIH"
script_install blih

script_header "MISE À JOUR DES PAQUETS DU SYSTÈME"
sys_upgrade

script_header "INSTALLATION DE PYTHON3"
sys_install python3

script_header "INSTALLATION DE EMACS ET DU SYSTÈME DE HEADERS EPITECH"
sys_install emacs
setup_emacs

script_header "INSTALLATION DE GCC"
sys_install gcc

script_header "INSTALLATION DE BASE-DEVEL POUR LA COMPILATION"
sys_install base-devel

script_header "INSTALLATION DE VALGRIND"
sys_install valgrind

script_header "INSTALLATION DE OPENSSH"
sys_install openssh

script_header "INSTALLATION DE OCAML"
sys_install ocaml

script_header "INSTALLATION DE LA LIBNCURSES"
sys_install ncurses

script_header "INSTALLATION DE CURL"
sys_install curl

script_header "INSTALLATION DE GIT, GENERATION DE LA CLE SSH ET UPLOAD SUR SERVEUR EPITECH"

script_header "GIT" $C_YELLOW
sys_install git

script_header "CLE SSH, LEAVE EVERYTHING AS DEFAULT" $C_YELLOW
ssh-keygen
handle_error $?

script_header "BLIH SSH UPLOAD" $C_YELLOW
echo "mot de passe Office (Pour se connecter à l'intra)"
blih -u "$1" sshkey upload /home/$USER/.ssh/id_rsa.pub
handle_error $?

script_header "INSTALLATION ET CONFIGURATION DE ZSH ET OH MY ZSH"

script_header "ZSH" $C_YELLOW
sys_install zsh

script_header "OH-MY-ZSH" $C_YELLOW
curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh > oh-my-zsh.sh
sed -i "s:env zsh:exit:g" oh-my-zsh.sh
chmod 755 oh-my-zsh.sh
./oh-my-zsh.sh
rm oh-my-zsh.sh
#no error check here: remote install.sh has a chsh error
chsh $USER -s /usr/bin/zsh
handle_error $?
echo "alias blih='blih -u $1'" >> /home/$USER/.zshrc
echo "alias ns_auth='ns_auth -u $1'" >> /home/$USER/.zshrc

script_header "INSTALLATION DU MAN GOOGLE"
sudo cp $files/google.1 /usr/share/man/man1/google.1
handle_error $?

script_header "INSTALLATION DE TERMINATOR"
sys_install terminator

script_header "INSTALLATION DES OUTILS COMPLEMENTAIRES"
sys_install tree
sys_install filezilla

script_header "CHANGEMENT DES DROITS (-) SUR POWEROFF ET REBOOT"
sudo chmod +s /sbin/poweroff
handle_error $?
sudo chmod +s /sbin/reboot
handle_error $?

script_header "DESIREZ VOUS INSTALLER MAKEFILE-GEN ?"
read -p "Installer makefile-gen pour générer vos makefiles ? [O/n]" yn
case $yn in
    [Nn]* );;
    * ) sys_install ruby; git clone https://github.com/kayofeld/makefile-gen.git; cd makefile-gen; sudo ./install.sh; cd ../;;
esac

script_header "DESIREZ VOUS INSTALLER HTOP ?"
read -p "Installer htop pour avoir un top plus pratique ? [O/n]" yn
case $yn in
    [Nn]* );;
    * ) sys_install htop;;
esac


script_header "EFFACEMENT DES FICHIERS D'INSTALLATION"
rm -rvf ../installation

script_header "VOTRE OS EST PRÊT POUR EPITECH" $C_BWHITE

sudo -k