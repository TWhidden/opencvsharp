FROM nvcr.io/nvidia/l4t-base:r32.2.1 AS build-native-env

# Copy the cuda libs to the local cuda dir
COPY cuda/lib64 /usr/local/cuda-10.0/

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    software-properties-common \
    wget \
    unzip \
    curl \
    ca-certificates

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