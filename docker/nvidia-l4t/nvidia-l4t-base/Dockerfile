ARG CUDA_V=10.2
ARG L4T_V=32.4.4
FROM nano-build:cuda-${CUDA_V}-base-${L4T_V} AS build-native-env

WORKDIR /

# Build Args
ARG opencv_version
ARG opencvsharp_version
ARG L4T_V=32.4.4
ARG CUDNN_V=10.2
ARG CUDNN_STATIC_V=8

ENV OPENCV_VERSION=$opencv_version
ENV OPENCVSHARP_VERSION=$opencvsharp_version


# Setup OpenCV source
RUN wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
    unzip -q ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    mv opencv-${OPENCV_VERSION} opencv

# Setup opencv-contrib Source
RUN wget -q https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
    unzip -q ${OPENCV_VERSION}.zip && \
    rm ${OPENCV_VERSION}.zip && \
    mv opencv_contrib-${OPENCV_VERSION} opencv_contrib

# Needed for the CUDNN compile
COPY cuda/lib/aarch64-linux-gnu/* /usr/lib/aarch64-linux-gnu/
COPY cuda/include/aarch64-linux-gnu/* /usr/include/aarch64-linux-gnu/
COPY cuda/include/* /usr/include/
#RUN ln -L /usr/include/aarch64-linux-gnu/cudnn_v${CUDNN_STATIC_V}.h /usr/include/cudnn.h    
#RUN ln -L /usr/include/aarch64-linux-gnu/cudnn_version_v${CUDNN_STATIC_V}.h /usr/include/cudnn_version.h
RUN ln -L /usr/lib/aarch64-linux-gnu/libcudnn.so.${CUDNN_V}  /usr/lib/aarch64-linux-gnu/libcudnn.so
RUN ln -L /usr/lib/aarch64-linux-gnu/libcudnn_static_v${CUDNN_STATIC_V}.a  /usr/lib/aarch64-linux-gnu/libcudnn_static.a
RUN ln -L /usr/lib/aarch64-linux-gnu/libcublas.so.10.2.2.89  /usr/lib/aarch64-linux-gnu/libcublas.so
RUN echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64:/usr/lib/aarch64-linux-gnu/
RUN echo PATH=$PATH:/usr/local/cuda/bin

# Build OpenCV
# CUDA_ARCH_BIN = https://en.wikipedia.org/wiki/CUDA#GPUs_supported

RUN cd opencv && mkdir build && cd build && \
    cmake \
    -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_SHARED_LIBS=OFF \
    -D ENABLE_CXX11=ON \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_JAVA=OFF \
    -D BUILD_opencv_app=OFF \
    -D BUILD_opencv_java=OFF \
    -D BUILD_opencv_python=OFF \
    -D BUILD_opencv_ts=OFF \
    -D BUILD_opencv_js=OFF \
    -D WITH_GSTREAMER=OFF \ 
    -D WITH_LIBV4L=ON \
    -D WITH_FFMPEG=OFF \
    -D OPENCV_ENABLE_NONFREE=OFF \
    -D WITH_CUDA=ON \
    -D CUDA_ARCH_BIN="5.3,6.2,7.2" \
    -D CUDA_ARCH_PTX="" \
    .. && make -j4 && make install && ldconfig

WORKDIR /

# Download OpenCvSharp
#RUN git clone https://github.com/shimat/opencvsharp.git
#RUN cd opencvsharp && git fetch --all --tags --prune

ARG OPENCV_SHARP_ZIP=4.5.0.20201013

RUN wget -q https://github.com/shimat/opencvsharp/archive/${OPENCV_SHARP_ZIP}.zip && \
    unzip -q ${OPENCV_SHARP_ZIP}.zip && \
    rm ${OPENCV_SHARP_ZIP}.zip && \
    mv opencvsharp-${OPENCV_SHARP_ZIP} opencvsharp

# Install the Extern lib.
WORKDIR /opencvsharp/src
RUN mkdir /opencvsharp/make
RUN cd /opencvsharp/make && cmake -D CMAKE_INSTALL_PREFIX=/opencvsharp/make /opencvsharp/src && make -j4 && make install
RUN ls /opencvsharp/make

# Copied from the original docker
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-bionic-arm64v8 AS build-dotnet-env
COPY --from=build-native-env /opencvsharp/make/OpenCvSharpExtern/libOpenCvSharpExtern.so ./

# Install parts needed for dev
RUN apt-get update && apt-get install -y \
    unzip 

# Version of OpenCV Sharp to match the version being called
ARG OPENCV_SHARP_ZIP=4.5.0.20201013

# Setup OpenCV source
RUN wget -q https://github.com/shimat/opencvsharp/archive/${OPENCV_SHARP_ZIP}.zip && \
    unzip -q ${OPENCV_SHARP_ZIP}.zip && \
    rm ${OPENCV_SHARP_ZIP}.zip && \
    mv opencvsharp-${OPENCV_SHARP_ZIP} opencvsharp

# RUN git clone --depth 1 https://github.com/shimat/opencvsharp.git
# #RUN git clone https://github.com/TWhidden/opencvsharp.git
# RUN pwd
# RUN ls

# Install Build the C# part of OpenCvSharp
WORKDIR /opencvsharp/src/OpenCvSharp
RUN cd /opencvsharp/src/OpenCvSharp
RUN dotnet build -c Release -f netstandard2.0 

WORKDIR /opencvsharp/src/OpenCvSharp.Blob
RUN cd /opencvsharp/src/OpenCvSharp.Blob
RUN dotnet build -c Release -f netstandard2.0 

WORKDIR /opencvsharp/src/OpenCvSharp.Extensions
RUN cd /opencvsharp/src/OpenCvSharp.Extensions
RUN dotnet build -c Release -f netstandard2.0 

RUN mkdir /opencvsharp/build
WORKDIR /opencvsharp/build
RUN cp /libOpenCvSharpExtern.so .
RUN cp /opencvsharp/src/OpenCvSharp/bin/Release/netstandard2.0/* .
RUN cp /opencvsharp/src/OpenCvSharp.Blob/bin/Release/netstandard2.0/* .
RUN cp /opencvsharp/src/OpenCvSharp.Extensions/bin/Release/netstandard2.0/* .
RUN pwd
RUN ls

ARG L4T_V=32.4.4

# Base nvidia image for accel needs
FROM nvcr.io/nvidia/l4t-base:r${L4T_V}

ENV DEBIAN_FRONTEND noninteractive

# Install on the base image, the .net runtime, dependancies, etc. 
RUN cd /tmp \
  && apt-get update \
  && apt-get install -y apt-transport-https ca-certificates \
  && apt-get install -y --allow-unauthenticated \
        libgdiplus \
        libc6-dev \
        libgtk2.0-0 \
  && wget -q https://download.visualstudio.microsoft.com/download/pr/ac555882-afa3-4f5b-842b-c4cec2ae0e90/84cdd6d47a9f79b6722f0e0a9b258888/aspnetcore-runtime-5.0.0-linux-arm64.tar.gz \
  && mkdir -p /root/dotnet && tar zxf aspnetcore-runtime-5.0.0-linux-arm64.tar.gz -C /root/dotnet \
  && export DOTNET_ROOT=/root/dotnet \
  && export PATH=$PATH:/root/dotnet \
  && rm -rf /var/lib/apt/lists/* 

# Set the LD LIB PATHs for Cuda
RUN echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64:/usr/local/cuda/bin

# Copy the opencv sharp to the /app root. 
COPY --from=build-dotnet-env /opencvsharp/build /app
