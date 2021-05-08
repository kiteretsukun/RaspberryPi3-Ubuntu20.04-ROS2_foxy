FROM raspi-ubuntu:20.04

RUN apt update && apt install -y curl gnupg2 lsb-release
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

RUN apt update && \
    apt install -y ros-foxy-ros-base  python3-colcon-common-extensions python3-pip && \
    pip3 install -U argcomplete
