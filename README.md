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

`sbpl` requires you to have a `sbpl-pkg.sh` file in the working direcotry. This file is used to manage your dependencies. You can generate it by calling

```BASH
./sbpl.sh init
```

or create it yourself. 

```BASH
#!/bin/bash
set -eu

sbpl_get 'archive' 'sbpl' 'master' 'https://github.com/octocraft/${name}/archive/${version}.zip' './${name}-${version}/bin/'
sbpl_get 'file'    'sbpl' 'master' 'https://raw.githubusercontent.com/octocraft/${name}/${version}/${name}.sh'
sbpl_get 'git'     'sbpl' 'master' 'https://github.com/octocraft/${name}.git' './bin/'

```

Note: `/sbpl.sh` calls `sbpl-pkg.sh` every time to check if it needs to download dependencies. It is assumed, that `sbpl-pkg.sh` runs without side effects. Keep this in mind if you include custom commands in this file.

### Binaries

Packages are downloaded (extracted if needed) and a symbolic link is placed in `vendor/bin/$sbpl_os/$sbpl_arch`. Furthermore a symbolic link in `vendor/bin/current` is created. Add this folder to `PATH` to make dependencies available for your apps/script.

```BASH
export PATH="$PWD/vendor/bin/current:$PATH"
``` 

Via the `envvars` command `sbpl` returns the path to the bin dir. You can use this to lock bins for a specific platform. Include it in `PATH` like this:

```BASH
export PATH="$(./sbpl.sh envvars sbpl_path_bin):$PATH"
```

You find a full example in [examples/blank](examples/blank).

### Packages

The packages are stored in `vendor/$sbpl_os/$sbpl_arch/${name}-${version}`. A link is created in `vendor/current`.

## Commands

`help` - Prints usage information and a list of commands which may be used

`init` - Interactively create a `sbpl-pkg.sh` file

`update` - Download all packages

`upgrade` - Upgrade `sbpl.sh` to the latest version

`clean` - Delete all contents in vendor-dir

`version` - Prints the version of `sbpl`

`envvars` - Returns all variables used by sbpl. You may pass a variable name to filter the list

`get` - Download a package via shell. The syntax for this command is the same as sbpl_get

If called without further arguments `/sbpl.sh` will download packages if needed.

## API

`sbpl-pkg.sh` has access to certain variables and functions. 

Note: `sbpl.sh` does not override variables. You can export all variables before calling `sbpl` to override its default behavior.

**Functions**

`sbpl_get` - download and install a package

Usage: sbpl_get 'target'
- `sbpl_get file    'name' 'version'    'url'`
- `sbpl_get archive 'name' 'version'    'url' 'bin_dir'`
- `sbpl_get git     'name' 'branch/tag' 'url' 'bin_dir'`

To define the bin-dir and the url, all the variables below can be used. Additionally the name (`$name`) and version (`$version`) are exposed to those arguments. Additional options can be added to influence the bevaior of find (which is internatlly used):
- `bin` - bin path
- `{sbpl_os}-${sbpl_arch}/bin` - path using variables
- `name/bin/*.exe` - path using filter for `*.exe`

Note: `url` and `bin-dir` are evaluated using eval. Use single quotes to access variables provided by sbpl.

**sbpl**

`sbpl_version` - The version number of `sbpl`

**Platform**

`$sbpl_os` - Operating system 
(android, darwin, dragonfly, freebsd, linux, netbsd, openbsd, plan9, solaris, windows or `$sbpl_osTYPE` if nothing from the list)

`$sbpl_arch` - Architecture (arm64, arm, 368, amd64, ppc64le, ppc64, mips64le, mips64, mipsle, mips or `$HOSTTYPE` if nothing from the list)

**Directories**

`$sbpl_dir_pkgs` - Relative path vendor dir (`vendor`)

`$sbpl_dir_bins` - Relative path to bin dir (`$sbpl_dir_pkgs/bin`)

`$sbpl_dir_tmps` - Relative path to tmp dir (`$sbpl_dir_pkgs/tmp`)


`$sbpl_dir_pkg` - Relative path to platform vendor dir (`vendor/$sbpl_os/$sbpl_arch`)

`$sbpl_dir_bin` - Relative path to platform bin dir (`$sbpl_dir_pkgs/bin/$sbpl_os/$sbpl_arch`)

`$sbpl_dir_tmp` - Relative path to platform bin dir (`$sbpl_dir_pkgs/tmp/$sbpl_os/$sbpl_arch`)


`$sbpl_path_pkg` - Absolute path to platform vendor dir (`$PWD/$sbpl_dir_pkg`)

`$sbpl_path_bin` - Absolute path to platform bin dir (`$PWD/$sbpl_dir_bin`)

`$sbpl_path_tmp` - Absolute path to platform bin dir (`$PWD/$sbpl_dir_tmp`)


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


