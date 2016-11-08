# Linker Script VMA and LMA example

In linker script, VMA (virtual memory address) and LMA (loaded memory address)
is a basic concept about output section address. Every loadable or allocatable
output section has two address, that is VMA and LMA.

* VMA (virtual memory address): The address the section will have when the output
file is run.
* LMA (load memory address): The address at which the section will be loaded.

Most of the time, VMA and LMA will be the same, for example, the program you compile
with gcc on Linux, the VMA and LMA will be the same since the loaded address is same
as virtual memory address. But in embedded system, this situation might change.

Let's say we have this memory layout in our embedded system:

	ROM: 0x0000 ~ 0x1000
	RAM: 0x1000 ~ 0x2000

If we use `move_without_lma.ld` linker script, we can see that the data in section
def will start from 0x1000, that is when we burn the binary file onto embedded
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

# Makefile

* observe: observe with `objdump` and `hexdump`
* simple: build with `simple.ld`
* move_without_lma: build with `move_without_lma.ld`
* move_with_lma: build with `move_with_lma.ld`
* clean: clena all file.

# Quick Start

We won't use `make observe` now, just type the command and get familiar with these
command.

## simple

First to run `make simple`, it will build `foo.elf` and foo.bin` with `simple.ld`
linker script.

Then run `objdump -h foo.elf` to dump out section header like this:

	> objdump -h foo.elf

	foo.elf:     file format elf32-i386

	Sections:
	Idx Name          Size      VMA       LMA       File off  Algn
	  0 abc           0000001c  00000000  00000000  00001000  2**2
	                  CONTENTS, ALLOC, LOAD, DATA
	  1 def           00000018  0000001c  0000001c  0000101c  2**2
	                  CONTENTS, ALLOC, LOAD, DATA

We can now observe VMA and LMA for each section, section abc has VMA at 0x00000000
and LMA at 0x00000000, and section def has VMA at 0x0000001c and LMA at 0x0000001c.

## move without lma

Run `make without_lma`, now the linker script will put section def VMA to
0x1000, you can see in line 9, location counter was assign to 0x1000.

You may now run `make observe`, it will output this information:

	> make observe
	objdump -h foo.elf

	foo.elf:     file format elf32-i386

	Sections:
	Idx Name          Size      VMA       LMA       File off  Algn
	  0 abc           0000001c  00000000  00000000  00001000  2**2
	                  CONTENTS, ALLOC, LOAD, DATA
	  1 def           00000018  00001000  00001000  00002000  2**2
	                  CONTENTS, ALLOC, LOAD, DATA
	----------------
	hexdump foo.bin
	0000000 0001 0000 0002 0000 0003 0000 1008 0000
	0000010 0007 0000 0008 0000 0009 0000 0000 0000
	0000020 0000 0000 0000 0000 0000 0000 0000 0000
	*
	0001000 0004 0000 0005 0000 0006 0000 000a 0000
	0001010 000b 0000 000c 0000                    
	0001018
	----------------
	objdump -D foo.elf | grep -A 2 -B 0 "<m>"
	0000000c <m>:
	   c:	08 10                	or     %dl,(%eax)

It will output three part. First it `objdump -h` for section header, you can see
that section def VMA and LMA has changed to 0x0001000.

Second, we are using `hexdump` to dump out binary file content, start from 0x0,
the data was store by little-endian, and the data was a:1, b:2, c:3, m:1008, ...,
the mark `*` was saying that from 0x0000020 to 0x001000 is padding by 0x0 content.
Starting from 0x001000, it continues the section def data.

In the end, we can see that in `void *m`, the value inside is `1008`, that is quite
sure, since `int f` was stored at 0x001008.

## move with lma

Now, let us run `with_lma`, then to observe by `make observe`:

	> make observe
	objdump -h foo.elf

	foo.elf:     file format elf32-i386

	Sections:
	Idx Name          Size      VMA       LMA       File off  Algn
	  0 abc           0000001c  00000000  00000000  00001000  2**2
	                  CONTENTS, ALLOC, LOAD, DATA
	  1 def           00000018  00001000  0000001c  00002000  2**2
	                  CONTENTS, ALLOC, LOAD, DATA
	----------------
	hexdump foo.bin
	0000000 0001 0000 0002 0000 0003 0000 1008 0000
	0000010 0007 0000 0008 0000 0009 0000 0004 0000
	0000020 0005 0000 0006 0000 000a 0000 000b 0000
	0000030 000c 0000                              
	0000034
	----------------
	objdump -D foo.elf | grep -A 2 -B 0 "<m>"
	0000000c <m>:
	   c:	08 10                	or     %dl,(%eax)
		...

We can see that section def LMA was changed to 0000001c, if you look closer in the
linker script, you may found that is the result of `ADDR(abc) + SIZEOF(abc)`, counting
by abc VMA address and size, we can calculate the value is `00000000 + 0x0000001c`.

So, what did this matter?

Yes, it matter. Look at the hexdump result, there hasn't appear any `*` mark,
section def content was continue at 0x000001c, not 0x0001000, and now, the binary
file was only 52 bytes, hola!

The question, will this change the value of `void *m`? The answer is no, you can
see that `void *m` value is still `0x1008`, the VMA of `int f`.

Using this technique, you will need to initialize data youself when the program
start to run, you will need to move data from ROM to RAM, don't forget about it.
