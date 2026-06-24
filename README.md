![zigi](https://user-images.githubusercontent.com/117615/69496216-051d1580-0ed0-11ea-9ea5-cf0d9153482c.png)

# Overview

`zigi` is the z/OS ISPF Git Interface and is designed for use by the experienced ISPF developer who needs to interact with a Git hosted source. The installation of `zigi` requires that you have downloaded the `zigi` installer, which you obviously have or you wouldn't be reading this.

  - The main requirement for using this interface is to install a ported version of Git to z/OS. 


## Index

- [Overview](#overview)
- [Installation and Configuration](#installation-and-configuration)
  - [Step 1: Installing Git](#step-1-installing-git)
  - [Step 2: Creating the z/OS ZIGI Datasets](#step-2-creating-the-zos-zigi-datasets)
- [Suggested Tool](#suggested-tool)
- [Samples](#samples)
- [Contributing](#contributing)
- [Known Issues](#known-issues)


## Installation and Configuration
### Step 1 - Installing Git 

Currently there are several available ported versions of Git for z/OS. One from Rocket Software, another from the z/OS Open Tools project, and an IBM-provided package that contains the `git` binary and corresponding libraries as well as several other open source packages. Below you can find a short explanation of how to install Git from each of the different sources.

  - [Option 1 - Installing Git from Rocket Software](#option-1-installing-git-from-rocket-software)
  - [Option 2 - Installing Git from the zopen Community](#option-2-installing-git-from-the-zopen-community)
  - [Option 3 - Installing Git from IBM Open Enterprise Foundation for z/OS](#option-3-installing-git-from-ibm-open-enterprise-foundation-for-z-os)

#### Option 1 - Installing Git from Rocket Software

1. Point your browser to https://www.rocketsoftware.com/ and create an account. 

2. Download the Rocket installer `miniconda` and follow their instructions. 

3. Then, download `git`, `bash`, `gzip` and `perl`, and bring all those files to one directory in USS.

4. Head over to https://gist.github.com/wizardofzos/897b243d4cbe9fbc471ec1396fbbe174 and copy that installer script into the same directory that contains the things you downloaded from rocket.

5. **Run that script.** After executing the script, you should now have git installed on your Mainframe.

6. Clone this repository, and run the installer via:
```bash
git clone git@github.com:zigi/zigi.git
cd zigi
./zginstall.rex
```

  - Or, use:

[![anaconda/dl](https://anaconda.org/zdevops/zigi/badges/installer/conda.svg)](https://anaconda.org/zdevops/zigi)

#### Setting up your environment

Be sure to follow the instructions provided by Rocket Software to update the `PATH`, `LIBPATH`, `MANPATH`, and other environment variables in your `/etc/profile`.


#### Option 2 - Installing Git from the zopen community

Another available port of Git is from the [zopen community](https://zopen.community/) project. They provide an installer called `zopen` which you will need to download from [https://zopen.community/#/Guides/QuickStart](https://zopen.community/#/Guides/QuickStart). 

Once the `zopen` installer is installed, you will need to execute the `zopen-config` script found in the installation directory `mountpoint/etc`. At that point, you can run the command `zopen install git` and follow the prompts to install Git along with any pre-reqs and co-reqs.

#### Setting up your environment

To make the z/OS Open Tools kit available, you will need to update your `/etc/profile` to automatically execute the `zopen-config` script each time your shell starts. To do this, perform the following steps:

1. Add `. ./mountpoint/etc/zopen-config` to your `/etc/profile`

After you've done this step, you're good to go - each time your UNIX (USS/OMVS) profile loads, you will also automatically load the necessary zopen tools configurations.

  - ***Unless*** you copied, moved, or remounted the installation directory to a new mount point, in which case you should change `mountpoint` as appropriate **AND** update the `zopen-config` variable `ZOPEN_ROOTFS=` to point to the root where you installed/copied/mounted it.

**Example:** `ZOPEN_ROOTFS="/isv/zopen"` 

Since you wish to also use this package with `zigi`, there is one more step:

#### The zigi Environment File

The `zigi` interface to z/OS UNIX System Services (aka USS or OMVS) uses the REXX interface service `bpxwunix` which, unfortunately, does not support having sub-scripts like the `zopen-config` run from `/etc/profile`. We have developed a work-around which requires that once you start `zigi`, you enter the full path and name for the `zopen-config`.

**Example:** Here is an example of the panel prompt to change the zigi environment file path: 
![image](https://github.com/lbdyck/zigi/assets/42328411/71d465b5-d471-4268-8061-1a5e645c1570)

Upon starting, `zigi` will display a dialog box that prompts you to input the full path to the environment file in the case that it is unable to detect a version of Git in the current USS Path. You can also display this ISPF panel using either the command `zigi /envr` when you start, or by using the command `gitenv` from within the `zigi` panel.


#### Option 3 - Installing Git from IBM Open Enterprise Foundation for z/OS

IBM Open Enterprise Foundation for z/OS provides a comprehensive suite of open source UNIX-based development tools that are enabled to run natively on z/OS. These tools and libraries are designed to enhance the development and deployment experience on the z/OS platform. 

**NOTICE:** A few points worth mentioning regarding this package:
  - These packages are also often referred to as 'OEFZOS' or 'FOZ' (FOZ is the official abbreviation and terminology that IBM provides for the package).
  - The are included with your existing IBM z/OS Service and Support at ***no*** additional charge.
  - As of z/OS 3.1 and above, this package is a bypassable requisite, and can be installed directly through the z/OSMF interface and/or SMP/E.

> Additional product information (including an easier way to plan and order, prerequisites, other products, and more) is available within IBM Shopz for the following programs:
> - IBM Open Enterprise Foundation for z/OS 1.1 (5655-OEF)
> - IBM Open Enterprise Foundation for z/OS Subscription and Support (S&S) (5655-EFS)

#### FOZ Git Configurations

1. Verify the version of z/OS that your mainframe is running:
  - If you are **on z/OS version 3.1 or higher**, you can likely pull down the IBM FOZ packages directly (or already have them).
  - If you are **on a version of z/OS below 3.1**, you will likely need to retrieve the package indirectly from ShopZ and relocate it to your system.

2. Determine and mount the FOZ zFS dataset to USS (if not already mounted). 
  - **Note:** It is also useful to add an entry to your member `BPXPRM` in PARMLIB if you haven't already, so that this zFS dataset containing Git and the other open source utilities are automounted to USS (UNIX) after IPLs.

3. Load into the UNIX environment via OMVS (TSO `omvs` command), and `cd` into the directory containing the IBM Open Enterprise Foundation for z/OS packages (your mountpoint path). **For example:**
```bash
cd /usr/lpp/IBM/foz/
```

  - We do this to ensure that the `git` command (binary) and libraries are present and available within the mounted zFS dataset. 
 
4. Enter the following command to execute the environment script, which loads the necessary environment variables for actually using the FOZ package (including the `git` command):
```
. ./.env
```

> **Note:** This is an IBM-provided shell script/dotfile that is used to easily setup useful shell environment variables, such as adding the FOZ commands and libraries to the path. More information can be found within the Open Enterprise Foundation for z/OS documentation (see below).

5. Verify that Git is found in the path and that it is working by running the following command:
```
git --version
```

*More information can be found using the following links to the official IBM documentation for Open Enterprise Foundation for z/OS:*
- [FOZ Documentation](https://www.ibm.com/docs/en/oefzos)
- [FOZ Product Page](https://www.ibm.com/products/open-enterprise-foundation-zos)

---

### Step 2: Creating the z/OS ZIGI Datasets

Next, you need to run the `zginstall.rex` command from either USS/OMVS or via the shell. This will allocate the `zigi` z/OS datasets and copy the contents to them for use.

> **Note:** Make sure you are authorized to allocate the target datasets.

**Example:**
```
./zginstall.rex
```


## Suggested Tool

`zigi` will use the z/OS supplied `cp` command to copy datasets and PDS members between z/OS and USS, *but* it is slow (this not ideal if you have PDS datasets with more than a few dozen members). The Dovetail Technologies company has made available their ***Co:Z Toolkit***, which includes the `getpds` and `putpds` tools (that are lightning fast compared to the standard `cp`) for ***free*** 

  - Although these tools are free, it is recommended that you support them by purchasing a support contract. 

Go to the [Co:Z Toolkit Downloads Page](https://coztoolkit.com/downloads/coz/index.html) and review the terms and conditions to determine if your installation qualifies for the *free* license and how to acquire a support (paid) contract, if you are able to purchase one.


## Samples

The `ZGBATCH` executable program (exec) is located in the ZIGI.SAMPLES dataset and is provided as an example to use for creating a batch process to add/commit/push updates in batch to a zigi-managed git repository.


## Contributing

Contributing to zigi? Yes please! We can always use others to join us and assist in addressing bugs, adding features, improving and/or creating documentation, etc.


## Known Issues
### Weird Certificate Errors

When faced with a "SSL Certificate problem: unable to get local issuer", the following steps might 'fix' this issue.

> ***WARNING:*** Please note that this will **disable encryption for all uses of git** and this is strongly discouraged in non-sandbox environments.

`git config --global http.sslVerify false`

### Text File Corruption

If a text file contains any of the following special characters, then they will be corrupted when copied from z/OS datasets into OMVS (UNIX) files:

```
x'0D'  Carriage Return (CR)
x'15'  New Line (NL)
x'25'  Line Feed (LF)
```

This typically occurs in ISPF panels where there are special characters being used as attribute characters.

The solution is to add these datasets or PDS members to the Git repository as binary elements.

