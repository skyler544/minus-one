# PREPARE
# ----------------------------------------------------
FROM quay.io/fedora-ostree-desktops/silverblue:44

COPY build_files /build_files
COPY mg /usr/bin/mg
COPY systemd /usr/lib/systemd/system
COPY sysusers /usr/lib/sysusers.d

# ASSEMBLE
# ----------------------------------------------------
RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    bash /build_files/build_all.sh && \
    systemctl enable minus-one-build.timer && \
    bash /build_files/cleanup.sh
RUN rm -rf /build_files

# COMMIT
# ----------------------------------------------------
RUN ostree container commit
RUN bootc container lint
