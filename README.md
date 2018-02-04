# sbpl

[![Software License][ico-license]](LICENSE.md)
[![Build Status][ico-travis]][link-travis]

Simple Bash Package Loader

## Why
If you want to test something or make sure it runs on multiple platforms, you need some kind of dependency management. The simplest thing is to wget/curl something. `sbpl` makes this a bit more convenient.

## Installation
Just download `sbpl.sh` from the repository.

```BASH
wget https://raw.githubusercontent.com/octocraft/sbpl/master/sbpl.sh
chmod u+x sbpl.sh
```
### Dependencies

Though `sbpl` was developed with as little dependencies as possible, they cant be avoided. `sbpl` requires `curl` to be available. Furthermore `bsdtar` if you want to download archives and `git` if you want to check out repos.

Install all dependencies

```BASH
sudo apt-get update && sudo apt-get install -y curl bsdtar git
```

## Usage

`sbpl` requires you to have a `sbpl-pkg.sh` file in the same directory as `sbpl.sh`. This file is used to manage your dependencies. You can create this file interactively by calling

```BASH
./sbpl.sh init
```

or create it yourself. 

```BASH
#!/bin/bash

sbpl_get 'archive' 'sbpl' 'master' 'https://github.com/octocraft/${name}/archive/${version}.zip' './${name}-${version}/bin/'
sbpl_get 'file'    'sbpl' 'master' 'https://raw.githubusercontent.com/octocraft/${name}/${version}/${name}.sh'
sbpl_get 'git'     'sbpl' 'master' 'https://github.com/octocraft/${name}.git' './bin/'

```

Packages are downloaded (extracted if needed) and a symbolic link is placed in `vendor/bin`. Add this folder to `PATH` to make dependencies available for your apps/script.

```BASH
#!/bin/bash
set -eu

# Get Packages
./sbpl.sh

# Include Packages
export PATH=$(pwd)/vendor/bin:$PATH

# Execute
# Place your command here. All dependencies will be available

```

You find this example in [examples/blank](examples/blank).


Note: `/sbpl.sh` calls `sbpl-pkg.sh` every time to check if it needs to download dependencies. It is assumed, that `sbpl-pkg.sh` runs without side effects. Keep this in mind if you include custom commands in this file.

### Commands

`init` - Interactively create a `sbpl-pkg.sh` file

`update` - Download all packages

`upgrade` - Upgrade `sbpl.sh` to the latest version

`clean` - Delete all contents in vendor-dir

`version` - Prints the version of `sbpl`

If called without further arguments `/sbpl.sh` will download packages if needed.

### API

`sbpl-pkg.sh` has access to certain variables and functions. 

Note: `sbpl.sh` does not override variables. You can export all variables before calling `sbpl` to override its default behavior.

**Functions**

`sbpl_get` - download and install a package

Usage: sbpl_get 'target'
- `sbpl_get file    'name' 'version'    'url'`
- `sbpl_get archive 'name' 'version'    'url' 'bin_dir'`
- `sbpl_get git     'name' 'branch/tag' 'url' 'bin_dir'`

To define the bin-dir and the url, all the variables below can be used. Additionally the name (`$name`) and version (`$version`) are exposed to those arguments.

Note: `url` and `bin-dir` are evaluated using eval. Use single quotes to make use of this.

**Platform**

`$OS` - Operating system 
(android, darwin, dragonfly, freebsd, linux, netbsd, openbsd, plan9, solaris, windows or `$OSTYPE` if nothing from the list)

`$ARCH` - Architecture (arm64, arm, 368, amd64, ppc64le, ppc64, mips64le, mips64, mipsle, mips or `$HOSTTYPE` if nothing from the list)

**Directories**

`$sbpl_dir` - Absolute path to `/sbpl.sh`

`$sbpl_pkg_dir` - Relative path vendor dir (`vendor`)

`$sbpl_pkg_dir_bin` - Relative path to bin dir (`$sbpl_pkg_dir/bin`)

`$sbpl_pkg_dir_tmp` - Relative path to tmp dir (`$sbpl_pkg_dir/tmp`)

**pwd**

`sbpl.sh` performs a `pushd $sbpl_dir` before calling `sbpl-pkg.sh`. The working dir of `sbpl-pkg.sh` will always be the directory where `sbpl.sh` resides, not matter from where you call it.


## Examples

### [blank](examples/blank)

Copy this example as boiler plate for your own setup. 

`run.sh` - The script which starts your application and makes all packages available to it

### [testing-with-bats](examples/testing-with-bats)

`foo` - The executable to test

`test.sh` - The test script

`test_01\test.bats` - A test written for the bats-test-framework

## License

MIT


[link-travis]: https://travis-ci.org/octocraft/sbpl

[ico-license]: https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square
[ico-travis]: https://img.shields.io/travis/octocraft/sbpl/master.svg?style=flat-square


