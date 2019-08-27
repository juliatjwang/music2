#This is the dockerfile for juliatjwang/music2:fixed_withR
#Adapted from felixhu's dockerfile for music2.

FROM ubuntu:xenial

RUN apt-get update && apt-get install -y  build-essential libnss-sss\
    git \
    cmake \
    curl \
    cpanminus \
    libbz2-dev \
    libgtest-dev \
    libbam-dev \
    zlib1g-dev \
    python

# Install samtools
COPY ./bin/samtools /usr/local/bin/

# Install Calc Roi Covg
COPY ./bin/calcRoiCovg /usr/local/bin/

# Install bedtools
COPY ./bin/bedtools /usr/local/bin/

# Install Joinx
COPY ./bin/joinx /usr/local/bin/

# Intall Perl modules
RUN cpanm Test::Most \
    && cpanm Statistics::Descriptive \
    && cpanm Statistics::Distributions \
    && cpanm Bit::Vector

# Install MuSiC2
COPY ./MuSiC2-0.2.tar.gz /tmp/
RUN cpanm /tmp/MuSiC2-0.2.tar.gz

# Ensure workdir
RUN tar zxvf /tmp/MuSiC2-0.2.tar.gz -C /tmp
WORKDIR /tmp/MuSiC2-0.2

# Echo MuSiC2 info
RUN music2 help | cat

# Install extras such as vim
RUN apt-get update && apt-get install -y vim
RUN apt-get update && apt-get install -y r-base
