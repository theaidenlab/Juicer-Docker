############################################################
# Dockerfile to build Juicer container image
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Neva C. Durand 

# Update the repository sources list
# Install base packages: java, git, wget
RUN apt-get update && apt-get install -y \
    default-jdk \
    gawk \
    gcc \
    git \
    libz-dev \
    locales \
    make \
    unzip \
&& rm -rf /var/lib/apt/lists/*

# GAWK has the 'and' function, needed for chimeric_blacklist
RUN echo 'alias awk=gawk' >> ~/.bashrc

# Need to be sure we have this for stats
RUN locale-gen en_US.UTF-8

WORKDIR /opt/

# Install BWA
ADD https://github.com/lh3/bwa/archive/0.7.12.zip .
RUN unzip 0.7.12.zip 
RUN cd bwa-0.7.12/ && make
RUN ln -s bwa-0.7.12/bwa bwa

# Install Juicer
ADD https://github.com/theaidenlab/juicer/archive/1.5.6.zip .
RUN unzip 1.5.6.zip
RUN cd juicer-1.5.6 && chmod +x CPU/* CPU/common/* 

# Install Juicer tools
ADD http://hicfiles.tc4ga.com.s3.amazonaws.com/public/juicer/juicer_tools.1.7.5_linux_x64_jcuda.0.8.jar /opt/juicer-1.5.6/CPU/common
RUN ln -s /opt/juicer-1.5.6/CPU/common/juicer_tools.1.7.5_linux_x64_jcuda.0.8.jar /opt/juicer-1.5.6/CPU/common/juicer_tools.jar
RUN ln -s juicer-1.5.6/CPU scripts

# Grab reference for hg19
RUN mkdir references
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/references/Homo_sapiens_assembly19.fasta.ann references
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/references/Homo_sapiens_assembly19.fasta.amb references
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/references/Homo_sapiens_assembly19.fasta.bwt references
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/references/Homo_sapiens_assembly19.fasta.sa references
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/references/Homo_sapiens_assembly19.fasta.pac references
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/references/Homo_sapiens_assembly19.fasta references

# Grab restriction site for hg19
RUN mkdir restriction_sites
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/restriction_sites/hg19_DpnII.txt restriction_sites
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/restriction_sites/hg19_HindIII.txt restriction_sites
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/restriction_sites/hg19_MboI.txt restriction_sites
ADD http://juicerawsmirror.s3.amazonaws.com/opt/juicer/restriction_sites/hg19_NcoI.txt restriction_sites

# Version number contained in image
ADD VERSION .

# For sorting, LC_ALL is C
ENV LC_ALL C
ENV PATH=/opt:/opt/scripts:/opt/scripts/common:$PATH

ENTRYPOINT ["juicer.sh", "-D", "/opt"]
CMD ["-h"]


