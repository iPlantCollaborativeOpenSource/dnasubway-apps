# docker build --rm -t cyverse/dnasub_lang .

FROM cyverse/dnasub_core
MAINTAINER Matthew Vaughn <vaughn@tacc.utexas.edu>

ENV _APP DNALC Language Support
ENV _AUTHOR Matthew Vaughn
ENV _VERSION 0.7.0

RUN yum -y groupinstall "Development tools" && \
    yum clean all

# Functional packaes
RUN yum -y  install \
            sqlite \
            cairo-1.8.8-6.el6_6.x86_64 \
            java-1.7.0-openjdk.x86_64 \
            && yum clean all

# Dev libraries
RUN yum -y  install \
            zlib-devel \
            bzip2-devel \
            openssl-devel \
            ncurses-devel \
            readline-devel \
            curl-devel \
            libxml2-devel \
            libpng-devel \
            libtiff-devel \
            libjpeg-turbo-devel  \
            cairo-devel \
            java-1.7.0-openjdk-devel \
            && yum clean all

# Assumes package archive files in local 'cache' directory
RUN mkdir /tmp/cache
COPY ./cache/* /tmp/cache/

RUN ls /tmp/cache

# Install curl 7.5.1.0, over-ride system curl
# We do this because R can't interact with the BioC and
# CRAN infrastructure if its built against outdated
# versions of libcurl - wierd DNS and SSL errors abound
RUN cd /tmp/cache && \
    tar zxf curl-7.51.0.tar.gz && \
    cd curl-7.51.0 && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    ldconfig && \
    cd /tmp/cache && rm -rf curl-7.51.0*

# Python 2.7.1 into /opt to avoid breaking yum
RUN cd /tmp/cache && \
    tar xf Python-2.7.1.tar.bz2 && \
    cd Python-2.7.1 && \
    ./configure --prefix=/opt && \
    make && make altinstall /opt/bin/python2.7 && \
    ldconfig && \
    cd /tmp/cache && rm -rf Python-2.7.1*

# Pip and virtualenv
RUN cd /tmp/cache && \
    tar xf distribute-0.6.27.tar.gz && \
    cd distribute-0.6.27 && \
    /opt/bin/python2.7 setup.py install && \
    /opt/bin/easy_install-2.7 virtualenv && \
    cd /tmp/cache && rm -rf distribute-0.6.27*


# R 3.2.1 with graphics, modern libcurl, and cairo support
RUN cd /tmp/cache && \
    tar -zxf R-3.2.1.tar.gz && \
    cd R-3.2.1 && \
    ./configure --prefix=/opt --with-curl=/opt/lib --with-x=no && \
    make && \
    make install && \
    cd /tmp/cache && rm -rf R-3.2.1*

# Bioconductor base
#RUN mkdir -p /tmp/rstats
#ENV TMPDIR /tmp/rstats
COPY bio.R .
RUN /opt/bin/Rscript bio.R
#ENV TMPDIR /tmp
