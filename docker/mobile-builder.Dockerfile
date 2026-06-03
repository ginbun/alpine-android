# syntax=docker/dockerfile:1

ARG ANDROID_IMAGE=ghcr.io/alvr/alpine-android:android-36-jdk17-v2026.02.20
ARG NODE_VERSION=24
ARG PNPM_VERSION=9

FROM node:${NODE_VERSION}-alpine AS node

FROM ${ANDROID_IMAGE}
LABEL maintainer="mobile-builder"

COPY --from=node /usr/local /usr/local

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="${PNPM_HOME}:${PATH}"

RUN corepack enable && \
    corepack prepare pnpm@${PNPM_VERSION} --activate && \
    node --version && \
    pnpm --version

WORKDIR /home/android

CMD ["/bin/bash"]
