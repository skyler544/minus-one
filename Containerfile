FROM quay.io/fedora-ostree-desktops/silverblue:42

COPY packages.sh /tmp/packages.sh
COPY ensure-flathub.sh /usr/local/sbin/ensure-flathub.sh
COPY mg /usr/bin/mg

RUN /tmp/packages.sh
RUN /usr/local/sbin/ensure-flathub.sh
RUN ostree container commit


RUN bootc container lint
