# minus-one
This project builds an extensible OCI image derived from [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) tracking "the latest Fedora release minus one," hence the name. This project takes a lot of great ideas from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://github.com/ublue-os/bluefin).

## Features
### Automatic updates
- `minus-one-build.service` runs weekly via timer, builds and stages a new image
- `rebuild-mandb.service` runs weekly via timer and rebuilds the manual page index
- `update-flatpaks.service` runs daily via timer, updates all flatpaks in the system installation

### Flathub
On first boot, all Fedora flatpaks are replaced with flathub equivalents.

### nix
The package manager, for an unprivileged package manager.

### distrobox
Useful container tool, lets you install packages from many distros in a container and integrate them into the host. This includes graphical packages, so if you need packages you can't get via nix or flatpak you can just install them in a distrobox container.

### Emacs
The advanced, extensible, customizable, self-documenting editor.

## Setup
The simplest way to use the image is to run this command from an existing Fedora Silverblue 44 installation:

```sh
sudo ./bootstrap.sh --base
```

This will pull the latest published Fedora Silverblue 44 image and build `minus-one` from it, then switch to the image using `bootc`. After a reboot, you'll be running `minus-one`.

## Derivative images
The build system lets you extend or override the base image with a derivative image. Use a derivative for things like VPN software or one of rpmfusion's media drivers.

To add a derivative, create a `derivatives/<name>` directory with a `build.sh` script. `Containerfile.derivative` builds on top of the base image, copies that directory next to the shared build scripts and runs it. Pass the derivative name to the bootstrap script:

```sh
sudo ./bootstrap.sh --grimoire
```

If you want to unlock LUKS with a bluetooth keyboard, you can use the `bluetooth-pairing-archive-setup.sh` script to create an archive of your keyboard's pairing data. First pair the device in question, then set the requisite address(es) in the `.env` file. Then run
```sh
sudo ./bluetooth-pairing-archive-setup.sh
```

Your derivative build script will then require an `initramfs` rebuild step to include this bluetooth pairing data in the `initramfs`. See `derivatives/grimoire/build.sh` for an example.

Credit for this idea goes to [this comment](https://github.com/coreos/rpm-ostree/issues/4214#issuecomment-3087364057).

### Building via `systemd`

The deployed image enables a weekly `minus-one-build.timer`.

Start a build immediately with:

```sh
sudo systemctl start minus-one-build.service
```

Follow the build log with:

```sh
journalctl --follow --unit=minus-one-build.service
```

---

## Credits
- [Ublue's image template](https://github.com/ublue-os/image-template) for teaching me how to build an image like this in the first place
- [Bluefin](https://github.com/ublue-os/image-template) for showing me how cool a containerized workflow can be
- [Distrobox](https://distrobox.it/) for providing such a useful tool
- [Fedora](https://fedoraproject.org/) for starting the atomic desktop initiative
