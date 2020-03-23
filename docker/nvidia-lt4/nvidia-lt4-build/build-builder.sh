#/bin/bash

# This script is intended to be built on the NVIDIA Nano. At the time
# of this writing, the Nano has CUDA version 10.0 on it.

#CUDA version on the Nano
CUDAVERSION=10.0

while getopts "c:" opt; do
  case ${opt} in
    c ) CUDAVERSION=${OPTARG};;
  esac
done

#Docker Tag to create
NVIDIATAG=nano-build:cuda-${CUDAVERSION}

# Inspect will return a fail if the tag does not exist, which will trigger the build
if [ $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^${NVIDIATAG}$" -c) -eq 1 ]; then
   echo "Tag ${NVIDIATAG} exists. Skipping build."

else

    CUDASOURCE=/usr/local/cuda-${CUDAVERSION}/lib64/

    if [ ! -d $CUDASOURCE ]; then
        echo "CUDA path does not exist ${CUDASOURCE}"
    else
        echo "Building with cuda path ${CUDASOURCE}"
        mkdir -p cuda/lib64 && cp -r ${CUDASOURCE} cuda/

        docker build . -t ${NVIDIATAG}
    fi  
fi