# AdiOS-newlib

This is the newlib port for AdiOS

Based on the repo : https://github.com/ReturnInfinity/BareMetal-newlib4

Introduction
------------

This repository contains the files, script, and instructions necessary to build the C library for AdiOS.

newlib gives AdiOS access to the standard set of C library calls like `printf()`, `scanf()`, `memcpy()`, etc.

These instructions are for executing on a 64-bit Linux host. Building on a 64-bit host saves us from the steps of building a cross compiler. The latest distribution of Ubuntu was used while writing this document.


Building Details
----------------

You will need the following Linux packages. Use your prefered package manager to install them:

	libtool sed gawk bison flex m4 texinfo texi2html unzip make

You also need exact versions of the following:
 * autoconf - 2.69
 * automake - 1.15.1

On a Arch-based system this can be accomplished via the following:
```
# Remove software if already installed
sudo pacman -R autoconf automake

# Download the required versions 
wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
wget https://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz

# Extract them
tar -xvzf autoconf-2.69.tar.gz
tar -xvzf automake-1.15.1.tar.gz

# Build and install them
cd autoconf-2.69
./configure
make
sudo make install
cd ..
cd automake-1.15.1
./configure
make
sudo make install
cd ..

# Adjust the path variable
PATH=$PATH:/usr/local/bin
```

Run the build script to download and build:

	./build-newlib.sh

After a lengthy compile you should have newlib installed in ./lib, headers in ./include

By default libc.a will be about 6.4 MiB. You can `strip` it to make it a little more compact. `strip` can decrease it to about 1.4 MiB.

	strip --strip-debug lib/libc.a
