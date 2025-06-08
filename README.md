# Preparation Milan Biohackaton 

## Setup
### Install Singularity
#### Linux
Follow along this [tutorial](https://pawseysc.github.io/singularity-containers/44-setup-singularity/index.html)
#### MacOS
Install VirtualBox and Vagrant:
- Load and install right version from: [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Load and install right version from: [Vagrant](https://developer.hashicorp.com/vagrant/install)

Create a dedicate directory to use as starting point to launch the box, then cd into it:
```sh
mkdir vm-singularity
cd vm-singularity
```

Get a Ubuntu Vagrant box from the [Vagrant Cloud](https://portal.cloud.hashicorp.com/vagrant/discover)
___
##### For AMD64 Chip
Load directly from the Vagrant Cloud
```sh
VM="ubuntu/bionic64"
vagrant init $VM
```
___
##### For ARM64 chip

Download a VirtualBox Vagrant ARM64 registry, like [this one](https://portal.cloud.hashicorp.com/vagrant/discover/bento/ubuntu-22.04) for instance 

Add the dowloaded "box" to vagrant:
```sh
vagrant box add <box-name> </path/to/mybox.box>
```

Initialize the Vagrant File:
```sh
vagrant init <box-name>
```
___

Enable X11 forwarding and open required communication ports (e.g. 8888) by editing the Vagrantfile in the current directory. \
Add the following lines within the main block of code, e.g. right after the line that specifies config.vm.box:
```md
# Enable X11 forwarding and open required communication port 8888
config.ssh.forward_x11 = true
config.vm.network "forwarded_port", guest: 8888, host: 8888, host_ip: "127.0.0.1"
```

Create the VM (Takes a few minutes):
```sh
vagrant up
```

Access the VM and then cd into /vagrant:
```sh
vagrant ssh
```

Inside the VM:
```sh
cd /vagrant
```
By default this is a shared directory that maps to the original launch directory in your machine. This way you can share files between the host machine and the VM, and ultimately also with the containers you will launch from in there.

Install Singularity ([Source Guide](https://docs.sylabs.io/guides/3.0/user-guide/installation.html)):
- Install dependencies
	```sh
	sudo apt-get update && sudo apt-get install -y \
		build-essential \
		libssl-dev \
		uuid-dev \
		libgpgme11-dev \
		squashfs-tools \
		libseccomp-dev \
		pkg-config
	```
	___
	
- Install Go \
	Visit the [Go download page](https://go.dev/dl/) and pick a package archive to download. Copy the link address and download with wget. Then extract the archive to /usr/local (or use other instructions on go installation page).

	Command line for MacOS with ARM64 for instance (Still within the Ubuntu VM):
	```sh
	export VERSION=1.24.4 OS=linux ARCH=arm64 && \
	wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
	sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
	rm go$VERSION.$OS-$ARCH.tar.gz
	```

	Setup Go environment:
	```sh
	echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
    echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc && \
    source ~/.bashrc
	```
	___

	Get the Singularity source project:
	```sh
	export VERSION=3.8.5 && \
	wget https://github.com/hpcng/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
	tar -xzf singularity-${VERSION}.tar.gz && \
	cd singularity-${VERSION}
	```

	Build and install:
	```sh
	./mconfig --prefix=/opt/singularity && \
	make -C builddir && \
	sudo make -C builddir install
	```

	Add Singularity to PATH and update shell:
	```sh
	export PATH="/opt/singularity/bin:$PATH" && \
	source ~/.bashrc
	```

	Show version and build configuration:
	```sh
	singularity --version
	singularity buildcfg
	```

#### Run Singularity
By default, Singularity has access to files under the `home/` directory.

Run a Singularity image - exec
```sh
singularity exec my_cont.sif python3 hello_world.py
```
It allows to run a local script using the container (i.e. all tge software, libraries, dependencies installed within the container) and it redirects the result to the host machine.
