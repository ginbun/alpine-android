# syntax=docker/dockerfile:1
# Android SDK 36 + JDK 17 + Node 24 + pnpm 10 + NDK 27 + CMake 3.30.5

ARG ANDROID_IMAGE=ghcr.io/alvr/alpine-android:android-36-jdk17-v2026.02.20

FROM ${ANDROID_IMAGE}
LABEL maintainer="ginbun"
LABEL org.opencontainers.image.description="Android SDK 36, JDK 17, Node 24, pnpm 10, NDK 27.0/27.1, CMake 3.30.5, build-tools 35/36"

ENV ANDROID_HOME=/opt/sdk \
    ANDROID_SDK_ROOT=/opt/sdk \
    CMAKE_VERSION=3.30.5 \
    GRADLE_OPTS="-Xmx4096m -XX:MaxMetaspaceSize=1024m -Dfile.encoding=UTF-8" \
    SENTRY_DISABLE_AUTO_UPLOAD=true

ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmake/3.30.5/bin"

# git, bash, curl already in alpine-android base
RUN apk add --no-cache \
    nodejs=24.14.1-r0 \
    pnpm=10.33.4-r0 \
    python3 \
    ca-certificates \
    openssl && \
    update-ca-certificates

# sdkmanager only — avoid `extras ndk` which also pulls cmake 4.x
RUN yes | sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" \
    "build-tools;35.0.0" \
    "build-tools;36.0.0" \
    "cmake;3.30.5" \
    "ndk;27.0.12077973" \
    "ndk;27.1.12297006" && \
    rm -rf "${ANDROID_SDK_ROOT}/cmake/3.22.1" && \
    "${ANDROID_SDK_ROOT}/cmake/3.30.5/bin/cmake" --version && \
    test -d "${ANDROID_SDK_ROOT}/ndk/27.1.12297006" && \
    test -d "${ANDROID_SDK_ROOT}/ndk/27.0.12077973" && \
    node --version && \
    pnpm --version

WORKDIR /workspace

CMD ["/bin/bash"]
