# syntax=docker/dockerfile:1
# see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DISTRIBUTION=almalinux
ARG DISTRO_VERSN=9
ARG PLATFORM=amd64

FROM --platform=linux/${PLATFORM} ${DISTRIBUTION}:${DISTRO_VERSN}

# set the environment variables that gha sets
ENV INPUT_SOURCE_REPO_LOCATION=""
ENV INPUT_SPEC_FILE_LOCATION=""
ENV INPUT_PROVIDED_VERSION=""
ENV INPUT_PROVIDED_RELEASE=""
ENV INPUT_SIGNING_KEY_NAME=""
ENV INPUT_SIGNING_KEY_FILE=""

# Install build environment
RUN dnf install -y selinux-policy-devel rpm-build rpm-sign

COPY ./build.sh .

RUN chmod u+x build.sh

# Script to execute when the docker container starts up
ENTRYPOINT ["bash", "/build.sh"]