FROM ubuntu:20.04

ENV TZ=Asia/Taipei
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

USER root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

ARG PYTHON_VERSION_TAG=3.10.5
ARG LINK_PYTHON_TO_PYTHON3=1

# https://github.com/pypa/pip/issues/4924#issuecomment-435825490
# Set (temporarily) DEBIAN_FRONTEND to avoid interacting with tzdata
RUN apt-get -qq -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y install \
        gcc \
        g++ \
        zlibc \
        zlib1g-dev \
        libssl-dev \
        libbz2-dev \
        libsqlite3-dev \
        libncurses5-dev \
        libgdbm-dev \
        libgdbm-compat-dev \
        liblzma-dev \
        libreadline-dev \
        uuid-dev \
        libffi-dev \
        tk-dev \
        wget \
        curl \
        git \
        make \
        sudo \
        bash-completion \
        tree \
        vim \
        software-properties-common && \
    mv /usr/bin/lsb_release /usr/bin/lsb_release.bak && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY install_python.sh install_python.sh
RUN bash install_python.sh ${PYTHON_VERSION_TAG} ${LINK_PYTHON_TO_PYTHON3} && \
    rm -r install_python.sh Python-${PYTHON_VERSION_TAG}    

RUN pwd
RUN apt-get update && apt-get install -y cmake build-essential libgtk2.0-dev wget bzip2 \
                                        ca-certificates curl git vim tmux g++ gcc build-essential cmake \ 
                                        checkinstall gfortran libjpeg8-dev libtiff5-dev pkg-config yasm  \ 
                                        libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev \
                                        libxine2-dev libv4l-dev qt5-default libgtk2.0-dev libtbb-dev \
                                        libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev \
                                        libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 v4l-utils \
                                        libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev \
                                        libhdf5-dev doxygen libflann-dev libboost-all-dev proj-data libproj-dev \
                                        libyaml-cpp-dev cmake-curses-gui
#RUN apt-get update && apt-get install ffmpeg libsm6 libxext6 software-properties-common gcc \
#            libgl1-mesa-glx qt5-default -y

RUN cd / && wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz &&\
    tar -xvzf ./eigen-3.4.0.tar.gz &&\
    cd eigen-3.4.0 &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make install


RUN cd / &&\
    git clone https://github.com/opencv/opencv &&\
    cd opencv &&\
    git checkout 4.4.0 &&\
    cd / && git clone https://github.com/opencv/opencv_contrib.git &&\
    cd opencv_contrib &&\
    git checkout 4.4.0 &&\
    cd /opencv &&\
    mkdir build


RUN cd /opencv/build &&\
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_CUDA_STUBS=OFF -DBUILD_DOCS=OFF -DWITH_MATLAB=OFF -Dopencv_dnn_BUILD_TORCH_IMPORTE=OFF -DCUDA_FAST_MATH=ON  -DMKL_WITH_OPENMP=ON -DOPENCV_ENABLE_NONFREE=ON -DWITH_OPENMP=ON -DWITH_QT=ON -WITH_OPENEXR=ON -DENABLE_PRECOMPILED_HEADERS=OFF -DBUILD_opencv_cudacodec=OFF -DINSTALL_PYTHON_EXAMPLES=OFF  -DWITH_TIFF=OFF -DWITH_WEBP=OFF -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -DCMAKE_CXX_FLAGS=-std=c++11 -DENABLE_CXX11=OFF  -DBUILD_opencv_xfeatures2d=ON -DOPENCV_DNN_OPENCL=OFF -DWITH_CUDA=ON -DWITH_OPENCL=OFF &&\
    make -j6 &&\
    make install &&\
    cd /opencv/build && make install


RUN cd / 
RUN echo "pwd:" + `pwd`
RUN echo "gcc --version:" + `gcc --version`
COPY Thirdparty/Pangolin ./Pangolin
RUN apt install -y -qq python3-pip
RUN cd Pangolin && \
    ./scripts/install_prerequisites.sh recommended && \
    mkdir build && \
    cmake -B build && \
    cmake --build build && \ 
    cmake --build build -t pypangolin_pip_install && \
    ctest

# Realsense
RUN apt update && apt install usbutils libssl-dev libusb-1.0-0-dev libudev-dev pkg-config libgtk-3-dev cmake lsb-core lsb-release -y && \
    export PYTHONPATH="/usr/lib/python3/dist-packages" && \ 
    mv /usr/bin/lsb_release.bak /usr/bin/lsb_release && \ 
    mkdir -p /etc/apt/keyrings && \  
    curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
    tee /etc/apt/sources.list.d/librealsense.list && \ 
    apt-get update && apt-get install -y librealsense2-dkms librealsense2-utils librealsense2-dev

RUN cd / && mkdir ORB_SLAM3 && cd ORB_SLAM3
COPY . .

# from https://github.com/UZ-SLAMLab/ORB_SLAM3/issues/458#issuecomment-1007077761
RUN sed -i 's/++11/++14/g' CMakeLists.txt
RUN chmod +x build.sh && ./build.sh  

ARG user=shawn
ARG home=/home/$user
RUN groupadd -g 1000 $user
RUN useradd -d $home -s /bin/bash -m $user -u 1000 -g 1000 \
        && echo $user:ubuntu | chpasswd \
        && adduser $user sudo
WORKDIR $home/src
USER $user
ENV HOME $home

RUN --network=host

ENV DISPLAY :0
