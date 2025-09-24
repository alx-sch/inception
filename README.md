# inception

<p align="center">
    <img src="https://github.com/alx-sch/inception/blob/main/.assets/inception_badge.png" alt="inception_badge.png" />
</p>

This project focuses on system administration and virtualization with **Docker**. The goal is to build a multi-container application using **Docker Compose**, featuring separate containers for an NGINX web server, a MariaDB database, and a WordPress instance.   

All services are built from scratch using custom `Dockerfiles` and communicate securely over a dedicated Docker network.

---

## Docker Introduction

### What is Docker?

Docker is a platform for developing, shipping, and running applications in **containers**. A Docker container can hold any application and its dependencies (code, libraries, system tools, configuration) and run on any machine that has Docker installed.    

This solves the classic problem of "it works on my machine" by packaging the entire application environment into a single, predictable and portable unit.

---

### A Bit of History

Docker was first introduced by Solomon Hykes at PyCon 2013 -- check out his legendary five-minute minute talk [here](https://www.youtube.com/watch?v=wW9CAH9nSLs)<sup><a href="#footnote1">[1]</a></sup>.     
Originally an internal project at his PaaS company dotCloud, it was quickly open-sourced once its potential became clear.

While Docker popularized containers, the underlying technology has been part of the Linux kernel for years in the form of **cgroups** (which limit resource usage) and **namespaces** (which isolate processes)<sup><a href="#footnote2">[2]</a></sup>.    

Docker’s innovation was to create a user-friendly set of tools, a strong community and useful services (public registries, ready-made base images, and orchestration tools like Compose and Kubernetes), making those kernel features approachable for everyday developers.

---

### Containers vs. Virtual Machines

A common point of confusion is the difference between a container and a virtual machine (VM):

- **A VM** virtualizes the hardware. It runs a full-blown guest operating system with its own kernel on top of your host OS. Think of it as a complete, separate house with its own plumbing, electricity and foundation.
  
- **A Docker Container** virtualizes the operating system. All containers on a host share the host's OS kernel but have their own isolated view of the filesystem and processes. Think of them as apartments in a single building: They all share the building's main foundation and utilities but are completely separate living spaces.

This makes containers incredibly lightweight, fast to start, and efficient compared to VMs.

<p align="center">
    <img src="https://github.com/alx-sch/inception/blob/main/.assets/vm-vs-docker.png" alt="vm-vs-docker.png"  width="600" />
    <br>
     <span>
        <b>VMs (left):</b> Use a hypervisor (managing virtual hardware), include full guest OS.<br>
        <b>Containers (right):</b> Use Docker engine, share the host OS, isolate at process level<sup><a href="#footnote8">[8]</a></sup>.
    </span>
</p>

---

### Applications

Docker is the standard way modern applications are built, shipped, and run<sup><a href="#footnote3">[3</a>,<a href="#footnote4">4]</sup>. Common applications are:

- **Standardized Development Environments**       
    By packaging an application and its dependencies into a container, companies ensure that their software runs identically everywhere: on a developer's laptop, on a testing server, and in production.

- **CI/CD Pipelines**        
   Docker is a cornerstone of modern **Continuous Integration and Continuous Deployment (CI/CD)**. When a developer pushes new code, automated systems use Docker to:
    1. Build the code inside a clean, consistent container.
    2. Run automated tests inside that container.
    3. If tests pass, push the new container image to a registry.
    4. Automatically deploy the updated container to production servers.
 
- **Microservices Architecture**      
    Docker is the perfect platform for microservices, an architectural style where a large application is broken down into smaller, independent services. Each microservice (e.g., user authentication, payment processing, product catalog) runs in its own container. This makes the application easier to develop, scale, and maintain, as different teams can work on different services independently.

- **Cloud and Multi-Cloud Deployment**     
    Docker containers can run on any cloud provider (AWS, Google Cloud, Azure, etc.) without modification. This portability gives companies the freedom to move applications between different cloud environments without being locked into a single vendor. It's the foundation of modern "cloud-native" applications.

---

## Docker Deep Dive

### Docker Components

Overview of multiple Docker components<sup><a href="#footnote5">[5]</a></sup>:

- **Docker Engine:** The core of Docker. It's a client-server application with three main components: a long-running background service called the **Docker daemon**, a **REST API** that specifies interfaces for programs to talk to the daemon, and the **Docker client**.
 
- **Docker Client:** The primary way users interact with Docker. It's the command-line interface (CLI) tool (e.g., `docker run`, `docker build`) that sends commands to the Docker daemon.
 
- **Docker Registries:** A storage and distribution system for Docker images. **Docker Hub** is the default public registry, but companies often host private ones for their own images.
  
- **Docker Images:** Read-only, executable blueprints that contain everything needed to run an application: the code, a runtime, libraries, environment variables, and configuration files.
  
- **Dockerfile:** A text file containing a set of instructions on how to build a Docker image. The `docker build` command reads this file to assemble the image layer by layer.

- **Docker Volumes:** The mechanism for persisting data generated by Docker containers. Volumes are managed by Docker and exist outside the container's lifecycle, ensuring your data is safe even if the container is removed.

- **Docker Compose:** A tool for defining and running multi-container applications. It uses a single YAML file (`docker-compose.yml`) to configure all of the application's services, networks, and volumes, which can then be started or stopped with a single command.

<br>
<p align="center">
    <img src="https://github.com/alx-sch/inception/blob/main/.assets/docker-engine.png" alt="docker-engine.png"  width="400" />
    <br>
     <span>
        <b>Docker Engine:</b> Running a Docker command in the CLI, it communicates with the daemon via a REST API (locally over a Unix socket or TCP). The daemon then manages images, containers, networks and volumes<sup><a href="#footnote9">[9]</a></sup>.
    </span>
</p>

<br>
<p align="center">
    <img src="https://github.com/alx-sch/inception/blob/main/.assets/docker-architecture.png" alt="docker-architecture.png"  width="400" />
    <br>
     <span>
        <b>Docker Architecture:</b> The Docker client (CLI) communicates with the Docker Engine on the host to run containers using images, which are often stored and pulled from a registry like Docker Hub.<br>
        <b>NGINX:</b> Web server or reverse proxy; often used to route traffic to containers or load-balance requests.<br>
        <b>Docker Hub:</b> Public container registry (orange logo); stores and distributes Docker images.<br>
        <b>OpenStack:</b> Cloud platform for managing virtual machines, storage, and networks; can host Docker infrastructure but is separate from Docker itself.<sup><a href="#footnote8">[8]</a></sup>.
    </span>
</p>



---

### The Workflow

1. You write a **Dockerfile**, a text file containing instructions to build a Docker image.   
2. You use the **Docker Client** (`docker build`) to send these instructions to the **Docker Daemon**.
3. The Docker Daemon executes the instructions, creating a **Docker Image**. This image is a lightweight, stand-alone, executable blueprint of your application's environment.
4. You use the Docker Client (`docker run`) to tell the Docker Daemon to create and start a **Container** from that image. The container is a live, running instance of your application.

**Docker Compose** streamlines and automates this workflow, especially for applications with multiple services:

1. You write a Dockerfile for each service (e.g., one for your web server, one for your database).
2. You create a single `docker-compose.yml` file. In this file, you define all your services, tell Compose where to find each service's Dockerfile, and describe how they should be connected (e.g., networking, volumes).
3. You use the **Docker Compose CLI** (`docker-compose up`) to send the entire application definition to the Docker Daemon.
4. The Docker Daemon then reads the `docker-compose.yml file` and:
    - **Builds** a Docker Image from each Dockerfile (if it doesn't already exist).
    - **Creates and starts** a Container from each image, automatically **connecting** them on a shared network so they can communicate.

Docker Compose acts as an orchestrator for the Docker Engine, allowing you to manage the entire build-and-run lifecycle for a multi-container application with a single command.

----

### The Dockerfile

Text-based document that's used to create a container image. As an example, the following Dockerfile would produce a ready-to-run Python application<sup><a href="#footnote7">[7]</a></sup>:

```Dockerfile
FROM python:3.13
WORKDIR /usr/local/app

# Install the application dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy in the source code
COPY src ./src
EXPOSE 5000

# Setup an app user so the container doesn't run as the root user
RUN useradd app
USER app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

A Dockerfile typically follows these steps:

1. Determine your base image
2. Install application dependencies
3. Copy in any relevant source code and/or binaries
4. Configure the final image

Some of the most common instructions in a `Dockerfile` include:

- `FROM <image>` - this specifies the base image that the build will extend.
- `WORKDIR <path>` - this instruction specifies the "working directory" or the path in the image where files will be copied and commands will be executed.
- `COPY <host-path> <image-path>` - this instruction tells the builder to copy files from the host and put them into the container image.
- `RUN <command>` - this instruction tells the builder to run the specified command.
- `ENV <name> <value>` - this instruction sets an environment variable that a running container will use.
- `EXPOSE <port-number>` - this instruction sets configuration on the image that indicates a port the image would like to expose.
- `USER <user-or-uid>` - this instruction sets the default user for all subsequent instructions.
- `CMD ["<command>", "<arg1>"]` - this instruction sets the default command a container using this image will run.

---


Useful Docker commands<sup><a href="#footnote6">[6]</a></sup>:


---

## How Docker is used in Inception   

For this project, we use Docker to create isolated containers for each service:

- Nginx (our web server)
- MariaDB (our database)
- WordPress (our application)

By containerizing them, we ensure that they can be developed, tested, and deployed in any environment with perfect consistency. The `docker-compose.yml` file defines how these isolated containers connect and work together to form a single, functional application.



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

Working directly in the VM console is possible but inconvenient: You have no mouse integration, copy-pasting is not possible, and you can't use your favorite text editor. By creating a "tunnel" from the host to the VM's SSH port, you can work from your host machine’s terminal and editor.

Inside the VM, confirm the SSH port:

```bash
grep Port /etc/ssh/sshd_config
```

If `Port 22` is commented out, SSH defaults to port 22, which is what you want.

By default, the VM is assigned an internal IP address within a private NAT network. This purposefully isolates the VM, making it inaccessible from the external network and providing a basic layer of security. While not strictly required for setting up the port forward, you can check the VM's IP with:

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

## References

<a name="footnote1">[1]</a> Hykes, S.; PyCon 2013 (Mar 13, 2013). [*The future of Linux Containers*](https://www.youtube.com/watch?v=wW9CAH9nSLs)         
<a name="footnote2">[2]</a> Subendran, B.; Medium (Feb 13, 2024). [*Namespaces and cgroups*](https://hanancs.medium.com/namespaces-and-cgroups-3eb99041e04f)     
<a name="footnote3">[3]</a> Docker Inc. (2025). [*What is Docker?*](https://docs.docker.com/get-started/docker-overview/)      
<a name="footnote4">[4]</a> ur Rehman, O.; Folio3 Cloud Services (Jun 23, 2025). [*Docker Use Cases: Top 15 Most Common Ways To Use Docker*](https://cloud.folio3.com/blog/docker-use-cases/)      
<a name="footnote5">[5]</a> Sonalijain; Medium (Jan 5, 2024). [*Docker Components*](https://cloud.folio3.com/blog/docker-use-cases)      
<a name="footnote6">[6]</a> Coursera Inc. (2025). [*Docker Cheat Sheet*](https://www.coursera.org/collections/docker-cheat-sheet)      
<a name="footnote7">[7]</a> Docker Inc. (2025). [*Writing a Dockerfile*](https://docs.docker.com/get-started/docker-concepts/building-images/writing-a-dockerfile/)     
<a name="footnote8">[8]</a> Avi; Geekflare (Dec 21, 2024). [*Docker Architecture and its Components for Beginners*](https://geekflare.com/devops/docker-architecture/)     
<a name="footnote9">[9]</a> Rahul; Tecadmin.net (Apr 26, 2025). [*Docker 101: An Introduction to Containerization Technology*](https://tecadmin.net/docker-introduction/)      

