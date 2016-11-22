# docker build --rm -t cyverse/dnasub_apps .

FROM cyverse/dnasub_base
MAINTAINER Matthew Vaughn <vaughn@tacc.utexas.edu>
ENV _APP DNALC DNA Subway Apps
ENV _VERSION 0.7.0

RUN mkdir /opt/scripts
ADD scripts /opt/scripts
RUN chmod -R a+rx /opt/scripts/*
ENV DNASUB_SCRIPTS /opt/scripts

# Assumes archive files are cached in ./cache folder
RUN mkdir /home/cache
COPY cache/* /home/cache/

# Install Samtools 0.1.19
RUN cd /home/cache && tar -jxvf samtools-0.1.19.tar.bz2 && cd samtools-0.1.19 && make && cp samtools /opt/bin/ && cp bcftools/bcftools /opt/bin/ && cp misc/* /opt/bin/ && ldconfig && rm -rf /home/samtools-0.1.19 && rm /home/cache/samtools-0.1.19.tar.bz2

# Install Picard 1.120
RUN cd /home/cache && unzip picard-tools-1.120.zip && mv picard-tools-1.120 /opt && rm -rf /home/cache/picard* && chmod -R a+r /opt/picard-tools-1.120
ENV DNASUB_PICARD_DIR=/opt/picard-tools-1.120

# Install TopHat 2.0.11.1
# https://ccb.jhu.edu/software/tophat/downloads/tophat-2.0.11.Linux_x86_64.tar.gz
RUN cd /home/cache && tar -zxf tophat-2.0.11.Linux_x86_64.tar.gz && mv tophat-2.0.11.Linux_x86_64/* /opt/bin/ && rm -rf /home/cache/tophat*

# Install Bowtie 2.2.1.1
RUN cd /home/cache && unzip bowtie2-2.2.1-linux-x86_64.zip && mv bowtie2-2.2.1/* /opt/bin/ && cd /tmp && rm -rf /home/cache/bowtie2*

# Install Cufflinks 2.1.0
RUN cd /home/cache && tar -zxf cufflinks-2.1.0.Linux_x86_64.tar.gz && mv cufflinks-2.1.0.Linux_x86_64/* /opt/bin/ && rm -rf /home/cache/cufflinks*

# Install FastQC 0.11.4
RUN cd /home/cache && unzip fastqc_v0.11.4.zip && mv FastQC /opt/ && chmod -R a+rx /opt/FastQC/fastqc && rm -rf /home/cache/fastqc*
ENV DNASUB_FASTQC_DIR=/opt/FastQC

# Install FASTX_toolkit
RUN cd /home/cache && tar xzf libgtextutils-0.7.tar.gz && \
	cd libgtextutils-0.7 && ./configure && make && make install && ldconfig && \
	cd /home/cache && tar xjf fastx_toolkit-0.0.14.tar.bz2 && cd fastx_toolkit-0.0.14 && \
	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH && \
	./configure --prefix=/opt && make && make install && \
	cd /home/cache && \
	rm -rf /home/cache/*

# Install Agave CLI
RUN git clone https://bitbucket.org/agaveapi/cli.git /opt/bin/agave-cli && chmod -R a+r /opt/bin/agave-cli/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/opt/bin/agave-cli/bin
# Automatically config root user for iplantc.org tenant
RUN /opt/bin/agave-cli/bin/tenants-init -t $AGAVE_TENANT

ADD ./runners /opt/bin

# Install cummerbund
# These are not identical to the ones on Lonestar or in the bundle
COPY bio.R .
RUN /opt/bin/Rscript bio.R

# Just in case
RUN chmod -R a+rx /opt/bin/*
