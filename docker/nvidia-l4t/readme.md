# Notes about this docker build

 - This should be built on the Nvidia Nano, which will copy the libs from the host machine as part of the build process
 - The BUILD image (pre-built if someone needs it) can be pulled from  docker pull traviswhidden/opencvsharp-nvidia-nano-build:cuda-10.0_netcore3.1
 - The RUNTIME image (which doesnt have the .net SDK or sources) from  docker pull traviswhidden/opencvsharp-nvidia-nano-runtime:cuda-10.0_netcore3.1
 
 The runtime netcore 3.1 and build sdk 3.1 on build image.  
 
 This image will compile opencvsharp, with nvidia cuda enabled for use with the DNN libraries. 
 
 Please let me know if potential problems, docker optimziations, etc - Twitter:  @TWhidden
 
 Mount Instructions for Runtime:
 
  docker run  \
  --restart=always \
  --runtime nvidia \
  --device=/dev/video0:/dev/video0 \
  -v /usr/local/cuda:/usr/local/cuda \
  -v /usr/lib/aarch64-linux-gnu/libcudnn_static_v7.a:/usr/lib/aarch64-linux-gnu/libcudnn_static_v7.a \
  -v /usr/lib/aarch64-linux-gnu/libcudnn.so:/usr/lib/aarch64-linux-gnu/libcudnn.so \
  -d \
  YourImageName
 
This mounts the hardware libs inside the docker so the docker doesnt have to have a copy of it, reducing the docker image by 1-3 GB in size.
