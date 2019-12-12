FROM nvcr.io/nvidia/l4t-base:r32.2.1 AS build-native-env

# Copy the cuda libs to the local cuda dir
# These files are staged from the build script when building on the Nvidia Jetson Nano
COPY cuda/lib64 /usr/local/cuda-10.0/

# Install parts needed for dev
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    wget \
    unzip \
    curl \
    ca-certificates \
    git

# Install opencv dependencies
RUN cd ~
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    gfortran \
    libjpeg8-dev \
    libpng-dev \
    software-properties-common

# libjaspter1 is needed by OpenCV, but not in this nvidia build container
RUN wget http://launchpadlibrarian.net/376191785/libjasper1_1.900.1-debian1-2.4ubuntu1.2_arm64.deb && dpkg -i libjasper1_1.900.1-debian1-2.4ubuntu1.2_arm64.deb

# Install additional OpenCV depends
RUN apt-get install -y \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libv4l-dev

RUN cd /usr/include/linux
RUN ln -s -f ../libv4l1-videodev.h videodev.h
RUN cd ~
RUN apt-get install -y \
    libgtk2.0-dev \
    libtbb-dev \
    qt5-default \
    libatlas-base-dev \
    libfaac-dev \
    libmp3lame-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libavresample-dev \
    x264 \
    v4l-utils

# Build .net 3.1 Base so we dont need to build it again later.
RUN cd /tmp \
    && wget https://download.visualstudio.microsoft.com/download/pr/5a4c8f96-1c73-401c-a6de-8e100403188a/0ce6ab39747e2508366d498f9c0a0669/dotnet-sdk-3.1.100-linux-arm64.tar.gz \
    && mkdir -p /root/dotnet && tar zxf dotnet-sdk-3.1.100-linux-arm64.tar.gz -C /root/dotnet \
    && export DOTNET_ROOT=/root/dotnet \
    && export PATH=$PATH:/root/dotnet  
