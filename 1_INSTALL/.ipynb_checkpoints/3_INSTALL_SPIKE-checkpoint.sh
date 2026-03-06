sudo apt update -y
sudo apt upgrade -y
sudo apt install -y device-tree-compiler libboost-regex-dev libboost-system-dev openocd git build-essential autoconf automake libtool pkg-config
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
mkdir -p build
cd build
../configure --prefix=/opt/riscv
make -j$(nproc)
sudo make install