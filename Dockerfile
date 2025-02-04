FROM alpine:latest

LABEL maintainer="Chris Bensch <chris.bensch@gmail.com>"
#Original work by tynor88
#MAINTAINER tynor88 <tynor@hotmail.com>

# global environment settings
ENV RCLONE_DOWNLOAD_VERSION="current"
ENV PLATFORM_ARCH="amd64"

# s6 environment settings
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1

# install packages
RUN \
	apk update && \
	apk add --no-cache \
	ca-certificates \
	bash \
	fuse && \
	sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf

# install build packages
RUN \
	apk add --no-cache --virtual=build-dependencies \
	wget \
	curl \
	unzip && \
	# add s6 overlay
	OVERLAY_VERSION=$(curl -sX GET "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
	curl -o \
	/tmp/s6-overlay.tar.gz -L \
	"https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${PLATFORM_ARCH}.tar.gz" && \
	tar xfz \
	/tmp/s6-overlay.tar.gz -C / && \
	cd tmp && \
	wget -q http://downloads.rclone.org/rclone-${RCLONE_DOWNLOAD_VERSION}-linux-${PLATFORM_ARCH}.zip && \
	unzip /tmp/rclone-${RCLONE_DOWNLOAD_VERSION}-linux-${PLATFORM_ARCH}.zip && \
	mv /tmp/rclone-*-linux-${PLATFORM_ARCH}/rclone /usr/bin && \
	apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/community \
	shadow && \
	# cleanup
	apk del --purge \
	build-dependencies && \
	rm -rf \
	/tmp/* \
	/var/tmp/* \
	/var/cache/apk/*

# create abc user
RUN \
	groupmod -g 1000 users && \
	useradd -u 911 -U -d /config -s /bin/false abc && \
	usermod -G users abc && \
	# create some files / folders
	mkdir -p /config /data /tmpdata && \
	mkdir -p /root/.cache/rclone/cache-backend

# add local files
COPY root/ /

VOLUME ["/config", "/data"]

ENTRYPOINT ["/init"]

#CMD [ "/bin/bash" ]