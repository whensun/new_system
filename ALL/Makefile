B=bootloader
BIOS = \
    $B/entry.o \
    $B/start.o \
    $B/code.o \
    $B/load.o \
    $B/string.o \
    $B/machine_to_supervisor.o \
    $B/machine_to_user.o \

ifndef TOOLPREFIX
TOOLPREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	elif riscv64-unknown-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-linux-gnu-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find a riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

QEMU = qemu-system-riscv64

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb -gdwarf-2
CFLAGS += -MD
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

###################################################################################################
###################################################################################################

CFLAGS += -march=rv64imafdch_zicfiss_zicbom_zicboz_v_zicsr_zca_zimop_zcmop_zbb_zbs_zkne_zbkb_zabha_zacas_zawrs_zkr_smepmp_zcb_zicond
ASFLAGS = -march=rv64imafdch_zicfiss_zicbom_zicboz_v_zicsr_zca_zimop_zcmop_zbb_zbs_zkne_zbkb_zabha_zacas_zawrs_zkr_smepmp_zcb_zicond

###################################################################################################
###################################################################################################

MODE ?= UMODE
CFLAGS += -D$(MODE)

ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]no-pie'),)
CFLAGS += -fno-pie -no-pie
endif
ifneq ($(shell $(CC) -dumpspecs 2>/dev/null | grep -e '[^f]nopie'),)
CFLAGS += -fno-pie -nopie
endif

LDFLAGS = -z max-page-size=4096

$B/%.o: $B/%.S
	$(CC) $(CFLAGS) $(ASFLAGS) -c $< -o $@

$B/%.o: $B/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$B/bootloader: $(BIOS) $B/bootloader.ld 
	$(LD) $(LDFLAGS) -T $B/bootloader.ld -o $B/bootloader $(BIOS) 
	$(OBJDUMP) -S $B/bootloader > $B/bootloader.asm
	$(OBJDUMP) -t $B/bootloader | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $B/bootloader.sym

$U/initcode: $U/initcode.S
	$(CC) $(CFLAGS) -march=rv64g -nostdinc -I. -Ikernel -c $U/initcode.S -o $U/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o $U/initcode.out $U/initcode.o
	$(OBJCOPY) -S -O binary $U/initcode.out $U/initcode
	$(OBJDUMP) -S $U/initcode.o > $U/initcode.asm

tags: $(OBJS) _init
	etags *.S *.c

ULIB = $U/ulib.o $U/usys.o $U/printf.o $U/umalloc.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -T $U/user.ld -o $@ $^
	$(OBJDUMP) -S $@ > $*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

$U/usys.S : $U/usys.pl
	perl $U/usys.pl > $U/usys.S

$U/usys.o : $U/usys.S
	$(CC) $(CFLAGS) -c -o $U/usys.o $U/usys.S

$U/_forktest: $U/forktest.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $U/_forktest $U/forktest.o $U/ulib.o $U/usys.o
	$(OBJDUMP) -S $U/_forktest > $U/forktest.asm

mkfs/mkfs: mkfs/mkfs.c $K/fs.h $K/param.h
	gcc -Werror -Wall -I. -o mkfs/mkfs mkfs/mkfs.c

.PRECIOUS: %.o

-include kernel/*.d user/*.d

clean: 
	rm -f *.tex *.dvi *.idx *.aux *.log *.ind *.ilg \
	*/*.o */*.d */*.asm */*.sym \
	$U/initcode $U/initcode.out $B/bootloader fs.img \
  bootloader-with-recovery.img \
	mkfs/mkfs .gdbinit \
        $U/usys.S \
	$(UPROGS)

GDBPORT = $(shell expr `id -u` % 5000 + 25000)
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)
ifndef CPUS
CPUS := 1
endif

###################################################################################################
###################################################################################################

QEMUOPTS = -machine virt -bios none -kernel $B/bootloader -m 128M -smp $(CPUS) -nographic -cpu rv64,v=on,smstateen=on,sscofpmf=on,smcsrind=on,sscsrind=on,smaia=on,ssaia=on,ssccfg=on,smcdeleg=on,zicfiss=on,zimop=on,zcmop=on,zaamo=on,zca=on,zbb=on,zbs=on,zkne=on,zbkb=on,zabha=on,zacas=on,zawrs=on,smdbltrp=on,zkr=on,smepmp=on,zcb=on,zicond=on

###################################################################################################
###################################################################################################

all: $B/bootloader

qemu: $B/bootloader
	$(QEMU) $(QEMUOPTS) $(QEMUOPTS1)

.gdbinit: .gdbinit.tmpl-riscv
	sed "s/:1234/:$(GDBPORT)/" < $^ > $@

qemu-gdb: $B/bootloader .gdbinit
	@echo "*** Now run 'gdb' in another window." 1>&2
	$(QEMU) $(QEMUOPTS) $(QEMUOPTS1) -S $(QEMUGDB)