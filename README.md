# inception

# WIP!!!! NOT FINISHED YET!

<p align="center">
    <img src="https://github.com/alx-sch/inception/blob/main/.assets/inception_badge.png" alt="inception_badge.png" />
</p>

This project focuses on system administration and containerization with **Docker**. The goal is to build a multi-container application using **Docker Compose**, featuring separate containers for an NGINX web server, a MariaDB database and a WordPress instance.

As extra features, I implemented:
- **Redis caching** with a custom **Redis Explorer** for monitoring cached data.
- **Adminer** for efficiently inspecting and managing the MariaDB database.
- **FTP** for handling files in the WordPress PHP-FPM volume.
- A **static website** built with HTML and CSS.

All services are built from scratch using custom `Dockerfiles` and communicate securely over a dedicated Docker network.

---

## Table of Contents

- [The Project](#the-project-a-dockerized-web-application-stack)
     - [Technology Stack](#technology-stack)
     - [Architecture & Request Flow](#architecture-and-request-flow)
     - [How To Use?](#how-to-use)
- [Docker Introduction](#docker-introduction)
    - [What is Docker?](#what-is-docker)
    - [History](#a-bit-of-history)
    - [Container vs VM](#containers-vs-virtual-machines)
    - [Applications](#applications)
- [Deep Dive](#docker-deep-dive)
    - [Docker Components](#docker-components)
    - [Docker Workflow](#docker-workflow)
    - [Docker File](#the-dockerfile)
    - [Docker Compose](#XXX)
    - [Docker Commands](#docker-commands)
    - [Total Cleanup](#total-cleanup)
- [Setting Up the VM](#setting-up-the-vm)
- [Setting Up Inception](#setting-up-inception)

---

## The Project: A Dockerized Web Application Stack

In this project, I containerize a full-stack web application using Docker. The goal is to learn about system administration, container orchestration and the architecture of modern web services by setting up a WordPress site with NGINX and a MariaDB database from scratch, without using pre-existing official images. The entire stack is deployed within a Debian virtual machine, creating a fully isolated and production-like server environment from the ground up. 

This project emphasizes the importance of isolated environments and the automation of service deployment. By using Docker, it is ensured that the application is portable, scalable and runs consistently across any environment. The `docker-compose.yml` file serves as the master blueprint, defining and connecting the individual services on a private network to form a single, cohesive application.

---

### Technology Stack
- **Host Environment:** Virtual Machine running Debian 13 (Trixie)
- **Orchestration:** Docker & Docker Compose
- **Web Server / Reverse Proxy:** NGINX with TLSv1.3
- **Application:** WordPress with PHP-FPM
- **Database:** MariaDB
- **Automation:** Makefile

---

### Architecture and Request Flow

The "big picture" of the Inception application is an orchestrated stack of services, each running in its own isolated container. All communication between services happens over a private Docker network, with NGINX being the sole public-facing entry point.

```
+----------+      HTTPS     +-------------+      HTTP      +----------------+      SQL       +-------------+
|          | -------------> |             | -------------> |                | -------------> |             |
|  User's  |                |    NGINX    |                |   WordPress    |                |   MariaDB   |
|  Browser | <------------- | (Port 443)  | <------------- |   (PHP-FPM)    | <------------- | (Database)  |
|          |      HTML      |             |      HTML      |                |      Data      |             |
+----------+                +-------------+                +----------------+                +-------------+
  ^                                |                                |                              |
  |                                |                                |                              |
  +--------------------------------+--------------------------------+------------------------------+
                                       (Data stored in persistent Docker Volumes)
```

#### Step-by-Step Breakdown:

1. **The User Arrives (Browser -> NGINX)**
   - A user opens their web browser and types in your address (e.g., `https.aschenk.42.fr`).
   - This request travels across the internet and hits your server. **The only container exposed to the outside world is NGINX.** It acts as the front door, security guard and receptionist all in one (a reverse proxy).
   - NGINX receives the `HTTPS` request. Its first job is **TLS Termination**. It handles the complex encryption/decryption, so WordPress doesn't have to.

3. **The Hand-off (NGINX -> WordPress)**
   - After decrypting the request, NGINX looks at its configuration. It sees that requests for this domain should be handled by the WordPress service.
   - It then forwards a simple, unencrypted `HTTP` request over the **private Docker network** to the WordPress container. The WordPress container is not exposed to the internet; it only talks to NGINX.

5. **The Brain at Work (WordPress -> MariaDB)**
   - The WordPress container receives the request. It's running a PHP processor (`PHP-FPM`) which executes the WordPress application code.
   - WordPress determines what content is needed to build the page (e.g., the latest blog posts, comments, page content). This data is not in the WordPress container; it's in the database.
   - WordPress opens a connection to the MariaDB container, again over the private Docker network. It connects using the predefined configuration (hostname, database user, database to access, etc.).
  
4. **The Vault Opens (MariaDB -> WordPress)**
    - The MariaDB container receives the SQL query from WordPress (e.g., `SELECT * FROM wp_posts...`).
    - It executes the query, gathers the results and sends the data back to the WordPress container. Like WordPress, the MariaDB container is completely isolated from the internet. It only talks to WordPress.

5. **The Assembly and Return (WordPress -> NGINX -> Browser)**
   - WordPress receives the data from MariaDB. The PHP engine uses this data to assemble the final HTML page.
   - WordPress sends the complete, rendered HTML page back to NGINX.
   - NGINX receives the plain HTML, re-encrypts it for `HTTPS` and sends it back across the internet to the user's browser.
   - The user's browser renders the HTML and they see the beautiful website :)

---

### How to Use?

XXX

---

## Docker Introduction

### What is Docker?

Docker is a platform for developing, shipping and running applications in **containers**. A Docker container can hold any application and its dependencies (code, libraries, system tools, configuration) and run on any machine that has Docker installed.    

This solves the classic problem of "it works on my machine" by packaging the entire application environment into a single, predictable and portable unit.

---

### A Bit of History

Docker was first introduced by Solomon Hykes at PyCon 2013 -- check out his legendary five-minute minute talk [here](https://www.youtube.com/watch?v=wW9CAH9nSLs)<sup><a href="#footnote1">[1]</a></sup>.     
Originally an internal project at his PaaS company dotCloud, it was quickly open-sourced once its potential became clear.

While Docker popularized containers, the underlying technology has been part of the Linux kernel for years in the form of **cgroups** (which limit resource usage) and **namespaces** (which isolate processes, filesystems, etc.)<sup><a href="#footnote2">[2]</a></sup>.    

Docker’s innovation was to create a user-friendly set of tools, a strong community and useful services (public registries, ready-made base images and orchestration tools like Compose and Kubernetes), making those kernel features approachable for everyday developers.

---

### Containers vs. Virtual Machines

A common point of confusion is the difference between a container and a virtual machine (VM):

- **A VM** virtualizes the hardware. It runs a full-blown guest operating system with its own kernel on top of your host OS. Think of it as a complete, separate house with its own plumbing, electricity and foundation.
  
- **A Docker Container** virtualizes the operating system. All containers on a host share the host's OS kernel but have their own isolated view of the filesystem and processes. Think of them as apartments in a single building: They all share the building's main foundation and utilities but are completely separate living spaces.

This makes containers incredibly lightweight, fast to start and efficient compared to VMs.

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

Docker is the standard way modern applications are built, shipped and run<sup><a href="#footnote3">[3</a>,<a href="#footnote4">4]</sup>. Common applications are:

- **Standardized Development Environments**       
    By packaging an application and its dependencies into a container, companies ensure that their software runs identically everywhere: on a developer's laptop, on a testing server and in production.

- **CI/CD Pipelines**        
   Docker is a cornerstone of modern **Continuous Integration and Continuous Deployment (CI/CD)**. When a developer pushes new code, automated systems use Docker to:
    1. Build the code inside a clean, consistent container.
    2. Run automated tests inside that container.
    3. If tests pass, push the new container image to a registry.
    4. Automatically deploy the updated container to production servers.
 
- **Microservices Architecture**      
    Docker is the perfect platform for microservices, an architectural style where a large application is broken down into smaller, independent services. Each microservice (e.g., user authentication, payment processing, product catalog) runs in its own container. This makes the application easier to develop, scale and maintain, as different teams can work on different services independently.

- **Cloud and Multi-Cloud Deployment**     
    Docker containers can run on any cloud provider (AWS, Google Cloud, Azure, etc.) without modification. This portability gives companies the freedom to move applications between different cloud environments without being locked into a single vendor. It's the foundation of modern "cloud-native" applications.

---

## Docker Deep Dive

### Docker Components

Overview of multiple Docker components<sup><a href="#footnote5">[5]</a></sup>:

- **Docker Engine:** The core of Docker. It's a client-server application with three main components: a long-running background service called the **Docker daemon**, a **REST API** that specifies interfaces for programs to talk to the daemon and the **Docker client**.
 
- **Docker Client:** The primary way users interact with Docker. It's the command-line interface (CLI) tool (e.g., `docker run`, `docker build`) that sends commands to the Docker daemon.
 
- **Docker Registries:** A storage and distribution system for Docker images. **Docker Hub** is the default public registry, but companies often host private ones for their own images.
  
- **Docker Images:** Read-only, executable blueprints that contain everything needed to run an application: the code, a runtime, libraries, environment variables and configuration files.
  
- **Dockerfile:** A text file containing a set of instructions on how to build a Docker image. The `docker build` command reads this file to assemble the image layer by layer.

- **Docker Volumes:** The mechanism for persisting data generated by Docker containers. Volumes are managed by Docker and exist outside the container's lifecycle, ensuring your data is safe even if the container is removed.

- **Docker Compose:** A tool for defining and running multi-container applications. It uses a single YAML file (`docker-compose.yml`) to configure all of the application's services, networks and volumes, which can then be started or stopped with a single command.

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
        <b>OpenStack:</b> Cloud platform for managing virtual machines, storage and networks; can host Docker infrastructure but is separate from Docker itself.<sup><a href="#footnote8">[8]</a></sup>.
    </span>
</p>

---

### Docker Workflow

1. You write a **Dockerfile**, a text file containing instructions to build a Docker image.   
2. You use the **Docker Client** (`docker build`) to send these instructions to the **Docker Daemon**.
3. The Docker Daemon executes the instructions, creating a **Docker Image**. This image is a lightweight, stand-alone, executable blueprint of your application's environment.
4. You use the Docker Client (`docker run`) to tell the Docker Daemon to create and start a **Container** from that image. The container is a live, running instance of your application.

**Docker Compose** streamlines and automates this workflow, especially for applications with multiple services:

1. You write a Dockerfile for each service (e.g., one for your web server, one for your database).
2. You create a single `docker-compose.yml` file. In this file, you define all your services, tell Compose where to find each service's Dockerfile and describe how they should be connected (e.g., networking, volumes).
3. You use the **Docker Compose CLI** (`docker-compose up`) to send the entire application definition to the Docker Daemon.
4. The Docker Daemon then reads the `docker-compose.yml file` and:
    - **Builds** a Docker Image from each Dockerfile (if it doesn't already exist).
    - **Creates and starts** a Container from each image, automatically **connecting** them on a shared network so they can communicate.

Docker Compose acts as an orchestrator for the Docker Engine, allowing you to manage the entire build-and-run lifecycle for a multi-container application with a single command.

----

### The Dockerfile

Text-based document that is used to create a container image. As an example, the following Dockerfile would produce a ready-to-run Python application<sup><a href="#footnote7">[7]</a></sup>:

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

- `FROM <image>` - this specifies the base image, so what you start with. This could be a minimal OS to build on or a ready-to-use image for a specific application.
- `WORKDIR <path>` - this instruction specifies the "working directory" or the path in the image where files will be copied and commands will be executed.
- `COPY <host-path> <image-path>` - this instruction tells the builder to copy files from the host and put them into the container image.
- `RUN <command>` - this instruction tells the builder to run the specified command.
- `ENV <name> <value>` - this instruction sets an environment variable that a running container will use.
- `EXPOSE <port-number>` - this instruction sets configuration on the image that indicates a port the image would like to expose.
- `USER <user-or-uid>` - this instruction sets the default user for all subsequent instructions.
- `ENTRYPOINT ["<executable>", "<param1>"]` - this sets the main command. It typically executes a script or a binary, but can also be a command.
- `CMD ["<command>", "<arg1>"]` - this instruction sets the default command a container using this image will run. This can be overridden when providing a command when starting the container (`docker run my-image <CMD>`).

Note: When multiple `ENTRYPOINT` and `CMD` are specified in a Dockerfile, all but the very last are ignored.

---

### Docker Compose

XXXXX

---

### Docker Commands    

The most common Docker commands you'll use with a `Dockerfile` are for building an image from the file and running a container based on that image<sup><a href="#footnote6">[6]</a></sup>:

- `docker build`     
  This command builds a Docker image from a `Dockerfile` and a "context". The context is the set of files at the path specified (in this case, `.`).
  
  ```bash
  docker build -t your-image-name:tag .
  ```
  
  - `-t`: This flag stands for **"tag"**. It allows you to name your image and give it a version tag (e.g., `my-app:1.0`). If you don't provide a tag, it defaults to `latest`.
  - `your-image-name:tag`: The name and tag you choose for your image.
  - `.`: The period specifies the **build context**. It tells Docker to use the current directory's files for the build.

- `docker run`    
  Once your image is built, you use this command to start a container from it.
  
  ```bash
  docker run -d -p 8080:80 your-image-name:tag
  ```
  
  - `-d`: Runs the container in **detached mode** (in the background). Without this, your terminal will be attached to the container's log output.
  - `-p 8080:80`: The **port mapping** flag. It maps port `8080` on your host machine to port `80` inside the container. The format is `HOST_PORT:CONTAINER_PORT`.
  - `your-image-name:tag`: The name of the image you want to run.

- `docker images`      
  This command lists all the Docker images you have on your local machine. It's useful for seeing the images you've built.
  
  ```bash
  docker images
  ```
  
  This will show a table with your images, including repository name, tag, image ID, creation date and size.

- `docker ps`    
  This command shows you all the containers that are currently running.
  
  ```bash
  docker ps
  ```
  
  To see *all* containers, including those that have stopped, add the `-a` flag:
  ```bash
  docker ps -a
  ```

- `docker rmi`     
  If you want to remove an image from your system, you use this command.

  ```bash
  docker rmi your-image-name:tag
  ```
  
  You cannot remove an image if it's currently being used by a container. You'll need to stop and remove the container first using `docker stop <container_id>` and `docker rm <container_id>`.

---

### Total Cleanup

This is a powerful "total cleanup" routine. It removes *ALL* Docker resources to free up space:

```bash
# Stop all containers
docker stop $(docker ps -q)

# Then prune everything (images, containers, unnamed volumes)
docker system prune -a --volumes

# Also remove named volumes
docker volume rm $(docker volume ls -q)
```

Here's a single-line version achieving the same result:
```bash
docker stop $(docker ps -a -q) && docker system prune -af --volumes && docker volume rm $(docker volume ls -q)
```

Check the disk space consumed by different Docker ressources with:
```bash
docker system df
```

---
# Project Setup

## Setting up the VM

### 1. Check Edit Rights for `/etc/hosts` File

The goal is to successfully access your WordPress website, exposed via NGINX on port 443 (`-p 443:443`), using the custom domain `yourlogin.42.fr`. Since this domain is not public, you must configure **Local Domain Name Resolution** (Local DNS) by editing the `/etc/hosts` file on the machine initiating the request

- **Accessing the site from the Host Machine**:    
  This scenario relies on **NAT Port Forwarding** configured in the VM software. This rule tells your host machine to redirect traffic from its own loopback address to the VM.     
  - **VM Software Configuration:**     
    The VM software must be configured with a NAT network adapter and a Port Forwarding rule:
       - Host IP: `127.0.0.1` (or blank, which defaults to all interfaces)
       - Host Port: `443`
       - Guest IP: leave blank (VirtualBox resolves it automatically); you may also add the VM's internal IP address
       - Guest Port: `443` 
  - **Edit the Hosts File on the Host Machine:**      
    Use `sudo` privileges to edit the `/etc/hosts` file on your **main host computer** and add the following entry:
    ```bash
    # The Host Machine's NAT rule directs this loopback traffic to the VM.
    127.0.0.1   yourlogin.42.fr
    ```
  💡 **Note:** In this case, setting up a minimal, command-line-only server VM is sufficient.

- **Accessing the site from the VM**:       
  If you are on a restricted host machine and cannot edit `/etc/hosts`, you can still edit this file within your VM and eventually access the website via the VM's browser. Since the NGINX container exposes port `443` to all interfaces (`0.0.0.0:443`) on the VM, you still use the loopback address.
  - **Edit the Hosts File on the VM:**     
    Use `sudo` to edit the `/etc/hosts` file inside the **VM** and add the following entry:
    ```bash
    # The VM's Loopback IP is used for direct Docker NATing inside the VM.
    127.0.0.1   yourlogin.42.fr
    ```
  💡 **Note:** In this case, you'd also need to install a desktop environment and GUI when setting up the VM.

--- 

### 2. Install the Debian VM

Using a Debian **minimal install** is recommended for this project. Download a net-install ISO from the [Debian website](https://www.debian.org/distrib/) (choose **64-bit PC netinst iso**).

Create a new VM in **Oracle VirtualBox** (free, open-source) with the following specifications:
- Choose a directory with enough disk space (42 Network: `/sgoinfre/`)
- Load the ISO image.
- **Base Settings:**
    - **Type**: Linux / **Version**: Debian (64-bit)
    - **Subtype**: Debian
    - **Skip Unattended Installation**: ✔
    - **Memory**: 2048 MB
    - **Processors**: 1 CPU
    - **Disk**: 20 GB (dynamic allocation is fine)

When the installer runs:
- **Software Selection:**
    - **If you have access rights to the hosts machine's `/etc/hosts` (see above):** Deselect Debian desktop environment and any graphical options such as GNOME to keep the VM light and fast.
    - Make sure **SSH server** and **standard system utilities** are selected.
- **Boot Loader:** Install the GRUB boot loader when prompted.

--- 

### 3. Enable SSH Access

Working directly in the VM console is possible but might be inconvient. By creating a "tunnel" from the host to the VM's SSH port, you can work from your host machine’s terminal and editor.

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

#### Set Up Port Forwarding in VirtualBox
1. Shut down the VM.
2. In **Settings → Network**, ensure the adapter is set to NAT.
3. Click Port Forwarding and add a rule:
      - **Name:** e.g. ssh-access
      - **Protocol:** TCP
      - **Host Port**: e.g. `2222` (choose a free port)
      - **Guest Port**: `22`
      - **Guest IP**: leave blank (VirtualBox resolves it automatically); you may also add the VM's internal IP address confirmed above
       
#### Connect from the Host

Start the VM (you don’t need to log in at the console) and, on the host:

```bash
ssh <vm_username>@localhost -p 2222
```

#### SSH Config Shortcut

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

#### Use Your Local Editor (e.g. VS Code)
- Install the **Remote – SSH** extension on VS Code.
- Click the “><” icon in the lower-left corner (“Open a Remote Window”).
- Choose **Connect to Host → myvm** and enter the VM user’s password.

You can now edit files and run terminals in VS Code as if you were working locally.

---- 

### 4. Prepare the Debian Host

To prepare the minimal Debian server installation for the project and the Docker Engine installation, follow these steps:

#### Add User to Sudo Group

Docker commands typically require elevated privileges. To give your user sudo rights:

```bash
# Log in as root
su -

# Install sudo
apt install sudo

# Add your user to the sudo group (replace with your username)
usermod -aG sudo <your_username>

# Verify membership
groups your_username
```

You should see `sudo` listed in the groups. Type `exit` to leave the root shell, then log out and back in for the change to take effect.

#### Update the System and Install Common Tools

Keep the packages current:

```bash
sudo apt update && sudo apt upgrade -y
```

Install a few utilities you’ll use often:

```bash
sudo apt install curl git make -y
```

- `git` helps manage project files from a repository.
- `curl` is handy for downloading installation scripts (used when installing the Docker Engine).
- `make` is used to execute Makefiles.

---

### 5. Install Docker Engine

Follow Docker’s official guide for the most reliable installation:
[Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)

Use the **“Install using the apt repository”** method. After installation, confirm that Docker is working:

```bash
sudo docker run hello-world
```

If you see the “Hello from Docker!” message, your setup is complete.

#### Add to User to Docker Group

Docker commands must be run by the root user or via sudo by default.   
To simplify things, you can add your user to the `docker` group, allowing you to run all `docker` commands without needing the `sudo` prefix.

```bash
# Log in as root
su -

# Add your user to the docker group (replace with your username)
usermod -aG docker <your_username>

# Verify membership
groups your_username
```

---

## Setting up Inception

### Test Isolated Containers First

While the ultimate goal of Inception is to create a multi-container application orchestrated by Docker Compose, the foundation of a stable system lies in building and testing services in isolation first. This workflow can be thought of as "unit testing" for infrastructure.

Before we can connect all the services, we ideally prove that each one (MariaDB, WordPress and NGINX) is individually robust, secure and functional. This isolates variables, making debugging the final, integrated application much easier.

---

### MariaDB

MariaDB is a free and open-source Relational Database (using tables, rows and columns) by the original developers of MySQL. It stores the WordPress data (like users, settings and posts) in organized tables using SQL commands.

The goal is to set up a correctly initialized and persistent MariaDB container. The current `init_db.sh` uses the secure method of reading passwords from Docker secret files (`cat /run/secrets/...`). To allow for isolated testing of the container as described below (without Docker Compose), the script needs to use environment variables for passwords (`{$DB_ROOT_PASSWORD}`, `{$DB_PASSWORD}`) instead.

The files used to build the MariaDB image and container are found in [`srcs/requirements/mariadb`](https://github.com/alx-sch/inception/tree/main/srcs/requirements/mariadb):

- `Dockerfile`: This is the main blueprint. It starts from a base Debian image, installs the MariaDB server packages and copies our custom configuration and scripts into the image. It also defines the `ENTRYPOINT` and `CMD` to ensure that the container starts gracefully.
  
 - `tools/init_db.sh`: This is the core logic of the container. It's a script that runs every time the container starts. It checks if the database has already been initialized. If not, it uses the `mariadbd --bootstrap` command to securely set up the database, create the WordPress user, grant the correct permissions and change filesystem ownership to the `mysql` user. If the database already exists, the script does nothing.

- `conf/50-server.cnf`: This configuration file overrides the default `bind-address` setting to `0.0.0.0`, allowing the database to accept connections from other containers (like WordPress) over the private Docker network.

1. **Building the Image**    

    First, we use the `Dockerfile` to build a custom image.
  
    ```bash
    docker build -t mariadb:inception ./srcs/requirements/mariadb
    ```

    Check the Docker build output: All steps should complete successfully (each step is shown in blue when it succeeds). Docker's layer caching will make subsequent builds almost instant if no files have changed.

2. **Running the Isolated Container**

    Next, we run the container using `docker run`. This is where we simulate the environment that Docker Compose will eventually provide, passing in all necessary configurations as environment variables (`-e`) and attaching a persistent volume (`-v`):
    
   ```bash
    docker run -d --name mariadb \
      -p 3306:3306 \
      -v db_data:/var/lib/mysql \
      -e DB_NAME=wordpress \
      -e DB_USER=db_user \
      -e DB_PASSWORD=user_pass \
      -e DB_ROOT_PASSWORD=root_pass \
      mariadb:inception
    ```

3. **Verification and Testing**

    With the container running, we perform a series of checks to validate its state and functionality.
    
     **A. Log Analysis (`docker logs`)**

    The first step is to check the container's logs to ensure the initialization script behaved as expected. On the first run with an empty volume, the logs should show the full initialization sequence.

    ```bash
    docker logs mariadb
    ```

    The output must show all `echo` messages from the `init_db.sh` script, confirming each stage of the setup was reached.

   **B. Interactive Testing (`docker exec`)**

   Next, gain access to the container via an interactive shell to perform live tests from the perspective of an administrator and the application itself.

    ```bash
    docker exec -it mariadb bash
    ```

    Once inside, we verify the following:
   
    - **Root Access:** Can we log in as the MariaDB `root` user with the correct password? (`mysql -u root -p`)
    - **Application User Access:** Can we log in as the dedicated `wp_user` and connect to the `wordpress` database? (`mysql -u db_user -p wordpress`)
    - **Permissions and Security:** When logged in as `wp_user`, do `SHOW DATABASES;` and `SHOW GRANTS;` confirm that the user has `ALL PRIVILEGES` on the `wordpress` database and can see nothing else?
    -  **Full CRUD Test:** As the `db_user`, verify that you can perform a complete Create, Read, Update and Delete cycle (`CREATE TABLE`, `INSERT`, `SELECT`, `UPDATE`, `DELETE`, `DROP TABLE`)? This is the ultimate proof that all permissions are correct. Learn more about these SQL commands [here](https://datalemur.com/blog/sql-create-read-update-delete-drop-alter)<sup><a href="#footnote10">[10]</a></sup> and [here](https://www.almabetter.com/bytes/cheat-sheet/mariadb)<sup><a href="#footnote11">[11]</a></sup>.

    ⚠️ **Note on GitHub Codespaces:**

    Due to a specific incompatibility between this container and the Codespaces runtime, `docker exec` may fail. Connecting directly to the database from the Codespaces terminal is a reliable workaround:

    ```bash
    mysql -h 127.0.0.1 -u wp_user -p wordpress
    ```

    You can now proceed with the permission and CRUD tests.

    **C. Persistence Test (`docker stop` / `docker rm`)**

    Finally, ensure that the data survives in the allocated volume even when the container is completely removed.

   1. **Stop and remove the container:** `docker stop mariadb` and then `docker rm mariadb`. The container is now gone.

   2. **Re-run the container:** Use the exact same `docker` run command from step 2, ensuring you attach the same volume (`-v db_data:/var/lib/mysql`).

   3. **Verify the logs:** The new container's logs (`docker logs mariadb`) must now show the message `Database directory is not empty. Skipping initialization.`. This proves our script's logic is correct and that the data persisted in the volume.

After all these checks pass, we can consider the MariaDB service fully validated and ready for integration. All other service containers are validated using a similar methodology. Once each component is proven to be stable and correct, we proceed to the final integration phase: orchestrating the entire application with Docker Compose.

---

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout inception.key -out inception.crt
```

- `openssl req`: Starts the utility to create a certificate request (or, with -x509, a self-signed certificate).
- `x509`: Creates a **self-signed certificate** instead of a request.
- `nodes`: **No DES/No Encryption:** Disables the use of a passphrase for the private key. This is critical for Docker, as Nginx cannot start automatically if it needs a password to read the key.
- `days 365`: Sets the certificate's validity period to 365 days.
- `newkey rsa:2048`: Generates a new **Private Key** using the RSA algorithm with a length of 2048 bits (standard security).
- `keyout inception.key`: **Output File for the Private Key (Secret):** This is your `ssl_priv_key` file.
- `out inception.crt`: **Output File for the Certificate (Public Key):** This is your `ssl_pub_key` file.

#### Prompts You Must Answer

When you run the command, OpenSSL will prompt you to enter information to embed into the certificate. Since this is for development, the values don't need to be perfectly accurate, but the **Common Name** is important:

- **Country Name (2 letter code):** `DE`
- **State or Province Name:** `Berlin`
- **Locality Name (city):** `Berlin`
- **Organization Name:** `42 Berin`
- **Organizational Unit Name:** `Inception Project`
- **Common Name (FQDN of your server):** `aschenk.42.fr` (Crucial: Must match your Nginx `server_name`)
- **Email Address:** `XXX@aschenk.42.fr`

---

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
<a name="footnote10">[10]</a> Singh, N.; DataLemur(Jan 19, 2025). [*SQL CRUD: CREATE, READ, UPDATE, DELETE, DROP, and ALTER in SQL*](https://datalemur.com/blog/sql-create-read-update-delete-drop-alter)
<a name="footnote11">[11]</a> Abhani, J; AlmaBetter (Dec 15, 2024). [*MariaDB Cheat Sheet*](https://www.almabetter.com/bytes/cheat-sheet/mariadb)  

The project badge is from [this repository](https://github.com/ayogun/42-project-badges) by Ali Ogun.
