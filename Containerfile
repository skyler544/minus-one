# PREPARE
# ----------------------------------------------------
FROM quay.io/fedora/fedora-silverblue:44

COPY build_scripts /build_scripts
COPY mg /usr/bin/mg
COPY systemd /usr/lib/systemd/system
COPY sysusers /usr/lib/sysusers.d

# ASSEMBLE
# ----------------------------------------------------
ARG MINUS_ONE_BUILD_ID
RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    test -n "$MINUS_ONE_BUILD_ID" && \
    bash /build_scripts/build.sh && \
    bash /build_scripts/packages.sh
RUN rm -rf /build_scripts

# COMMIT
# ----------------------------------------------------
RUN ostree container commit
RUN bootc container lint
