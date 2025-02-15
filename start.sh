#!/bin/bash
DOCKER_FILE_PATH=docker/Dockerfile
DOCKER_IMAGE_NAME=c8ydm-image
INSTALL_VNC=1

#DOCKER_CONTAINER_NAME=c8ydm
# construct build args from env
function env_build_arg() {
    BUILD_ARG_LIST=$(ggrep -oP '^ARG .*(?==)' "$DOCKER_FILE_PATH" | cut -d' ' -f2-)
    BUILD_ARG_ARG=''
    for BUILD_ARG in $BUILD_ARG_LIST
    do
        ENV_BUILD_ARG=$(env | grep ^$BUILD_ARG=)
        if [ ! -z "$ENV_BUILD_ARG" ]
        then
            BUILD_ARG_ARG="$BUILD_ARG_ARG --build-arg $ENV_BUILD_ARG"
        fi
    done
    echo $BUILD_ARG_ARG
}
docker build -t $DOCKER_IMAGE_NAME -f "$DOCKER_FILE_PATH" $(env_build_arg) .
# check interactivity
INTERACTIVITY_ARG='-d'
if [ "${INTERACTIVE:-}" = 1 ]
then
    INTERACTIVITY_ARG='-it'
fi

if [ "${USE_CERTS:-}" = 1 ]
then
    docker run --env-file use_certs.env \
           --rm $INTERACTIVITY_ARG \
           -v /var/run/docker.sock:/var/run/docker.sock  $DOCKER_IMAGE_NAME
else
    docker run --env-file <(env | grep C8YDM) \
           --rm $INTERACTIVITY_ARG \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -v /Users/ck/.cumulocity:/root/.cumulocity/ $DOCKER_IMAGE_NAME
fi


