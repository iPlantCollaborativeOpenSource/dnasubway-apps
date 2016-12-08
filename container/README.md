
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

================================================================================
AGAVE_TENANT: iplantc.org
APP: DNALC Container base
AUTHOR: Matthew Vaughn
LICENSE: BSD-3-Clause
VERSION: 0.7.0
BIN_PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin
LIBRARY_PATH: 
--------------------------------------------------------------------------------
ENVIRONMENT:
HOSTNAME=a9ecc91190c4
TERM=xterm
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin
PWD=/home
HOME=/root
SHLVL=2
no_proxy=*.local, 169.254/16
AGAVE_TENANT=iplantc.org
--------------------------------------------------------------------------------
SYSTEM CONTEXT:
UNAME:  Linux a9ecc91190c4 4.4.30-moby #1 SMP Tue Nov 8 10:29:28 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
VOLUMES:
Filesystem     1K-blocks     Used Available Use% Mounted on
none            61893412 45811640  12914696  79% /
tmpfs            1022484        0   1022484   0% /dev
tmpfs            1022484        0   1022484   0% /sys/fs/cgroup
/dev/vda2       61893412 45811640  12914696  79% /etc/resolv.conf
/dev/vda2       61893412 45811640  12914696  79% /etc/hostname
/dev/vda2       61893412 45811640  12914696  79% /etc/hosts
shm                65536        0     65536   0% /dev/shm
tmpfs            1022484        0   1022484   0% /proc/kcore
tmpfs            1022484        0   1022484   0% /proc/timer_list
tmpfs            1022484        0   1022484   0% /proc/sched_debug
PWD: /home
PWDTREE:
.
`-- bio.R

0 directories, 1 file
--------------------------------------------------------------------------------
IMAGE ENTRYPOINT: /usr/local/bin/default_entrypoint.sh
================================================================================
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

*Bundle Files*

_wrap-<appname>.sh_: This is now the template file for an Agave .ipcexe job script, but can also be used in other contexts (in fact, we use it as part of the app's *test* action). In the context of an Agave job, this file is treated as a template into which parameter and input values are substituted by the Agave runtime. When executed locally, variable assignments come in via environment variables set by the caller. Within the wrapper script, all input and parameter variables must be serialized out to an .env file that can be read by the Docker runtime. They are also serialized out to a file that can be sourced to set up a Singularity runtime. The wrapper behvaior can be modified by setting the following variables:

* TYPE : Must be ```docker``` or ```singularity``` (default: ```singularity```)
* DOCKER_ORG: Defaults to ```cyverse```
* DOCKER_IMAGE: Defaults to ```dnasub_apps```
* SINGULARITY_IMAGE: Defaults to ```DOCKER_ORG-DOCKER_IMAGE.img```

The assumption for runing based on Docker under Agave is that the Docker image is available either on the system or via Dockerhub. For Singularity, the assumption is that a Singularity image based on the Docker image is present in the ```deploymentPath``` of the Agave application and that said image has been *compressed with bzip2*. Our build environment demonstrates automated production of a properly formatted ```cyverse-dnasub_apps.img.bz2``` image. 

The wrapper invokes an app-specific entrypoint defined by ```run-<appname>.sh``` and bundled into the apps image. At present, we do not inspect or honor any resource restrictions or requirements sent by Agave when executing a Docker container. This will change in the future. 

_run-<appname>.sh_: This is an entrypoint file that is copied into the app container. It relies on the container runtime environment to set environment variables that are evaluated in the runner, and for any input data files to be staged either into a volume mount bound to ```WORKDIR``` or into the container itself (not recommended). It relies on a volume mount or other means to export data written by the container to the host. The exit status for the run script will be propagated out to the host container runtime for error handling and reporting. 

*Helpful Hint* If one is porting an existing Agave template to become an entrypoint runner, it is critical to add a shebang line at the script's beginning, and also that ```run-<appname>.sh``` has its executable bit set (```chmod a+x run-<appname.sh>```). This is because Docker and other container runtimes expect that entrypoints are executable. If your Agave template expected a Bash environment, just add ```#!/usr/bin/env bash``` to the beginning of the runner script.  

_env-<appname>.sh_: A host-local test-script that launches the app container and runs the default entrypoint. Useful for debugging. Accessible via ```build/bundles/<appname>/env-<appname>.sh``` or via ```APPLIST=<appname> make envs```.

_test-<appname>.sh_: A host-local test-script that sets up inputs and parameters via environment variables, then launches the app-specific entrypoint script. Note in some of the examples our simple means of staging data files into place and cacheing them. Accessible via ``build/bundles/<appname>/test-<appname>.sh``` or via ```APPLIST=<appname> make tests```.

_*.json_: The ```app.json``` is the current Agave representation for the app, where parameters, inputs, outputs, resourcing, deployment details,, etc is described and the ```job.json``` is a sample job file for running an example instance of the app. Neither is template generated or maintained as part of the build process at present.

*Porting from Agave apps*

If you have an existing app.json and/or job.json, you can 

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

Test apps locally using Docker
------------------------------

```
bundles/<appname>/test-<appname>.sh
```

Deploy to Agave
---------------

```
make deploy
```


```Last Updated: 11/22/2016```