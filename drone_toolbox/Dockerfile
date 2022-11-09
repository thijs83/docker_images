
FROM nvcr.io/nvidia/l4t-base:r34.1.1


ARG ROS_PKG=ros-base
ENV ROS_DISTRO=noetic
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3


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
    && rm -rf /var/lib/apt/lists/*

# Add ROS repositories
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
    
# Install ROS and rosdep
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ros-${ROS_DISTRO}-${ROS_PKG} \
        python3-rosdep \
        unzip \
    && rm -rf /var/lib/apt/lists/*

#initialize rosdep
RUN rosdep init \
    && rosdep update

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-catkin-tools

# Copy files from host to container


# Extract files 

RUN mkdir -p ~/catkin_ws/src \
    && cd ~/catkin_ws \
    && catkin init \
    && catkin config --extend ${ROS_ROOT} \
    && cd src 
    
# Extract files from zip to workspace
#ADD drone_toolbox-master.tar.gz ~/catkin_ws/src
ADD drone_toolbox-master.zip /root/catkin_ws/src
ADD mocap_optitrack-dcsc_pose_stamped.zip /root/catkin_ws/src
 
RUN cd ~/catkin_ws/src \
    && unzip drone_toolbox-master.zip \
    && rm drone_toolbox-master.zip \
    && unzip mocap_optitrack-dcsc_pose_stamped.zip \
    && rm mocap_optitrack-dcsc_pose_stamped.zip \
    && git clone https://github.com/cor-drone-dev/mavros.git \
    && git clone https://github.com/ethz-asl/mav_comm.git \
    && cd .. \
    && rosdep install --from-paths src --ignore-src -r -y \
    && catkin build

RUN wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh \
    && bash ./install_geographiclib_datasets.sh

# Create bash script that sources environments
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash && \
          source ~/catkin_ws/devel/setup.bash && \
          exec "$@"' \
        > ~/ros_entrypoint.sh

# End with a terminal in the container and running the script to source environments
#ENTRYPOINT ["~/ros_entrypoint.sh"]
CMD ["bash"]


