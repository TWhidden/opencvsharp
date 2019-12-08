#/bin/bash

#CUDA version on the Nano
CUDAVERSION=10.0

while getopts "c:" opt; do
  case ${opt} in
    c ) CUDAVERSION=${OPTARG};;
  esac
done

#Docker Tag to create
NVIDIATAG=nano-build:cuda-${CUDAVERSION}

if [ $(docker ps -a --format '{{.Names}}' | grep -E "^${NVIDIATAG}$" -c) -eq 0 ]; then

    CUDASOURCE=/usr/local/cuda-${CUDAVERSION}/lib64/

    if [ ! -d $CUDASOURCE ]; then
        echo "CUDA path does not exist ${CUDASOURCE}"
    else
        echo "Building with cuda path ${CUDASOURCE}"
        mkdir -p cuda/lib64 && cp -r ${CUDASOURCE} cuda/

        docker build . -t ${NVIDIATAG}
    fi
fi