# Notes about this docker build

 - This should be built on the Nvidia Nano, which will copy the libs from the host machine as part of the build process
 - The BUILD image (pre-built if someone needs it) can be pulled from  docker pull traviswhidden/opencvsharp-nvidia-nano-build:cuda-10.0_netcore3.1
 - The RUNTIME image (which doesnt have the .net SDK or sources) from  docker pull traviswhidden/opencvsharp-nvidia-nano-runtime:cuda-10.0_netcore3.1
 
 The runtime netcore 3.1 and build sdk 3.1 on build image.  
 
 This image will compile opencvsharp, with nvidia cuda enabled for use with the DNN libraries. 
 
 Please let me know if potential problems, docker optimziations, etc - Twitter:  @TWhidden
