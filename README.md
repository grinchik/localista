# LOCALISTA

The **Localista** project enables reproducible provisioning of an immutable Linux development machine on macOS for **devcontainers**, without the need to install Docker or Podman.


## Prerequisite

1. macOS running on Apple Silicon.
1. [Homebrew](https://brew.sh) package manager installed.
1. Required dependencies installed via Homebrew:
    1. `brew install qemu`
    1. `brew install xz`
    1. `brew install butane`


## Setup

1. From the page [Download Fedora CoreOS](https://fedoraproject.org/coreos/download?stream=stable&arch=aarch64#download_section), download the aarch64-compatible QEMU image (qcow2.xz) to the project directory.
1. Update the `QCOW2_XZ_IMAGE_FILE_NAME` variable in the `Makefile` to reflect the name of the downloaded image file.
1. Run the following command in a Terminal and wait until the login prompt appears:
```shell
make localista
```


## Using

Once the virtual machine is up and running, use the following command to connect via SSH:
```shell
ssh -p 2222 core@localhost
```

For convenience, add the following configuration to the `.ssh/config` file:
```
Host localista
    HostName localhost
    Port 2222
    User core
    IdentityFile ~/.ssh/id_ed25519
    UseKeychain yes
```

This configuration allows you to simply run:
```
ssh localista
```


## Helpful Resources

1. [Fedora CoreOS Documentation](https://docs.fedoraproject.org/en-US/fedora-coreos/)
1. [Butane documentation](https://coreos.github.io/butane/)
