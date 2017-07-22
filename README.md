# GoSeed: A seed for a Go project

## Requirements

  * **Go** has to be installed and the environment variable `$GOPATH` setup as explained in https://golang.org/doc/install.
  * **Docker** is required to ship your program in containers. This have been used with [Docker CE for Mac](https://download.docker.com/mac/stable/Docker.dmg)

This have been tested on Mac OSX and may work on Linux. For Windows you may need a Linux emulator.

## Quick Start

Clone the repository using the name of the application or package, and run `make init`:

    git clone --depth=1 https://github.com/johandry/GoSeed.git MyApp
    cd MyApp
    make init

The project comes with base Go program to:
  * A Makefile to automate many development and testing tasks
  * The Makefile builds the application in binaries for every OS/Architecture, a microcontainer (from scratch) and a container from Alpine.
  * A version package, for every new version modify the file `version/latest.go`
  * Print version with subcommand 'version'
  * Logs to a file or Stderr, customizable with a flag, config file or environment variable
  * Define a debugging log level with a flag, config file or environment variable
  * Define a verbose log level (lower than debug) with a flag, config file or environment variable
  * By default, the log level is lower than verbose and just print errors.
  * Testing files.

The `.git` directory is recreated but you may need to configure your new project to a new Github repository. For example:

    echo "# MyApp" > README.md
    git add .
    git commit -m "First commit"
    git remote add origin https://github.com/johandry/MyApp.git
    git push -u origin master

## Builds

The Makefile is ready to build your code for your OS, all the OS and ship it in a Docker container.

To test and build your code for your OS, use `make` or `make build`. This will download all the vendors the code use, test it (if there is any test) and build it, placing the binary in `bin/`.

    make
    ./bin/myapp

To build the application for every OS and architecture, review in the Makefile the variables `C_OS` and `C_ARCH` at the top of the file, and update the required OS and architectures to build the application. Then execute `make build-all`. The binaries will be located in `pkg/{version}/{os}/{arch}/`

    make build-all
    ls -al pkg/*/*/*

To create a container with the binary execute `make image`. This will create a Docker image based on `scratch` with the application. **This build will fail if the project do not have a Github repository**, so configure git as explained above and commit/push it to Github. When the build is done you can view your images with `make ls` and run the application with `make run`, like this:

    make image
    make ls
    make run

If you want the 3 builds just execute `make all`.

To clean the repository of binaries, execute `make clean`. Optionally, you can remove every image and containers with `make clean-all`, just be careful, this will **delete every image and container in your system**.
