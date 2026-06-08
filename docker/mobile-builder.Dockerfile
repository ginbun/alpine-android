# syntax=docker/dockerfile:1
# Android SDK 36 + JDK 17 + Node 24 + pnpm 10 + NDK 27 + CMake 3.30.5
# Size: alpine-android-base (not android-36) + arm64-only NDK trim + sdk cache cleanup

# Base: alpine-android-base has no dated tags (see upstream README "Versioning" section).
# Valid tags: jdk17 | latest-jdk17 — not jdk17-v2026.02.20 (that format is for android-XX images only).
ARG BASE_IMAGE=ghcr.io/alvr/alpine-android-base:jdk17

FROM ${BASE_IMAGE}
LABEL maintainer="ginbun"
LABEL org.opencontainers.image.description="Android SDK 36, JDK 17, Node 24, pnpm 10, NDK 27.0/27.1 (arm64), CMake 3.30.5, build-tools 35/36"

ENV ANDROID_HOME=/opt/sdk \
    ANDROID_SDK_ROOT=/opt/sdk \
    CMAKE_VERSION=3.30.5 \
    GRADLE_OPTS="-Xmx4096m -XX:MaxMetaspaceSize=1024m -Dfile.encoding=UTF-8" \
    SENTRY_DISABLE_AUTO_UPLOAD=true

ENV PATH="${PATH}:${ANDROID_SDK_ROOT}/cmake/3.30.5/bin"

RUN apk add --no-cache \
    nodejs~24 \
    pnpm~10 \
    python3 \
    ca-certificates \
    openssl && \
    update-ca-certificates && \
    apk del --no-cache git-lfs 2>/dev/null || true && \
    rm -rf /var/cache/apk/* /tmp/*

# Install only required SDK packages (no duplicate build-tools 36.1.0 from android-36 image)
RUN yes | sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" \
    "platforms;android-36" \
    "build-tools;35.0.0" \
    "build-tools;36.0.0" \
    "cmake;3.30.5" \
    "ndk;27.0.12077973" \
    "ndk;27.1.12297006" && \
    sdkmanager --sdk_root="${ANDROID_SDK_ROOT}" --uninstall \
      "extras;google;instantapps" 2>/dev/null || true

# arm64-v8a only — drop unused NDK ABIs (~40% per NDK) and SDK download artifacts
RUN set -eux; \
    for ndk in "${ANDROID_SDK_ROOT}"/ndk/*/; do \
      prebuilt="${ndk}toolchains/llvm/prebuilt/linux-x86_64"; \
      rm -rf \
        "${prebuilt}/sysroot/usr/lib/arm-linux-androideabi" \
        "${prebuilt}/sysroot/usr/lib/i686-linux-android" \
        "${prebuilt}/sysroot/usr/lib/x86_64-linux-android"; \
      find "${prebuilt}/lib/clang" -mindepth 4 -maxdepth 4 -type d \
        -path '*/lib/linux/*' ! -name 'aarch64' -exec rm -rf {} + 2>/dev/null || true; \
      rm -rf "${ndk}shader-tools" "${ndk}simpleperf/inferno" 2>/dev/null || true; \
    done; \
    rm -rf \
      "${ANDROID_SDK_ROOT}/cmake/3.22.1" \
      /root/.android/cache \
      "${ANDROID_SDK_ROOT}/.temp" \
      "${ANDROID_SDK_ROOT}/.downloadIntermediates" \
      /var/cache/apk/* /tmp/*; \
    "${ANDROID_SDK_ROOT}/cmake/3.30.5/bin/cmake" --version; \
    test -d "${ANDROID_SDK_ROOT}/ndk/27.1.12297006"; \
    test -d "${ANDROID_SDK_ROOT}/ndk/27.0.12077973"; \
    node --version; \
    pnpm --version

WORKDIR /workspace

CMD ["/bin/bash"]
