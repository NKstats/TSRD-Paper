#!/bin/bash

IMAGE_NAME="tsrd"
DEFAULT_PASSWORD="password123"
PORT=8787

docker build --platform linux/amd64 . \
  --build-arg linux_user_pwd="$DEFAULT_PASSWORD" \
  -t "$IMAGE_NAME"

if [ $? -ne 0 ]; then
  echo "Docker build failed. Exiting."
  exit 1
fi

docker run --rm --platform=linux/amd64 \
  -e PASSWORD="$DEFAULT_PASSWORD" \
  -v "$(pwd):/home/rstudio" \
  -d -p "$PORT:$PORT" "$IMAGE_NAME"

if [ $? -eq 0 ]; then
  echo ""
  echo "RStudio is running. Access it at http://localhost:$PORT"
  echo "Username: rstudio"
  echo "Password: $DEFAULT_PASSWORD"
  echo ""
else
  echo ""
  echo "Docker run failed. Exiting."
  echo ""
  exit 1
fi