-- Copyright (C) 2023 Eccelerators GmbH
-- 
-- This code was generated by:
--
-- HxS Compiler v0.0.0-0000000
-- VHDL Extension for HxS v0.0.0-0000000
-- 
-- Further information at https://eccelerators.com/hxs
-- 
-- Changes to this file may cause incorrect behavior and will be lost if the
-- code is regenerated.
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

package RamIfcPackage is

	type T_RamIfcAxi4LiteDown is
	record
		AWVALID : std_logic;
		AWADDR : std_logic_vector(10 downto 0);
		AWPROT : std_logic_vector(2 downto 0);
		WVALID : std_logic;
		WDATA : std_logic_vector(31 downto 0);
		WSTRB : std_logic_vector(3 downto 0);
		BREADY : std_logic;
		ARVALID : std_logic;
		ARADDR : std_logic_vector(10 downto 0);
		ARPROT : std_logic_vector(2 downto 0);
		RREADY : std_logic;
	end record;
	
	type T_RamIfcAxi4LiteUp is
	record
		AWREADY : std_logic;
		WREADY : std_logic;
		BVALID : std_logic;
		BRESP : std_logic_vector(1 downto 0);
		ARREADY : std_logic;
		RVALID : std_logic;
		RDATA : std_logic_vector(31 downto 0);
		RRESP : std_logic_vector(1 downto 0);
	end record;
	
	type T_RamIfcAxi4LiteAccess is
	record
		WritePrivileged : std_logic;
		WriteSecure : std_logic;
		WriteInstruction : std_logic;
		ReadPrivileged : std_logic;
		ReadSecure : std_logic;
		ReadInstruction : std_logic;
	end record;
	
	type T_RamIfcTrace is
	record
		Axi4LiteDown : T_RamIfcAxi4LiteDown;
		Axi4LiteUp : T_RamIfcAxi4LiteUp;
		Axi4LiteAccess : T_RamIfcAxi4LiteAccess;
		UnoccupiedAck : std_logic;
		TimeoutAck : std_logic;
	end record;
	
	type T_RamIfcRamBlkDown is
	record
		DataWritten : std_logic_vector(31 downto 0);
		WRegPulseRam : std_logic;
		RTransPulseRam : std_logic;
		RamAddress : std_logic_vector(10 downto 0);
        RamByteSelect  : std_logic_vector(3 downto 0);
	end record;
	
	type T_RamIfcRamBlkUp is
	record
		DataToBeRead : std_logic_vector(31 downto 0);
		ExtReadAckRam : std_logic;
		ExtWriteAckRam : std_logic;
	end record;
	
	constant RAMBLK_BASE_ADDRESS : std_logic_vector(10 downto 0) := "00000000000";
	constant RAMBLK_SIZE : std_logic_vector(11 downto 0) := "100000000000";
	
	constant RAM_WIDTH : integer := 32;
	constant RAM_ADDRESS : std_logic_vector(10 downto 0) := std_logic_vector("00000000000" + unsigned(RAMBLK_BASE_ADDRESS));
	
	constant DATA_POSITION : integer := 0;
	constant DATA_WIDTH : integer := 32;
	constant DATA_MASK : std_logic_vector(31 downto 0) := x"FFFFFFFF";
	
end;