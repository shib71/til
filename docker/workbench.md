# Docker Workbench

[This script](./docker-workbench.sh) orchestrates a VirtualBox vm that acts as a host for Docker containers.
While Linux can run Docker containers natively (and that is probably preferable in
most cases) this approach allows developers on different operating systems to run
containers in equivelent environments.

On Linux, you can copy this file to `/usr/local/bin/docker-workbench` then use the command from anywhere.

## Removing an existing workbench

Removing the VM is straightforward - just use the VirtualBox UI. However, you may find yourself getting
something like this when you run `docker-workbench.sh`:

    Docker Workbench v0.2
    Host already exists: "workbench"
    Error checking TLS connection: machine does not exist
    Configuring bootsync.sh...
    machine does not exist
    machine does not exist
    machine does not exist
    machine does not exist
    machine does not exist
    machine does not exist
    Stopping "workbench"...
    machine does not exist
    Adding /workbench shared folder...
    VBoxManage: error: Could not find a registered machine named 'workbench'
    VBoxManage: error: Details: code VBOX_E_OBJECT_NOT_FOUND (0x80bb0001), component VirtualBoxWrap, interface IVirtualBox, callee nsISupports
    VBoxManage: error: Context: "FindMachine(Bstr(pszMachineName).raw(), machine.asOutParam())" at line 925 of file VBoxManageMisc.cpp
    Starting "workbench"...
    machine does not exist

In that case you will need to manually fix the `docker-machine` settings:

    docker-machine ls # lists machines that have been set up
    docker-machine rm [name] # removes the named machine
