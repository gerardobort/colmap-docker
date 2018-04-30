FROM nvidia/cuda 

RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libboost-all-dev \
    libsuitesparse-dev \
    libfreeimage-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libglew-dev \
    freeglut3-dev \
    qt5-default \
    libxmu-dev \
    libxi-dev \
    libatlas-base-dev \
    libsuitesparse-dev \
    git \
  && rm -rf /var/lib/apt/lists/*

# TODO squash with above command
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/

# Download and prepare sources to compile
RUN cd /tmp && \
  git clone https://github.com/colmap/colmap && \
  git clone https://ceres-solver.googlesource.com/ceres-solver && \
  wget http://bitbucket.org/eigen/eigen/get/3.2.10.tar.bz2 --no-check-certificate && \
  tar xjf 3.2.10.tar.bz2 && \
  mv eigen-eigen-b9cd8366d4e8 eigen && \
  rm -f 3.2.10.tar.bz2

WORKDIR /
RUN mkdir -p /src
RUN cp -R /tmp/* /src

# Install Eigen 3.2.10
#COPY /tmp/eigen /src/eigen
RUN mkdir -p /src/eigen/build
WORKDIR /src/eigen/build
RUN cmake .. && make && make install && make clean

RUN cd /src/ceres-solver && \
  git checkout 1.14.0

# Install Ceres Solver
#COPY /tmp/ceres-solver /src/ceres-solver
RUN mkdir -p /src/ceres-solver/build
WORKDIR /src/ceres-solver/build
RUN cmake -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF .. && make && make install && make clean 

# Install Colmap
#COPY /tmp/colmap /src/colmap
RUN mkdir -p /src/colmap/build
WORKDIR /src/colmap/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DTESTS_ENABLED=OFF .. && make && make install && make clean

# Delete GUI executable
RUN rm /usr/local/bin/colmap

# Remove unnecessary packages
RUN apt-get purge -y cmake && apt-get autoremove -y

WORKDIR /root

# Delete source files
RUN rm -r /src

CMD /bin/bash
