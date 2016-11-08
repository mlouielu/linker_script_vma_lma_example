# Linker Script VMA and LMA example

In linker script, VMA (virtual memory address) and LMA (loaded memory address)
is a basic concept about output section address. Every loadable or allocatable
output section has two address, that is VMA and LMA.

* VMA (virtual memory address): The address the section will have when the output
file is run.
* LMA (load memory address): The address at which the section will be loaded.

Most of the time, VMA and LMA will be the same, for example, the program you compile
with gcc on Linux, the VMA and LMA will be the same since the loaded address is same
as virtual memory address. but in embedded system, this situation might change.

Let's say we have this memory layout in our embedded system:

ROM: 0x0000 ~ 0x1000
RAM: 0x1000 ~ 0x2000

If we use `move_without_lma.ld` linker script, we can see that the data in `def`
section will start from 0x1000, that is, when we burn the binary file on to embedded
system, section def data will save on RAM (!), that's not what we want.

So, we can use `AT` keyword or `>AT` in linker script to assign output section
loaded address, then we can burn all the data in ROM, and move it into RAM when
system start to run.

# Structure

* a.c: contain section abc and section def data, a pointer in section abc point
to section def data.
* b.c: contain section abc and section def data.
* simple.ld: basic linker script, start from 0x0.
* move_without_lma.ld: moving section def to 0x1000, and without AT keyword to
assign LMA.
* move_with_lma.ld: moving section def to 0x1000 with AT keyword to assign LMA.
* Makefile: a makefile for this example.

# Quick Start

* make simple
* make observe
