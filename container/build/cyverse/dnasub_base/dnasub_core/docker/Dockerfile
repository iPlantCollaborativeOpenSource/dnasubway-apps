# docker build --rm -t cyverse/dnasub_core .

FROM centos:centos6.8
MAINTAINER Matthew Vaughn <vaughn@tacc.utexas.edu>

ENV _APP DNALC Centos 6.8 base
ENV _AUTHOR Matthew Vaughn
ENV _LICENSE BSD-3-Clause
ENV _VERSION 0.7.0
ENV AGAVE_TENANT iplantc.org

# Set up /usr/local and /opt
RUN mkdir -p /opt/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin
RUN echo "/opt/lib" > /etc/ld.so.conf.d/opt.conf && echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf && ldconfig

WORKDIR /home

# Add specific user, which we will run as if not specified

# Basics
RUN yum -y install git curl wget which bzip2 tree && yum clean all

ADD default_entrypoint.sh /usr/local/bin
RUN chmod a+x /usr/local/bin/default_entrypoint.sh
ENTRYPOINT /usr/local/bin/default_entrypoint.sh
