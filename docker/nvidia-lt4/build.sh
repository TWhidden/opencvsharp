#/bin/bash

# This script is intended to be built on the NVIDIA Nano. At the time
# of this writing, the Nano has CUDA version 10.0 on it.

CUDAVERSION=10.0
OPENCV_VERSION=4.2.0
OPENCVSHARP_VERSION=4.2.0.20200208

#Docker Tag to create
DOCKER_TAG=traviswhidden/opencvsharp-nvidia-nano-runtime:cuda-${CUDAVERSION}-opencv-$OPENCV_VERSION
DOCKER_LATEST_TAG=traviswhidden/opencvsharp-nvidia-nano-runtime:latest

echo "Building cuda container if it doesnt exist"
cd nvidia-lt4-build

./build-builder.sh -c ${CUDAVERSION}

echo "Building opencvsharp container"
cd ../nvidia-lt4-base

# Needed for cuDNN - these must be staged in the docker directory, so they can be copied in
# Nvidia has not included these files in the base docker and sugguests that they are mounted
# but that does nto assist us when we are building under the nano.  This is only for 
# compile time. 
mkdir -p cuda/lib/aarch64-linux-gnu \
  && mkdir -p cuda/include/aarch64-linux-gnu \
  && cp /usr/include/aarch64-linux-gnu/cudnn_v7.h cuda/include/aarch64-linux-gnu/ \
  && cp /usr/lib/aarch64-linux-gnu/libcudnn.so.7.5.0 cuda/lib/aarch64-linux-gnu/ \
  && cp /usr/lib/aarch64-linux-gnu/libcudnn_static_v7.a cuda/lib/aarch64-linux-gnu/ 
  
# Build and tag
docker build . \
  --build-arg opencv_version="${OPENCV_VERSION}" \
  --build-arg opencvsharp_version="${OPENCVSHARP_VERSION}" \
  -t ${DOCKER_TAG}

# Give the latest tag
docker tag ${DOCKER_TAG} ${DOCKER_LATEST_TAG}


