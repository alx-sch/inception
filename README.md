# inception
Set up a Linux virtual machine and use Docker to build and manage containerized services.

## What is Docker? What are containers?




## Setting up the VM

### 1. Install the Debian VM

Start with a minimal, command-line-only Debian server to keep the environment clean and predictable. Download a net-install ISO from the [Debian website](https://www.debian.org/distrib/) (choose **64-bit PC netinst iso**).

Create a new VM in **Oracle VirtualBox** (free, open-source):
- **Type**: Linux
- **Subtype**: Debian
- **Skip Unattended Installation**: ✔
- **Memory**: 2048 MB
- **Processors**: 1 CPU
- **Disk**: 20 GB (dynamic allocation is fine)

When the installer runs:
- Deselect Debian desktop environment and any graphical options such as GNOME.
- Make sure SSH server and standard system utilities are selected.
- Install the GRUB boot loader when prompted.

### 2. Enable SSH Access

Working directly in the VM console is possible but inconvenient. Using SSH lets you work from your host machine’s terminal and editor.

Inside the VM, confirm the SSH port:

```bash
grep Port /etc/ssh/sshd_config
```

If `Port 22` is commented out, SSH defaults to port 22, which is what you want.

Find the VM’s internal IP (not strictly required for port forwarding):

```bash
hostname -I
# typically something like 10.0.2.15
```

3. Set Up Port Forwarding in VirtualBox
  1. Shut down the VM.
  2. In **Settings → Network**, ensure the adapter is set to NAT.
  3. Click Port Forwarding and add a rule:
     - **Name:** e.g. ssh-access
     - **Protocol:** TCP
     - **Host Port**: e.g. `2222` (choose a free port)
     - **Guest Port**: `22`
     - **Guest IP**: leave blank (VirtualBox resolves it automatically); you may also add the VM's internal IP address confirmed above
       
## 4. Connect from the Host

Start the VM (you don’t need to log in at the console) and, on the host:

```bash
ssh <vm_username>@localhost -p 2222
```

## 5 Optional: SSH Config Shortcut

To simplify the command, edit `~/.ssh/config` on the host:

```bash
ssh <vm_username>@localhost -p 2222
```


Working directly in a command-line-only VM console is powerful, but it's also inefficient for development. You have no mouse integration, copy-pasting is difficult, and you can't use your favorite text editor. By creating a "tunnel" from the host to the VM's SSH port, we can work from the host machine, using it's terminals and tools.

First, you might want to double check if the VM's SSH uses port 22 (which it should by default). Log into the VM and check:

```bash
Host myvm
   HostName localhost
   User <vm_username>
   Port 2222
```

Now you can connect with:

```bash
ssh myvm
```

## 6. Use Your Local Editor (e.g. VS Code)
- Install the **Remote – SSH** extension on VS Code.
- Click the “><” icon in the lower-left corner (“Open a Remote Window”).
- Choose **Connect to Host → myvm** and enter the VM user’s password.

You can now edit files and run terminals in VS Code as if you were working locally.

---- 

## Setting up Docker

XXXX



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







