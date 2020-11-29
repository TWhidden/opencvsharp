#/bin/bash

# This script is intended to be built on the NVIDIA Nano. At the time
# of this writing, the Nano has CUDA version 10.0 on it.

#CUDA version on the Nano
CUDAVERSION=10.2
L4T_V=32.4.4
CUDNN_V=8.0.0
CUDNN_STATIC_V=8
FORCE=0

while getopts "c:u:s:l:f:" opt; do
  case ${opt} in
    c ) CUDAVERSION=${OPTARG};;
    u ) CUDNN_V=${OPTARG};;
    s ) CUDNN_STATIC_V=${OPTARG};;
    l ) L4T_V=${OPTARG};;
    f ) FORCE=${OPTARG};;
  esac
done

#Docker Tag to create
NVIDIATAG=nano-build:cuda-${CUDAVERSION}-base-${L4T_V}

# Inspect will return a fail if the tag does not exist, which will trigger the build
if [ $FORCE != 1 ] && [ $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^${NVIDIATAG}$" -c) -eq 1 ]; then
   echo "Tag ${NVIDIATAG} exists. Skipping build."

else

    CUDASOURCE=/usr/local/cuda-${CUDAVERSION}/lib64/

    if [ ! -d $CUDASOURCE ]; then
        echo "CUDA path does not exist ${CUDASOURCE}"
    else
        echo "Building with cuda path ${CUDASOURCE}"
        mkdir -p cuda/lib64 && cp -r ${CUDASOURCE} cuda/

        docker build \
          --build-arg L4T_V="${L4T_V}" \
          --build-arg CUDNN_V="${CUDNN_V}" \
          --build-arg CUDNN_STATIC_V="${CUDNN_STATIC_V}" \
          --build-arg CUDA_V="${CUDAVERSION}" \
          . -t ${NVIDIATAG}
    fi  
fi