#!/bin/bash

IMAGE_NAME="tsrd"
PORT=8787

docker build --platform linux/amd64 . -t "$IMAGE_NAME"

if [ $? -ne 0 ]; then
  echo "Docker build failed. Exiting."
  exit 1
fi

docker run --rm --platform=linux/amd64 -e DISABLE_AUTH=true \
  -v "$(pwd):/home/rstudio" -d -p "$PORT:$PORT" "$IMAGE_NAME"

if [ $? -eq 0 ]; then
  echo -e "\nRStudio is running. Access it at http://localhost:$PORT\n"
else
  echo -e "\nDocker run failed. Exiting.\n"
  exit 1
fi