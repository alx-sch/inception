# inception
Set up a Linux VM and use Docker to build and manage containerized services.


VM " Oracle Virtual Box -> Debian Server (command-line only OS)
https://www.debian.org/distrib/: Download CD image: 64-bit PC netinst iso
RAM: 2048 MB
Dynamocallly allocated
Hard disk size: 20 GB

end of installation: Deselecy "Debian Deskop environment", other grapgical environments like GNOME;
Make sure that SSH server and "standard utilities: are selected ; also install GRUB boot loader

FINISH

///

After installation:
login with created user

give user sudo rights
log in as root
su -

install sudo:
apt install sudo

Add your user to sudo group:
usermod -aG sudo your_username

verify change:
groups your_username 
(sudo should show up a group you are part of)

type 'exit' to leave and log out and back in.


1. Update Your System
First, make sure your system's package list is up-to-date and all installed packages are upgraded to their latest versions.

Bash

sudo apt update && sudo apt upgrade -y
2. Install a Few Essential Tools
Install some common utilities that you will need. git is for managing your project files from your repository, and curl is often used to download installation scripts.

Bash

sudo apt install curl git -y


Excellent. Now that you have a clean, minimal Debian OS, you only need to install a few key things to turn it into a host for your project.

The main software you need to install directly on the VM is Docker and Git.

Step-by-Step Installation Guide
Follow these steps in the command line of your new Debian VM.

1. Update Your System
First, make sure your system's package list is up-to-date and all installed packages are upgraded to their latest versions.

Bash

sudo apt update && sudo apt upgrade -y
2. Install a Few Essential Tools
Install some common utilities that you will need. git is for managing your project files from your repository, and curl is often used to download installation scripts.

Bash

sudo apt install curl git -y
3. Install Docker Engine 🐳
This is the most important step. You should always follow the official documentation to install Docker, as it's the most reliable method.

Go to the official Docker guide: Install Docker Engine on Debian (https://docs.docker.com/engine/install/debian/)

Follow the "Installation methods": The recommended method is to set up Docker's official repository and install from there. The guide will walk you through the exact commands to

check if installation was all succesful, by running this docker with:
sudo docker run hello-world


///

VM in NAT (Network Address Translation) mode; VM is hidden from main network (using an internal IP address, like 10.0.2.15);

 port forwarding is a rule that redirects communication from a port on your host computer to a specific port on your VM.

confirm what port ssh uses on VM (should be 22, but just to double check):

grep Port /etc/ssh/sshd_config

#Port 22
#GatewayPorts no

Port 22 is commented out, so the default is used (which is port 22)







