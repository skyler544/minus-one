FROM quay.io/fedora-ostree-desktops/silverblue:42

COPY /build_files /tmp/build_files
COPY mg /usr/bin/mg

RUN /tmp/build_files/packages.sh
RUN /tmp/build_files/ensure-flathub.sh
RUN /tmp/build_files/enable-docker.sh
RUN /tmp/build_files/post-install.sh

RUN bootc container lint
