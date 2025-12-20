# PREPARE
# ----------------------------------------------------
FROM quay.io/fedora-ostree-desktops/silverblue:42
COPY build_files /build_files
COPY mg /usr/bin/mg


# ASSEMBLE
# ----------------------------------------------------
RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    bash /build_files/build_all.sh
RUN rm -rf /build_files


# COMMIT
# ----------------------------------------------------
RUN ostree container commit
RUN bootc container lint
