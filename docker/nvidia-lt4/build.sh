#/bin/bash

CUDAVERSION=10.0

#Docker Tag to create
NVIDIATAG=nano:cuda-${CUDAVERSION}

echo "Building cuda container if it doesnt exist"
cd nvidia-lt4-build

./build-builder.sh -c ${CUDAVERSION}

echo "Building opencvsharp container"
cd ../nvidia-lt4-base

docker build . -t ${NVIDIATAG}
