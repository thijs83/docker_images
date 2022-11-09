FROM nvcr.io/nvidia/l4t-jetpack:r35.1.0



ARG ROS_PKG=ros-base
ENV ROS_DISTRO=noetic
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV RS_VERSION=2.50.0


# Change the default shell to Bash
SHELL [ "/bin/bash" , "-c" ]


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        cmake \
        build-essential \
        curl \
        wget \
        lsb-release \
        ca-certificates \
        software-properties-common \
        libssl-dev \
        libusb-1.0-0-dev \
        pkg-config \
        libgtk-3-dev \
        libglfw3-dev \
        libgl1-mesa-dev \
        libglu1-mesa-dev \    
        python3 \
        python3-dev \
        libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ~/download \
    && cd ~/download \
    && curl https://codeload.github.com/IntelRealSense/librealsense/tar.gz/v$RS_VERSION -o librealsense.tar.gz \
    && tar -xzf librealsense.tar.gz \
    && rm librealsense.tar.gz \
    && cd librealsense-$RS_VERSION \
    && mkdir build \
    && cd build \
    && cmake \
    -DCMAKE_C_FLAGS_RELEASE="${CMAKE_C_FLAGS_RELEASE} -s" \
    -DCMAKE_CXX_FLAGS_RELEASE="${CMAKE_CXX_FLAGS_RELEASE} -s" \
    -DBUILD_WITH_CUDA=true\
    -DFORCE_RSUSB_BACKEND=false\  
    -DBUILD_PYTHON_BINDINGS:bool=false \
    -DCMAKE_BUILD_TYPE=Release ../ \
    && make -j$(($(nproc)-1)) all \
    && make install 

RUN cd ~/download/librealsense-$RS_VERSION/config \
    && cp 99-realsense-libusb.rules /etc/udev/rules.d/ \
    && rm -r ~/download/librealsense-$RS_VERSION 

# Add ROS repositories
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
    
# Install ROS and rosdep
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-${ROS_PKG} \
        python3-rosdep \
        python3-catkin-tools

#initialize rosdep
RUN rosdep init \
    && rosdep update

      

ENV PYTHONPATH=$PYTHONPATH:/usr/local/lib

RUN mkdir -p ~/catkin_ws/src \
    && cd ~/catkin_ws \
    && catkin init \
    && catkin config --extend ${ROS_ROOT} \
    && cd src \
    && git clone https://github.com/thijs83/realsense-ros.git \
    && cd .. \
    && rosdep install --from-paths src --ignore-src -r -y \
    && catkin build


# Create bash script that sources environments
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash && \
          source ~/catkin_ws/devel/setup.bash && \
          exec "$@"' \
        > ~/ros_entrypoint.sh

# End with a terminal in the container and running the script to source environments
#ENTRYPOINT ["~/ros_entrypoint.sh"]
CMD ["bash"]






