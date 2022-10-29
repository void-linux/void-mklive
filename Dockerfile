# 1) use alpine to generate a void environment
FROM alpine:3.12 as stage0
ARG REPOSITORY=https://repo-default.voidlinux.org
ARG ARCH=x86_64
COPY keys/* /target/var/db/xbps/keys/
RUN apk add ca-certificates curl && \
  curl ${REPOSITORY}/static/xbps-static-latest.$(uname -m)-musl.tar.xz | \
    tar Jx && \
  XBPS_ARCH=${ARCH} xbps-install.static -yMU \
    --repository=${REPOSITORY}/current \
    --repository=${REPOSITORY}/current/musl \
    -r /target \
    base-minimal

# 2) using void to generate the final build
FROM scratch as stage1
ARG REPOSITORY=https://repo-default.voidlinux.org
ARG ARCH=x86_64
ARG BASEPKG=base-minimal
COPY --from=stage0 /target /
COPY keys/* /target/var/db/xbps/keys/
RUN xbps-reconfigure -a && \
  mkdir -p /target/var/cache && ln -s /var/cache/xbps /target/var/cache/xbps && \
  XBPS_ARCH=${ARCH} xbps-install -yMU \
    --repository=${REPOSITORY}/current \
    --repository=${REPOSITORY}/current/musl \
    -r /target \
    ${BASEPKG}

# 3) configure and clean up the final image
FROM scratch
COPY --from=stage1 /target /
RUN xbps-reconfigure -a && \
  rm -r /var/cache/xbps

CMD ["/bin/sh"]
