FROM scratch
ADD alpine-minirootfs-3.13.5-x86_64.tar.gz /
ADD s6-overlay-amd64.tar.gz /
ADD aspnetcore-runtime-5.0.6-linux-musl-x64.tar.gz /usr/share/dotnet/

ENV S6_REL=2.2.0.3 S6_ARCH=amd64 TZ=Asia/Shanghai
ENV DOTNET_VER=5.0.6 DOTNET_ARCH=x64

LABEL base.maintainer=Roxedus
LABEL base.s6.rel=${S6_REL} base.s6.arch=${S6_ARCH}
LABEL dotnet_version=${DOTNET_VER} dotnet_arch=${DOTNET_ARCH}

RUN \
	set -eux && \
	sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
	apk add --no-cache \
		curl \
		tar \
		bash \
		ca-certificates \
		coreutils \
		shadow \
		tzdata \
		libstdc++ \
		libgcc \
		icu-libs \
		libintl \
		libcap \
		libssl1.1 \
		zlib \
		krb5-libs \
		&& \
	apk add --no-cache libgdiplus --repository https://mirrors.ustc.edu.cn/alpine/edge/testing/ && \
	groupmod -g 1000 users && \
	useradd -u 1000 -U -d /config -s /bin/false rox && \
	usermod -G users rox && \
	mkdir -p \
		/app \
		/config && \
	rm -rf /tmp/* && \
	mkdir -p /etc/cont-init.d && \
	echo IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKUFVJRD0ke1BVSUQ6LTEwMDB9ClBHSUQ9JHtQR0lEOi0xMDAwfQoKZ3JvdXBtb2QgLW8gLWcgIiRQR0lEIiByb3gKdXNlcm1vZCAtbyAtdSAiJFBVSUQiIHJveAoKZWNobyAiClVzZXIgdWlkOiAgICAkKGlkIC11IHJveCkKVXNlciBnaWQ6ICAgICQoaWQgLWcgcm94KQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tCiIKCmNob3duIC1SIHJveDpyb3ggL2FwcApjaG93biAtUiByb3g6cm94IC9jb25maWc= | base64 -d >/etc/cont-init.d/1-prep-env

RUN \
  ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
  && setcap CAP_NET_BIND_SERVICE=+eip /usr/share/dotnet/dotnet \
  && mkdir -p /etc/services.d/

RUN mkdir -p /etc/services.d/app1 && \
  echo IyEvdXNyL2Jpbi93aXRoLWNvbnRlbnYgYmFzaAoKRExMPSR7RExMOi19CgpjZCAvYXBwIHx8IGV4aXQKCmV4ZWMgXAoJczYtc2V0dWlkZ2lkIHJveCBkb3RuZXQgJERMTA== | base64 -d >/etc/services.d/app1/run 

VOLUME [ "/app","/config" ]

WORKDIR /app

ENTRYPOINT ["/init"]

EXPOSE 80