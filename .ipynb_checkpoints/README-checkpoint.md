# Occulus Reparo

Occulus Reparo is an LLM-based framework designed to automatically generate and execute test cases for RISC-V QEMU. The workflow is notebook-driven and focuses on instruction-level and register-level behavioral exploration under different RISC-V extension configurations.

---

## How to Use

### 1. Generate Rules

Occulus Reparo first generates structured rules extracted from the RISC-V specifications. These rules are later used as input for test-case generation.

#### RISC-V Instructions

Use the notebook: `4_INSTRUCTION.ipynb`

Configuration options:

* To generate rules for all RISC-V instructions:

```python
IS_USING_EVERYTHING = True
```

* To generate rules for specific instructions only:

```python
LIST_INSTRUCTION_WANTED = ['CSRRWI', 'ADDIW']
IS_USING_EVERYTHING = False
```

Before selecting an instruction, verify that it exists in: `4_INSTRUCTION/1_OUTPUT/1_INSTRUCTION_ALL.txt`

---

#### RISC-V Registers

Use the notebook: `5_REGISTER.ipynb`

Configuration options:

* To generate rules for all RISC-V registers:

```python
IS_USING_EVERYTHING = True
```

* To generate rules for specific registers only:

```python
LIST_REGISTER_WANTED = ['mseccfg', 'stvec']
IS_USING_EVERYTHING = False
```

Before selecting a register, verify that it exists in: `5_REGISTER/1_OUTPUT/1_REGISTER_ALL.txt`

---

### 2. Generate Test Cases

Use the notebook: `6_TEST_CASE.ipynb`

Steps:

1. Choose a rule source:

* `4_INSTRUCTION/1_OUTPUT/6_INSTRUCTION_TOTAL.txt`
* `5_REGISTER/1_OUTPUT/8_REGISTER_TOTAL.txt`

2. Run the notebook.

The generated assembly test cases will be saved to: `6_TEST_CASE/2_TEST_CASE_RAW.txt`

---

### 3. Run and Check Test Cases

1. Open: `8_EMULATOR/1_QEMU_XV6/QEMU_XV6.ipynb`

2. (Optional) Configure RISC-V extensions in the Makefile.

Default configuration:

```make
QEMUOPTS = -machine virt -bios none -kernel $B/bootloader -m 128M -smp $(CPUS) -nographic -cpu rv64
```

Example: enable Zkr and disable Smepmp:

```make
QEMUOPTS = -machine virt -bios none -kernel $B/bootloader -m 128M -smp $(CPUS) -nographic -cpu rv64,zkr=true,smepmp=false
```

3. Copy test cases to: `8_EMULATOR/1_QEMU_XV6/TEXT/1_QEMU_XV6_INPUT.txt`

4. Run the notebook.

---

## Installation

### QEMU and RISC-V Toolchain Setup

#### Ubuntu-based Linux Distributions

1. Update the system:

```bash
sudo apt update -y
sudo apt upgrade -y
```

2. Install required packages:

```bash
sudo apt install -y qemu-system-misc autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev
```

3. Build the RISC-V GNU toolchain:

```bash
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv64imac_zicsr --with-abi=lp64
sudo make -j$(nproc)
```

---

#### Arch-based Linux Distributions

1. Update the system:

```bash
sudo pacman -Syu --noconfirm
```

2. Install required packages:

```bash
sudo pacman -S --noconfirm qemu-base autoconf automake python python-pip mpc mpfr gmp gawk base-devel bison flex texinfo gperf libtool patch bc zlib expat ninja git cmake glib2 libslirp
```

3. Build the RISC-V GNU toolchain:

```bash
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv --with-arch=rv64imac_zicsr --with-abi=lp64
sudo make -j$(nproc)
```

---

### Post-Installation

1. Add the RISC-V toolchain to PATH:

```bash
echo 'export PATH=/opt/riscv/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

2. Configure GDB auto-load:

```bash
mkdir -p ~/.config/gdb
echo 'set auto-load safe-path /' >> ~/.config/gdb/gdbinit
```

3. Install required Python dependency:

```bash
pip install pwntools
```

---

## Notes

* The notebooks are intended to be run sequentially.
* Extension toggling is essential for exploring QEMU behavioral differences.
* For installation, you can also check `1_INSTALL` folder.