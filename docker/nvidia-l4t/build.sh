#/bin/bash

# This script is intended to be built on the NVIDIA Nano. At the time
# of this writing, the Nano has CUDA version 10.0 on it.

CUDAVERSION=10.2
L4T_V=32.4.4
CUDNN_V=8.0.0
CUDNN_STATIC_V=8
OPENCV_VERSION=4.5.0
OPENCVSHARP_VERSION=4.5.0
OPENCVSHARP_ZIP_VERSION=4.5.0.20201013
FORCE_REBUILD_BASE=0
OPENCV

#Docker Tag to create
DOCKER_TAG=traviswhidden/opencvsharp-nvidia-nano-runtime:l4t-r${L4T_V}-cuda-${CUDAVERSION}-opencv-$OPENCV_VERSION
DOCKER_LATEST_TAG=traviswhidden/opencvsharp-nvidia-nano-runtime:latest

echo "Building cuda container if it doesnt exist"
cd nvidia-l4t-build

./build-builder.sh -c ${CUDAVERSION} -u ${CUDNN_V} -s ${CUDNN_STATIC_V} -l ${L4T_V} -f ${FORCE_REBUILD_BASE}

echo "Building opencvsharp container"
cd ../nvidia-l4t-base

# Needed for cuDNN - these must be staged in the docker directory, so they can be copied in
# Nvidia has not included these files in the base docker and sugguests that they are mounted
# but that does nto assist us when we are building under the nano.  This is only for 
# compile time. 
mkdir -p cuda/lib/aarch64-linux-gnu \
  && mkdir -p cuda/include/aarch64-linux-gnu \
  && cp -u /usr/include/*.h cuda/include/ \
  && cp -u /usr/include/aarch64-linux-gnu/cudnn_v${CUDNN_STATIC_V}.h cuda/include/aarch64-linux-gnu/ \
  && cp -u /usr/include/aarch64-linux-gnu/cudnn_version_v${CUDNN_STATIC_V}.h cuda/include/aarch64-linux-gnu/ \
  && cp -u /usr/lib/aarch64-linux-gnu/libcudnn.so.${CUDNN_V} cuda/lib/aarch64-linux-gnu/ \
  && cp -u /usr/lib/aarch64-linux-gnu/libcudnn_static_v${CUDNN_STATIC_V}.a cuda/lib/aarch64-linux-gnu/ \
  && cp -u /usr/lib/aarch64-linux-gnu/libcublas_static.a cuda/lib/aarch64-linux-gnu/ \
  && cp -u /usr/lib/aarch64-linux-gnu/libcublas.so.10.2.2.89 cuda/lib/aarch64-linux-gnu/ 

  
# Build and tag
docker build . \
  --build-arg opencv_version="${OPENCV_VERSION}" \
  --build-arg opencvsharp_version="${OPENCVSHARP_VERSION}" \
  --build-arg L4T_V="${L4T_V}" \
  --build-arg CUDNN_V="${CUDNN_V}" \
  --build-arg CUDNN_STATIC_V="${CUDNN_STATIC_V}" \
  --build-arg CUDA_V="${CUDAVERSION}" \
  --build-arg OPENCV_SHARP_ZIP="${OPENCVSHARP_ZIP_VERSION}" \
  -t ${DOCKER_TAG}

if [ $? != 0 ]; then
  echo "Failed"
  exit 1;
fi


# Give the latest tag
#docker tag ${DOCKER_TAG} ${DOCKER_LATEST_TAG}


