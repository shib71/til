## SSH

### Creating an SSH Key Pair

To create a new default SSH key pair (aka id_rsa / id_rsa.pub) \[[1]\]:

    > ssh-keygen
    Generating public/private rsa key pair.
    Enter file in which to save the key (/home/username/.ssh/id_rsa):

To create a new SSH key pair with a custom name:

    > ssh-keygen -f ~/.ssh/pair-name

### Install Your Private Key Onto a Server

To install your default public key (id_rsa.pub) onto a server \[[1]\]:

    > ssh-copy-id username@remote_host

To install a specific key onto a server:

    > ssh-copy-id -i ~/.ssh/pair-name.pub username@remote_host

This command will prompt you for a password if the server requires is.

### Configuring Specific SSH Settings for a Host

SSH Configs can be set up in ~/.ssh/config, to make sure that all SSH
connections for a specific host will use a given username, port, or
identity file. They can also be used to set up a custom "hostname" that
maps to a specific domain or IP address.

Example:

    host bm-varnish-prod-assets-01
        HostName 172.23.61.144
        Port 2020
        User root
        IdentityFile ~/.ssh/hpc_id_rsa


[1]: https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server