#!/usr/bin/bash

set -e

mkdir -p ./work
cd ./work

echo "analyze testbench devices"
ghdl -a --std=08 -frelaxed ../../tb-ip/hdl/Infineon/s25fl129p00/conversions.vhd
ghdl -a --std=08 -frelaxed ../../tb-ip/hdl/Infineon/s25fl129p00/s25fl129p00.vhd

echo "analyze hxs generated sources"
ghdl -a --std=08 ../../src-gen/vhdl/axi4lite/CellBufferIfcPackage.vhd
ghdl -a --std=08 ../../src-gen/vhdl/wishbone/SpiControllerIfcPackage.vhd
ghdl -a --std=08 ../../src-gen/vhdl/wishbone/SpiControllerIfcWishbone.vhd

echo "analyze ip sources"
ghdl -a --std=08 ../../ip/hdl/generic/Ram.vhd

echo "analyze sources"
ghdl -a --std=08 ../../src/vhdl/Phy.vhd
ghdl -a --std=08 ../../src/vhdl/DoubleBuffer.vhd
ghdl -a --std=08 ../../src/vhdl/CmdProcessor.vhd
ghdl -a --std=08 ../../src/vhdl/SpiControllerWithWishboneBus.vhd

echo "analyze testbench"
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_base_pkg.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_base_pkg_body.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_instructions_pkg.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_interpreter_pkg.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_interpreter_pkg_body.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_bus_avalon_pkg.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_bus_axi4lite_pkg.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_bus_wishbone_pkg.vhd
ghdl -a --std=08 ../../tb/hdl/tb_bus_pkg.vhd
ghdl -a --std=08 ../../tb/hdl/tb_signals_pkg.vhd
ghdl -a --std=08 ../../tb-ip/hdl/Eccelerators/simstm/src/tb_simstm.vhd

echo "analyze toplevel"
ghdl -a --std=08 -frelaxed ../../tb/hdl/tb_top_wishbone_infineon_spi_flash.vhd

echo "elaborate"
ghdl -e --std=08 -frelaxed tb_top_wishbone 

cd ..

echo "start simulation"
./work/tb_top_wishbone --vcd=./trace.vcd --stop-time=10000000ns

# echo "show waveforms"
# gtk-wave gtk-waves.gtkw ./trace.vcd


