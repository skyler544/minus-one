# PREPARE
# ----------------------------------------------------
FROM quay.io/fedora-ostree-desktops/silverblue:44

COPY build_scripts /build_scripts
COPY mg /usr/bin/mg
COPY systemd /usr/lib/systemd/system
COPY sysusers /usr/lib/sysusers.d

# ASSEMBLE
# ----------------------------------------------------
RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    bash /build_scripts/build.sh && \
    bash /build_scripts/packages.sh
RUN rm -rf /build_scripts

# COMMIT
# ----------------------------------------------------
RUN ostree container commit
RUN bootc container lint
