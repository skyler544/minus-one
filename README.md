# minus-one

This is an OCI image derived from [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) tracking "the latest Fedora release minus one," hence the name. This project takes a lot of great ideas from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://github.com/ublue-os/bluefin), and most of the design of this repository and build pipeline mimics their examples.

---

## Rationale
This image is centered around the idea of a "zero maintenance base system." Targeting Fedora minus-one is intended to strike a balance between relatively recent packages for the base system but slower update churn and fewer regressions.

## Main features
- Docker and Podman are included out-of-the-box.
- Codecs from `rpmfusion` are included out-of-the-box.
- User apps are provided via Flathub flatpaks and distrobox.
- Emacs is installed on the base image for maximal compatibility.
- No GNOME Software; [use Bazaar](https://flathub.org/en/apps/io.github.kolunmi.Bazaar) if you want a flatpak app store.

### Usage
> [!CAUTION]
> You almost certainly do not want to use this image directly. You would be much better served by forking this repo or creating a new one entirely.

If you still want to try this though, here's how to install it:
1. Install Fedora Silverblue 42 using [this iso](https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Silverblue/x86_64/iso/Fedora-Silverblue-ostree-x86_64-42-1.1.iso).
2. Follow the normal Fedora setup.
3. After creating your user, open the terminal and run the following command:
```bash
sudo bootc switch ghcr.io/skyler544/minus-one && systemctl reboot
```
> [!TIP]
> GNOME Software will immediately start trying to update you to the latest Fedora, which could block you from using `bootc`. You may therefore need to run `rpm-ostree cancel` in the terminal before using `bootc switch`.

4. Once the machine has rebooted and you've logged in for the first time, go and grab a cup of coffee while the Fedora flatpaks are replaced by Flathub equivalents and a useful set of default flatpaks are installed. This happens in the background and may take around 15 minutes depending on your internet connection speed.
5. Optionally, add your user to the `docker` and `libvirt` groups: `sudo usermod -aG docker,libvirt "$USER"`. Log out and back in for this to take effect.
6. Use your machine normally. Updates happen silently in the background; the base system is updated once a week and flatpaks are updated once a day. Base system updates require a reboot.

### Switch to signed image (optional)
This step can only be performed after rebasing to the unsigned image first. That is, perform the steps above first, then do this step. `minus-one` is signed using [sigstore/cosign](https://github.com/sigstore/cosign).
```bash
$ sudo bootc switch --enforce-container-sigpolicy ghcr.io/skyler544/minus-one
$ systemctl reboot
```

---

## Why not use bluefin?
I decided to build this derivative from upstream Silverblue to test my skills and design an image more tailored to my own workflow. After using Bluefin for around a year, I've learned a lot about container technologies and have developed a container-centric workflow that works for me. Deriving from upstream Silverblue and adding only what I want makes more sense to me than starting from Bluefin and removing things I don't use or care about.

## Credits
- [Ublue's image template](https://github.com/ublue-os/image-template) for teaching me how to build an image like this in the first place
- [Bluefin](https://github.com/ublue-os/image-template) for showing me how cool a containerized workflow can be
- [Distrobox](https://distrobox.it/) for providing such a useful tool
- [Fedora](https://fedoraproject.org/) for starting the atomic desktop initiative
