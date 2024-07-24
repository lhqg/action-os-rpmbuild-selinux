![GitHub Release (latest SemVer)](https://img.shields.io/github/v/release/lhqg/actions)
[![License](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![GitHub Issues](https://img.shields.io/github/issues/lhqg/actions)](https://github.com/lhqg/actions/issues)
[![GitHub PR](https://img.shields.io/github/issues-pr/lhqg/actions)](https://github.com/lhqg/actions/pulls)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/y/lhqg/actions)](https://github.com/lhqg/selinux_cassandra/commits/main)
[![GitHub Last commit](https://img.shields.io/github/last-commit/lhqg/actions)](https://github.com/lhqg/actions/commits/main)
![GitHub Downloads](https://img.shields.io/github/downloads/lhqg/actions/total)

Actions repository for LHQG to build SELinux RPMs on targeted OS
==========================================================
https://github.com/lhqg/actions

## Introduction

This repository aims to build on a specified OS, RPMS for an SELinux policy module and
to sign them with a GPG key.

## How to use this repository

Main branch is used to manage changes that are applicable to all the other branches. 
Specific branches are created for each OS we want the RPMs to be built. 
User must checkout each OS branch in is workflow in order to build the RPMs.

### Inputs

All the following inputs are required:

####  source_repo_location          (default: `SOURCE_REPO`)
    Provides the directory where the source repository was checked out

####  spec_file_location            (default: ``)
    Provides the relative path to the source repository of the SPEC file

####  selinux_files_location        (default: ``)
    Provides the relative path to the source repository of the SELinux files

####  provided_version              (default: ``)
    RPM version you want to build

####  provided_release              (default: ``)
    RPM release you want to build

####  gpg_name                      (default: ``)
    GPG pretty name of the key

####  gpg_private_key_file          (default: ``)
    GPG key file

## Disclaimer

The code of this repository is provided AS-IS. People and organisation
willing to use it must be fully aware that they are doing so at their own risks and
expenses.

The Author(s) of this repository module SHALL NOT be held liable nor accountable, in
any way, of any malfunction or limitation of said module, nor of the resulting damage, of
any kind, resulting, directly or indirectly, of the usage of this repository.

It is strongly advised to always use the last version of the code.

Finally, users should check regularly for updates.
