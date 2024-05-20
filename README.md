![zigi](https://user-images.githubusercontent.com/117615/69496216-051d1580-0ed0-11ea-9ea5-cf0d9153482c.png)

# Overview

`zigi` is the z/OS ISPF Git Interface and is designed for use by the experienced ISPF developer who needs to interact with `git` hosted source. The installation of `zigi` requires that you have downloaded the `zigi` installer, which you obviously have or you wouldn't be reading this.

The next requirement is to install a ported version of `git` for z/OS. 

Currently there are two ported versions of `git`. One from Rocket Software and the other from the z/OS Open Tools project. Below is a short explanation of how to install `git` from each:

# Installing git - Rocket Software

Point your browser to https://www.rocketsoftware.com/ and create an account. Then install the Rocket installer `miniconda` and follow their instructions.
Then download git, bash, gzip and perl and bring all those files to one directory in USS.

Then head on over to https://gist.github.com/wizardofzos/897b243d4cbe9fbc471ec1396fbbe174 and stick that installer in the
same directory as the things you downloaded from rocket.

Run that script.

You should now have git installed on you Mainframe.

Clone this repository and run the installer via:

    git clone git@github.com:zigi/zigi.git
    cd zigi
    ./zginstall.rex

or

[![anaconda/dl](https://anaconda.org/zdevops/zigi/badges/installer/conda.svg)](https://anaconda.org/zdevops/zigi)

## Setting up your environment

Be sure to follow the instructions provided by Rocket Software to update the `PATH`, `LIBPATH`,  `MANPATH`, etc. in your `/etc/profile`.

# Installing git - z/OS Open Tools

The other available port of `git` is from the z/OS Open Tools project. They provide an installer called `zopen` which you will need to download from (https://zosopentools.org/#/Guides/QuickStart)[https://zosopentools.org/#/Guides/QuickStart]. 

Once the `zopen` installer is installed youj will need execute the `zopen-config` script found in the installation directory `mountpoint/etc`. At that point you can run `open install git` and follow the prompts to install `git` along with any pre-reqs and co-reqs.

## Setting up your environment

To make the z/OS Open Tools installed tools available you will need to update your `/etc/profile` to execute that `zopen-config` script.

Add `. ./mountpoint/etc/zopen-config` to your `/etc/profile and your good to go.

***Unless*** you copied, moved, or remounted the installed directory so a new mount point in which case change `mountpoint` as appropriate ***and*** update the `zopen-config` statement `ZOPEN_ROOTFS=` to point to the root where you installed/copied/mounted it.

Example: `ZOPEN_ROOTFS="/isv/zopen"` 

Since you wish to use this with `zigi` there is one more step.

### The zigi Environment File

The `zigi` interface to z/OS UNIX System Services (aka USS or OMVS) uses the REXX interface service `bpxwunix` which, unfortunately, does not support having sub scripts like the `zopen-config` run from `/etc/profile`. So we have developed a work-around which requires that once you start `zigi` that you enter the full path and name for the `zopen-config`.

Here is an example:
![image](https://github.com/lbdyck/zigi/assets/42328411/71d465b5-d471-4268-8061-1a5e645c1570)

`zigi` will display this when it is started if it is unable to detect a version of `git` in the USS Path. You can also display this ISPF Panel using the command `zigi /envr` when you start or once in `zigi` enter the command `gitenv`.


# Creating the z/OS ZIGI Datasets

## Make sure you are authorized to allocate the target datasets

Next you need to run the `zginstall.rex` command from either USS/OMVS or via the shell. This will allocate the `zigi` z/OS datasets and copy the contents to them for use.

# Suggested Tool

`zigi` will use the z/OS supplied `cp` command to copy datasets, and PDS members, between z/OS and USS *but* it is slow so not ideal if you have PDS datasets with more than a few dozen members. The Dovetail Technologies company has made available their ***Co:Z Toolkit***, which includes `getpds` and `putpds` tools that are lightning fast compared to `cp`, for ***free*** (although it is recommended that you support them by getting a support contract). 

Go to [(https://coztoolkit.com/downloads/coz/index.html](https://coztoolkit.com/downloads/coz/index.html) and review the terms and conditions to determine if you installation qualifies for the *free* license and how to acquire a support (paid) contract if you are able.

# Samples

The ZGBATCH exec is located in the ZIGI.SAMPLES dataset and is provided as an example for you to use
to create a batch process to add/commit/push updates in batch to a zigi managed git repository.

# Contributing to zigi?

Yes please! We can always use others to join with us in addressing bugs, adding features, improving and/or creating documentation, etc.

# Known Issues (maybe solutions...)

## Weird Certificate Errors
When faced with a "SSL Certificate problem: unable to get local issuer" this might 'fix' it. Please note that this will
disable encryption for all uses of git and this is strongly discouraged in non-sandbox environments.

    git config --global http.sslVerify false

## Text File Corruption

If a text file contains the following special characters they will be corrupted when copied from z/OS to OMVS:

       x'0D'  Carriage Return (CR)
       x'15'  New Line (NL)
       x'25'  Line Feed (LF)

This typically occurs in ISPF Panels where there special characters are used as attribute characters.

The solution is to add these datasets, or PDS members, to the Git repository as binary elements.
