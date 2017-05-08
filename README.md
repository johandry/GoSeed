# GoSeed: A seed for a Golang project

## Requirements

Go has to be installed and the environment variable `$GOPATH` setup as explained in https://golang.org/doc/install.
Docker has to be installed. This have been used with [Docker CE for Mac](https://download.docker.com/mac/stable/Docker.dmg)
Make and other Linux commands are also required, so run this on OSX or Linux. For Windows you may need a Linux emulator of your preference.

## Quick Start

Clone the repository, rename the directory with the name of your application or package, and run `make init`:

    git clone --depth=1 https://github.com/johandry/GoSeed.git
    mv GoSeed MyApp
    cd MyApp
    make init

If you are not me, then you may need to change any reference to `github.com/johandry` to your repository:

    grep -r 'github.com/johandry' *

The project comes with simple Go program to print the version number. Do the modifications to the Go code according to your requirements.

The `.git` directory is recreated but you may need to configure your new project to a new Github repository:

    git add .
    git commit -m "First commit"
    remote add origin https://github.com/johandry/MyApp.git
    git push

## Builds

The Makefile is ready to build your code for your OS, all the OS and ship it in a Docker container.

To test and build your code for your OS, use `make` or `make build`. This will download all the vendors the code use, test it (if there is any test) and build it, placing the binary in `bin/`.

To build the application for every OS and architecture, review in the Makefile the variables `C_OS` and `C_ARCH` at the top of the file, and update the required OS and architectures to build the application. Then execute `make all`. The binaries will be located in `pkg/{version}/{os}/{arch}/`

To create a container with the binary execute `make image`. This will create a Docker image based on `scratch` with the application. When the build is done you can view your images with `make ls` and run the application with `make run`, like this:

    make image
    make ls
    make run

If you want the 3 builds just execute `make all`.

To clean the repository of binaries, execute `make clean`. Optionally, you can remove every image and containers with `make clean-all`, just be careful, this will *delete every image and container in your system*.
