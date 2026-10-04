# minus-one
This is an OCI image derived from [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) tracking "the latest Fedora release minus one," hence the name. This project takes a lot of great ideas from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://github.com/ublue-os/bluefin).

## Features
### Automatic updates
- `minus-one-build.service` runs weekly via timer, builds and stages a new image
- `update-flatpaks.service` runs daily via timer, updates all flatpaks in the system installation

### Flathub
On first boot, all Fedora flatpaks are replaced with flathub equivalents.

### nix
The package manager, for an unprivileged package manager.

### distrobox
Useful container tool, lets you install packages from many distros in a container and integrate them into the host. This includes graphical packages, so if you have something you can't get via flatpak you can just install them in a distrobox container.

### Emacs
The advanced, extensible, customizable, self-documenting editor.

## Setup
The simplest way to use the image is to run this command from an existing Fedora Silverblue 44 installation:

```sh
sudo ./bootstrap.sh --base
```

This will pull the latest published Fedora Silverblue 44 image and build `minus-one` from it in podman's rootful storage, then switch to the image using `bootc`. After a reboot, you'll be running `minus-one`.

## Complications
If you have a machine that needs some more specific handling like VPN software or one of rpmfusion's media drivers, you can set that up by creating a `Containerfile.<machine>` and a corresponding <machine> directory with the necessary build script. In that case, you will need to pass your `<machine>` name to the bootstrap script:

```sh
sudo ./bootstrap.sh --grimoire
```

If you want to unlock LUKS with a bluetooth keyboard, you can use the `bluetooth-pairing-archive-setup.sh` script to create an archive of your keyboard's pairing data. First pair the device in question, then set the requisite address(es) in the `.env` file. Then run
```sh
sudo ./bluetooth-pairing-archive-setup.sh
```

Your build script or `Containerfile.<machine>` will then require an `initramfs` rebuild step to include this bluetooth pairing data in the `initramfs`. See `grimoire/build.sh` for an example.

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

## Why not use bluefin?
I decided to build this derivative from upstream Silverblue to test my skills and design an image more tailored to my own workflow. After using Bluefin for around a year, I've learned a lot about container technologies and have developed a container-centric workflow that works for me. Deriving from upstream Silverblue and adding only what I want makes more sense to me than starting from Bluefin and removing things I don't use or care about.

## Credits
- [Ublue's image template](https://github.com/ublue-os/image-template) for teaching me how to build an image like this in the first place
- [Bluefin](https://github.com/ublue-os/image-template) for showing me how cool a containerized workflow can be
- [Distrobox](https://distrobox.it/) for providing such a useful tool
- [Fedora](https://fedoraproject.org/) for starting the atomic desktop initiative
