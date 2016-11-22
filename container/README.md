
DNA Subway Apps
===============

This is the current implementation of the DNA Subway Green Line app catalog, implemented as [Agave API](https://agaveapi.com) applications based on [Docker](https://docker.com) containers. It is extended to also be able to leverage [Singularity](http://singularity.lbl.gov) containers, which are userspace containers use on for HPC or other multitenant environments. The repository is organized as follows:

```
├── build
│   └── cyverse
├── bundles
│   ├── cuffdiff
│   ├── cufflinks
│   ├── cuffmerge
│   ├── fastqc
│   ├── fastx
│   ├── scripts
│   ├── tophat
│   ├── tophat-refprep
│   └── wc
└── templates
    ├── bundle
    └── json
```

Container Structure and Function
--------------------------------

The DNA Subway container (currently ```cyverse/dnasub_apps```) is built atop a base container (currently ```cyverse/dnasub_base```) with most critical, OS-level dependencies installed. The ```dnasub_core``` image is based on Centos 6.8.

```
+-------------+
| dnasub_apps |
+-------------+
     | |
+-------------+
| dnasub_base |
+-------------+
      |
+-------------+
| dnasub_lang |
+-------------+
      |
+-------------+
| dnasub_core |
+-------------+
```

Base Container
--------------

The base container has a default ENTRYPOINT that prints the local ENV, lists the current working directory, and may take few other utility actions in the future. The default entrypoint is designed to not do much beyond act to ensure that all containers based on it are executable and return useful information when that happens. Here's an example output from the ```dnasub_base``` container:

```
% docker run cyverse/dnasub_base

##################################################
APP: DNALC Container base
AUTHOR: Matthew Vaughn
LICENSE: BSD-3-Clause
VERSION: 0.7.0
AGAVE_TENANT: iplantc.org
PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin
--------------------------------------------------
ENVIRONMENT:
HOSTNAME=13aebf69502e
TMPDIR=/tmp
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin
PWD=/home
HOME=/root
SHLVL=2
no_proxy=*.local, 169.254/16
AGAVE_TENANT=iplantc.org
--------------------------------------------------
SYSTEM CONTEXT:
UNAME: Linux 13aebf69502e 4.4.30-moby #1 SMP Tue Nov 8 10:29:28 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
VOLUMES:
Filesystem     1K-blocks     Used Available Use% Mounted on
none            61893412 45382240  13344096  78% /
tmpfs            1022484        0   1022484   0% /dev
tmpfs            1022484        0   1022484   0% /sys/fs/cgroup
/dev/vda2       61893412 45382240  13344096  78% /etc/resolv.conf
/dev/vda2       61893412 45382240  13344096  78% /etc/hostname
/dev/vda2       61893412 45382240  13344096  78% /etc/hosts
shm                65536        0     65536   0% /dev/shm
tmpfs            1022484        0   1022484   0% /proc/kcore
tmpfs            1022484        0   1022484   0% /proc/timer_list
tmpfs            1022484        0   1022484   0% /proc/sched_debug
PWD: /home
PWDTREE:
.
└── bio.R

0 directories, 1 file
--------------------------------------------------
IMAGE ENTRYPOINT: /usr/local/bin/default_entrypoint.sh
##################################################
```

Application Structure and Function
----------------------------------

Each application is constructed from a *bundle*, and assumes a specific workflow for interacting with the application container. Each cont

Here's an example, from the *fastx* application:

```.
├── app.json
├── env-fastx.sh
├── job.json
├── run-fastx.sh
├── test-fastx.sh
└── wrap-fastx.sh
```

_JSON files_: The ```app.json``` is the current Agave representation for the app, where parameters, inputs, outputs, resourcing, deployment details,, etc is described and the ```job.json``` is a sample job file for running an example instance of the app. Neither is template generated or maintained as part of the build process at present.


Build base containers from source
---------------------------------

```
make docker-base
```

Build apps container from source
--------------------------------

```
make docker-apps
```

Deploy to Agave
---------------

```
make deploy
```


```Last Updated: 11/22/2016```