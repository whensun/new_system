sudo apt update -y
sudo apt upgrade -y
sudo apt install -y pkg-config libglib2.0-dev
git clone git@github.com:qemu/qemu.git
cd qemu
./configure --target-list=riscv64-softmmu --disable-werror
make -j $(nproc)
sudo make install