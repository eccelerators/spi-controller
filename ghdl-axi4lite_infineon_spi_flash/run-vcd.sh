#!/usr/bin/bash

set -e

mkdir -p ./work
cd ./work

echo "analyze testbench devices"
ghdl -a --std=08 -frelaxed ../../tb-ip/hdl/Infineon/s25fl129p00/conversions.vhd
ghdl -a --std=08 -frelaxed ../../tb-ip/hdl/Infineon/s25fl129p00/s25fl129p00.vhd

echo "analyze hxs generated sources"
ghdl -a --std=08 ../../src-gen/vhdl/axi4lite/CellBufferIfcPackage.vhd
ghdl -a --std=08 ../../src-gen/vhdl/axi4lite/SpiControllerIfcPackage.vhd
ghdl -a --std=08 ../../src-gen/vhdl/axi4lite/SpiControllerIfcAxi4Lite.vhd

echo "analyze ip sources"
ghdl -a --std=08 ../../ip/hdl/generic/Ram.vhd
ghdl -a --std=08 ../../ip/hdl/axi4lite_ram_bridge/RamIfcPackage.vhd
ghdl -a --std=08 ../../ip/hdl/axi4lite_ram_bridge/RamIfcAxi4Lite.vhd

echo "analyze sources"
ghdl -a --std=08 ../../src/vhdl/Phy.vhd
ghdl -a --std=08 ../../src/vhdl/DoubleBuffer.vhd
ghdl -a --std=08 ../../src/vhdl/CmdProcessor.vhd
ghdl -a --std=08 ../../src/vhdl/SpiControllerWithAxi4LiteBus.vhd

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
ghdl -a --std=08 -frelaxed ../../tb/hdl/tb_top_axi4lite_infineon_spi_flash.vhd

echo "elaborate"
ghdl -e --std=08 -frelaxed tb_top_axi4lite 

cd ..

echo "start simulation"
./work/tb_top_axi4lite --vcd=./trace.vcd --stop-time=10000000ns
