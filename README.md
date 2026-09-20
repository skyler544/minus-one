# minus-one

This is an OCI image derived from [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) tracking "the latest Fedora release minus one," hence the name. This project takes a lot of great ideas from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://github.com/ublue-os/bluefin). This image builds locally via podman. The intended workflow is to check out this base branch and create a derivative image for the specific machine you're installing it on to add things like the correct video acceleration driver for your processor to the resulting deployment.

---

## Bootstrap a machine

Install Fedora Silverblue using [this iso](https://download.fedoraproject.org/pub/fedora/linux/releases/44/Silverblue/x86_64/iso/Fedora-Silverblue-ostree-x86_64-44-1.7.iso) and clone this repository. Check
out the branch for the machine. For example:

```sh
git switch machine/buzz-lightyear
```

Review the branch, then run its bootstrap script:

```sh
sudo ./bootstrap.sh
```

The script records the repository's absolute path in
`/etc/minus-one-build.conf`, builds `localhost/minus-one:latest`, and stages
that image with `bootc switch`.

Reboot when ready:

```sh
systemctl reboot
```

## Run the build machinery

The deployed image enables `minus-one-build.timer`. It starts the local image
build each Sunday at 03:14 and runs a missed build after the machine starts.

Start a build immediately with:

```sh
sudo systemctl start minus-one-build.service
```

Follow the build log with:

```sh
journalctl --follow --unit=minus-one-build.service
```

Check the timer with:

```sh
systemctl status minus-one-build.timer
systemctl list-timers minus-one-build.timer
```

---

## Why not use bluefin?
I decided to build this derivative from upstream Silverblue to test my skills and design an image more tailored to my own workflow. After using Bluefin for around a year, I've learned a lot about container technologies and have developed a container-centric workflow that works for me. Deriving from upstream Silverblue and adding only what I want makes more sense to me than starting from Bluefin and removing things I don't use or care about.

## Credits
- [Ublue's image template](https://github.com/ublue-os/image-template) for teaching me how to build an image like this in the first place
- [Bluefin](https://github.com/ublue-os/image-template) for showing me how cool a containerized workflow can be
- [Distrobox](https://distrobox.it/) for providing such a useful tool
- [Fedora](https://fedoraproject.org/) for starting the atomic desktop initiative
