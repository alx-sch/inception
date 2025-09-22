# inception
Set up a Linux virtual machine and use Docker to build and manage containerized services.

## What is Docker? What are containers?

XXX
XXXXX


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
       
### 4. Connect from the Host

Start the VM (you don’t need to log in at the console) and, on the host:

```bash
ssh <vm_username>@localhost -p 2222
```

### 5 Optional: SSH Config Shortcut

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

### 6. Use Your Local Editor (e.g. VS Code)
- Install the **Remote – SSH** extension on VS Code.
- Click the “><” icon in the lower-left corner (“Open a Remote Window”).
- Choose **Connect to Host → myvm** and enter the VM user’s password.

You can now edit files and run terminals in VS Code as if you were working locally.

---- 

## Setting up Docker

To turn the minimal Debian server installation to a ready-to-use Docker host, follow these steps:

### 1. Create a Sudo-Enabled User

Docker commands typically require elevated privileges. To give your user sudo rights:

```bash
# Log in as root
su -

# Install sudo
apt install sudo

# Add your user to the sudo group (replace with your username)
usermod -aG sudo your_username

# Verify membership
groups your_username
```

You should see `sudo` listed in the groups. Type `exit` to leave the root shell, then log out and back in for the change to take effect.

### 2. Update the System

Keep the packages current:

```bash
sudo apt update && sudo apt upgrade -y
```

### 3. Install Common Tools

Install a few utilities you’ll use often:

```bash
sudo apt install curl git -y
```

`git` helps manage project files from a repository.
`curl` is handy for downloading installation scripts.

### 4. Install Docker Engine

Follow Docker’s official guide for the most reliable installation:
[Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)

Use the “Install using the apt repository” method. After installation, confirm that Docker is working:

```bash
sudo docker run hello-world
```

If you see the “Hello from Docker!” message, your setup is complete.
