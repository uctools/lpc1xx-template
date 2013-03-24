LPC1xx Template
==================

This template builds code for the LPC11xx and LPC13xx
microcontrollers.

## Toolchain

You will need an ARM bare-metal toolchain to build code for LPC1xx targets.
You can get a toolchain from the
[gcc-arm-embedded](https://launchpad.net/gcc-arm-embedded) project that is
pre-built for your platform. Extract the package and add the `bin` folder to
your PATH.

You will also need to download and extract LPCOpen, which can
be found
[here](http://www.lpcware.com/content/nxpfile/lpcopen-platform)

## Writing and Building Firmware

1. Clone the
   [lpc11xx-template](https://github.com/uctools/lpc11xx-template)
   repository (or fork it and clone your own repository).

        git clone git@github.com/uctools:lpc11xx-template

2. Modify the Makefile:
    * Set TARGET to the desired name of the output file (eg: TARGET = main)
    * Set SOURCES to a list of your sources (eg: SOURCES = main.c
      startup\_gcc.c)
    * Set LPCOPEN\_PATH to the full path to where you extracted LPCOpen.
    * Set FAMILY to the family of your part. This can be 11xx or 13xx.
    * Set PART for your part. For example, for the LPC11Uxx series, use
      CHIP_LPC11UXX.

3. Run `make`

4. The output files will be created in the 'build' folder
