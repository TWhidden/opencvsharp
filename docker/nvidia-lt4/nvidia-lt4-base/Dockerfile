FROM nano-build:cuda-10.0 AS build-native-env

WORKDIR /

# ENV OPENCV_VERSION=4.1.2

# Setup OpenCV source
# RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
#     unzip ${OPENCV_VERSION}.zip && \
#     rm ${OPENCV_VERSION}.zip && \
#     mv opencv-${OPENCV_VERSION} opencv

# Some issues building out of Master and 4.1.2 doesnt have the cuda extensions, so using a commit that has been tested and works.
RUN git clone https://github.com/opencv/opencv.git && cd opencv && git checkout b6a58818bb6b30a1f9d982b3f3f53228ea5a13c1 && cd /


# Setup opencv-contrib Source
# RUN wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip && \
#     unzip ${OPENCV_VERSION}.zip && \
#     rm ${OPENCV_VERSION}.zip && \
#     mv opencv_contrib-${OPENCV_VERSION} opencv_contrib

# Matching head used in the compile
RUN git clone https://github.com/opencv/opencv_contrib.git && cd opencv_contrib && git checkout 64961f3794d4da9619da486f14024aa84ebb4ae2 && cd /

# Needed for the CUDNN compile
COPY cuda/lib/aarch64-linux-gnu/* /usr/lib/aarch64-linux-gnu/
COPY cuda/include/aarch64-linux-gnu/* /usr/include/aarch64-linux-gnu/
RUN ln -L /usr/include/aarch64-linux-gnu/cudnn_v7.h /usr/include/cudnn.h    
RUN ln -L /usr/lib/aarch64-linux-gnu/libcudnn.so.7.5.0  /usr/lib/aarch64-linux-gnu/libcudnn.so
RUN ln -L /usr/lib/aarch64-linux-gnu/libcudnn_static_v7.a  /usr/lib/aarch64-linux-gnu/libcudnn_static.a
RUN echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64:/usr/lib/aarch64-linux-gnu/
RUN echo PATH=$PATH:/usr/local/cuda/bin

# Build OpenCV
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
RUN git clone https://github.com/shimat/opencvsharp.git
RUN cd opencvsharp && git fetch --all --tags --prune

# Install the Extern lib.
WORKDIR /opencvsharp/src
RUN mkdir /opencvsharp/make
RUN cd /opencvsharp/make && cmake -D CMAKE_INSTALL_PREFIX=/opencvsharp/make /opencvsharp/src && make -j4 && make install
RUN ls /opencvsharp/make

# Copyed from the original docker
FROM mcr.microsoft.com/dotnet/core/sdk:3.0-bionic-arm64v8 AS build-dotnet-env
COPY --from=build-native-env /opencvsharp/make/OpenCvSharpExtern/libOpenCvSharpExtern.so ./
RUN git clone https://github.com/shimat/opencvsharp.git
RUN pwd
RUN ls

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


#FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-bionic-arm64v8
FROM nvcr.io/nvidia/l4t-base:r32.2.1

# Install on the base image, the .net runtime, dependancies, etc. 
RUN cd /tmp \
  && apt-get update \
  && apt-get install -y apt-transport-https \
  && echo "Installing all apps" \
  && apt-get install -y --allow-unauthenticated \
   		libgdiplus \
        libc6-dev \
        libgtk2.0-0 \
  && wget https://download.visualstudio.microsoft.com/download/pr/e7c893c5-726a-40aa-8a13-7ae6f1e3ee4e/8ba7467756a3fb1778f02f1ca98ca1ee/aspnetcore-runtime-3.1.0-linux-arm64.tar.gz \
  && mkdir -p /root/dotnet && tar zxf aspnetcore-runtime-3.1.0-linux-arm64.tar.gz -C /root/dotnet \
  && export DOTNET_ROOT=/root/dotnet \
  && export PATH=$PATH:/root/dotnet \
  && rm -rf /var/lib/apt/lists/* 

# Set the LD LIB PATHs for Cuda
RUN echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64:/usr/local/cuda/bin

# Copy the opencv sharp to the /app root. 
COPY --from=build-dotnet-env /opencvsharp/build /app
