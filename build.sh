set -ex
# docker hub username
USERNAME=aidenlab
# image name
IMAGE=juicer
docker build -t $USERNAME/$IMAGE:latest .
