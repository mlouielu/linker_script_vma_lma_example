CC := $(CC)
CFLAGS = -nostdlib -m32
TARGET = foo.bin

observe:
	objdump -h foo.elf
	@echo "----------------"
	hexdump foo.bin
	@echo "----------------"
	objdump -D foo.elf | grep -A 2 -B 0 "<m>"

simple: a.c b.c
	$(CC) $(CFLAGS) -T simple.ld $^ -o foo.elf
	objcopy -j abc -j def -O binary foo.elf $(TARGET)

without_lma: a.c b.c
	$(CC) $(CFLAGS) -T move_without_lma.ld $^ -o foo.elf
	objcopy -j abc -j def -O binary foo.elf $(TARGET)

with_lma: a.c b.c
	$(CC) $(CFLAGS) -T move_with_lma.ld $^ -o foo.elf
	objcopy -j abc -j def -O binary foo.elf $(TARGET)
	$(observe)

clean:
	$(RM) -f *.o *.bin *.elf