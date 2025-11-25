# PREPARE
# ----------------------------------------------------
FROM quay.io/fedora-ostree-desktops/silverblue:42
COPY /build_files /tmp/build_files
COPY /signing/policy.json /etc/containers/policy.json
COPY /signing/skyler544.yaml /etc/containers/registries.d/skyler544.yaml
COPY cosign.pub /etc/pki/containers/cosign.pub
COPY mg /usr/bin/mg


# ASSEMBLE
# ----------------------------------------------------
RUN /tmp/build_files/github-release-install.sh sigstore/cosign x86_64
RUN /tmp/build_files/enable-docker.sh
RUN /tmp/build_files/packages.sh
RUN /tmp/build_files/ensure-flathub.sh
RUN /tmp/build_files/cleanup.sh


# COMMIT
# ----------------------------------------------------
RUN ostree container commit
RUN bootc container lint
