# syntax=docker/dockerfile:1

ARG ANDROID_IMAGE=ghcr.io/alvr/alpine-android:android-36-jdk17-v2026.02.20

FROM ${ANDROID_IMAGE}
LABEL maintainer="mobile-builder"

RUN apk add --no-cache \
    nodejs=24.14.1-r0 \
    pnpm=10.33.4-r0 && \
    node --version && \
    pnpm --version

WORKDIR /home/android

CMD ["/bin/bash"]
