FROM debian:11-slim

# install prerequisites
RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --yes --no-install-recommends netbase nfs-common dbus \
    nfs-ganesha nfs-ganesha-proxy nfs-ganesha-vfs \ 
    gpg dirmngr gpg-agent \
    && apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /run/rpcbind /exports /var/run/dbus \
    && touch /run/rpcbind/rpcbind.xdr /run/rpcbind/portmap.xdr \
    && chmod 755 /run/rpcbind/* \
    && chown messagebus:messagebus /var/run/dbus

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.asc /tini.asc
RUN set -x \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --verify /tini.asc \
    && rm -rf "$GNUPGHOME" /tini.asc \
    && chmod +x /tini

# NFS ports and portmapper
EXPOSE 2049

# /export is commonly exported
VOLUME /exports

# Add startup script
COPY start.sh /

# Start Ganesha NFS daemon by default
ENTRYPOINT ["/tini", "--"]
CMD ["/start.sh"]
