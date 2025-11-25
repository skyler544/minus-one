FROM quay.io/fedora-ostree-desktops/silverblue:42

COPY packages.sh /tmp/packages.sh
COPY ensure-flathub.sh /tmp/ensure-flathub.sh
COPY mg /usr/bin/mg

RUN /tmp/packages.sh
RUN /tmp/ensure-flathub.sh
RUN ostree container commit


RUN bootc container lint
