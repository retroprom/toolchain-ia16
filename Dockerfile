
# Use debian as a base - ubuntu should work too
ARG BASE="debian:latest"

# Create a base image with everything that we want to keep as tools
FROM ${BASE} as tools

ENV DEBIAN_FRONTEND="noninteractive"

ENV IA16_PREFIX="/opt/ia16"
ENV IA16_DEPENDS_TOOLS="ca-certificates diffutils dosbox git-core less make mtools nano patch procps psmisc unzip vim wget zip"
ENV IA16_DEPENDS_BUILD="build-essential autoconf automake bison ca-certificates flex gcc-multilib libncurses-dev libtool texinfo"

RUN apt-get update \
 && apt-get install -y --no-install-recommends ${IA16_DEPENDS_TOOLS} \
 && apt-get clean \
 && rm -rf /var/spool/apt/lists/*

# Create a build image and perform the build with build dependencies installed
FROM tools as build

RUN apt-get update \
 && apt-get install -y --no-install-recommends ${IA16_DEPENDS_BUILD} \
 && apt-get clean \
 && rm -rf /var/spool/apt/lists/*

WORKDIR /build

COPY . .

RUN export PREFIX="${IA16_PREFIX}" \
 && ./fetch.sh \
 && ./build.sh clean \
 && ./build.sh binutils \
 && ./build.sh prereqs \
 && ./build.sh gcc1 \
 && ./build.sh newlib \
 && ./build.sh causeway \
 && ./build.sh elks-libc \
 && ./build.sh elf2elks \
 && ./build.sh libi86 \
 && ./build.sh gcc2 \
 && ./build.sh extra \
 && ./build.sh sim

# Create the final image by copying the build result
FROM tools

ENV PATH="${IA16_PREFIX}/bin:${PATH}"

COPY --from=build "${IA16_PREFIX}" "${IA16_PREFIX}"

