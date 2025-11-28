# PREPARE
# ----------------------------------------------------
FROM quay.io/fedora-ostree-desktops/silverblue:42
COPY /build_files /tmp/build_files
COPY mg /usr/bin/mg


# ASSEMBLE
# ----------------------------------------------------
RUN /tmp/build_files/enable-docker.sh
RUN /tmp/build_files/enable-codecs.sh
RUN /tmp/build_files/enable-virt-manager.sh
RUN /tmp/build_files/packages.sh
RUN /tmp/build_files/ensure-flathub.sh
RUN /tmp/build_files/install-system-flatpaks.sh
RUN /tmp/build_files/automatic-updates.sh
RUN /tmp/build_files/cleanup.sh


# COMMIT
# ----------------------------------------------------
RUN ostree container commit
RUN bootc container lint
