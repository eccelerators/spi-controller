-- ******************************************************************************
-- 
--                   /------o
--             eccelerators
--          o------/
-- 
--  This file is an Eccelerators GmbH sample project.
-- 
--  MIT License:
--  Copyright (c) 2023 Eccelerators GmbH
-- 
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
-- 
--  The above copyright notice and this permission notice shall be included in all
--  copies or substantial portions of the Software.
-- 
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--  SOFTWARE.
-- ******************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.SpiControllerIfcPackage.all;
use work.RamIfcPackage.all;

entity SpiControllerWithAxi4LiteBus is
	port(
		Clk : in std_logic;
		Rst : in std_logic;
		SpiControllerIfcAxi4LiteDown : in T_SpiControllerIfcAxi4LiteDown;
		SpiControllerIfcAxi4LiteUp : out T_SpiControllerIfcAxi4LiteUp;
		SpiControllerIfcTrace : out T_SpiControllerIfcTrace;
		SClk : out std_logic;
		MiSo : in std_logic;
		MoSi : out std_logic;
		nCs : out std_logic_vector(14 downto 0)
	);
end entity;

architecture RTL of SpiControllerWithAxi4LiteBus is
	
	signal SpiControllerBlkDown : T_SpiControllerIfcSpiControllerBlkDown;
	signal SpiControllerBlkUp : T_SpiControllerIfcSpiControllerBlkUp;
	
	signal SelectedBufferNumberOwnedBySw : std_logic;
	signal SwBufferWriteEnable : std_logic_vector(3 downto 0);
	signal HwBufferWriteEnable : std_logic_vector(3 downto 0);
	signal HwBufferAddress : std_logic_vector(6 downto 0);
	signal HwBufferWriteData : std_logic_vector(31 downto 0);
	signal HwBufferReadData : std_logic_vector(31 downto 0);

	signal DoTransceivePulse : std_logic;	
	signal ReleaseTxDataPulse : std_logic;
	signal StoreRxDataPulse : std_logic;
	signal TxByte : std_logic_vector(7 downto 0);
	signal RxByte : std_logic_vector(7 downto 0);
	signal CPol : std_logic;
	signal CPha : std_logic;
	signal SClkPeriodInNs : std_logic_vector(9 downto 0);
	
	signal ExtReadAckRamDelay : std_logic_vector(1 downto 0);
	
    signal RamIfcAxi4LiteDown : T_RamIfcAxi4LiteDown;
    signal RamIfcAxi4LiteUp : T_RamIfcAxi4LiteUp;
    signal RamIfcTrace : T_RamIfcTrace;
    signal RamIfcRamBlkDown : T_RamIfcRamBlkDown;
    signal RamIfcRamBlkUp : T_RamIfcRamBlkUp;


begin

	i_SpiControllerIfcAxi4Lite : entity work.SpiControllerIfcAxi4Lite
		port map(
			Clk => Clk,
			Rst => Rst,
			Axi4LiteDown => SpiControllerIfcAxi4LiteDown,
			Axi4LiteUp => SpiControllerIfcAxi4LiteUp,
			Axi4LiteAccess => open,
			Trace => SpiControllerIfcTrace,
			SpiControllerBlkDown => SpiControllerBlkDown,
			SpiControllerBlkUp => SpiControllerBlkUp
		);
		
	i_Phy : entity work.Phy
		generic map(
			ClkPeriodIn16thNs => 10 * 16
		)
		port map(
			Clk => Clk,
			Rst => Rst,
			SClk => SClk,
			MiSo => MiSo,
			MoSi => MoSi,
			DoTransceivePulse => DoTransceivePulse,
			ReleaseTxDataPulse => ReleaseTxDataPulse,
			StoreRxDataPulse => StoreRxDataPulse,
			TxByte => TxByte,
			RxByte => RxByte,
			CPol => CPol,
			CPha => CPha,
			SClkPeriodInNs => SClkPeriodInNs
		);

	i_CmdProcessor : entity work.CmdProcessor
		generic map(
			ClkPeriodIn16thNs => 10 * 16
		)
		port map(
			Clk => Clk,
			Rst => Rst,
			Activation => SpiControllerBlkDown.Activation,
			SwBufferPrepared => SpiControllerBlkDown.SwBuffer,
			WTransPulseControlReg  => SpiControllerBlkDown.WTransPulseControlReg,
			Operation => SpiControllerBlkUp.Operation,
			HwBufferAvailable => SpiControllerBlkUp.HwBuffer,
			SelectedBufferNumberOwnedBySw => SelectedBufferNumberOwnedBySw,
			HwBufferAddress => HwBufferAddress,
			HwBufferWriteEnable => HwBufferWriteEnable,
			HwBufferWriteData => HwBufferWriteData,
			HwBufferReadData => HwBufferReadData,
			CPol => CPol,
			CPha => CPha,
			SClkPeriodInNs => SClkPeriodInNs,
			DoTransceivePulse => DoTransceivePulse,
			ReleaseTxDataPulse => ReleaseTxDataPulse,
			StoreRxDataPulse => StoreRxDataPulse,
			TxByte => TxByte,
			RxByte => RxByte,
			nCs => nCs
		);

	i_DoubleBuffer : entity work.DoubleBuffer
		port map(
			Clk => Clk,
			Rst => Rst,
			SelectedBufferNumberOwnedBySw => SelectedBufferNumberOwnedBySw,
			HwBufferWriteEnable => HwBufferWriteEnable,
			HwBufferAddress => HwBufferAddress,
			HwBufferWriteData => HwBufferWriteData,
			HwBufferReadData => HwBufferReadData,
			SwBufferWriteEnable => SwBufferWriteEnable,
			SwBufferAddress => RamIfcRamBlkDown.RamAddress(8 downto 2),
			SwBufferWriteData => RamIfcRamBlkDown.DataWritten,
			SwBufferReadData => RamIfcRamBlkUp.DataToBeRead
	);
	
    RamIfcAxi4LiteDown.AWVALID <= SpiControllerBlkDown.CellBufferAWVALID;
    RamIfcAxi4LiteDown.AWADDR <= SpiControllerBlkDown.CellBufferAWADDR(10 downto 0);
    RamIfcAxi4LiteDown.AWPROT <= SpiControllerBlkDown.CellBufferAWPROT;
    RamIfcAxi4LiteDown.WVALID <= SpiControllerBlkDown.CellBufferWVALID;
    RamIfcAxi4LiteDown.WDATA <= SpiControllerBlkDown.CellBufferWDATA;
    RamIfcAxi4LiteDown.WSTRB <= SpiControllerBlkDown.CellBufferWSTRB;
    RamIfcAxi4LiteDown.BREADY <= SpiControllerBlkDown.CellBufferBREADY;
    RamIfcAxi4LiteDown.ARVALID <= SpiControllerBlkDown.CellBufferARVALID;
    RamIfcAxi4LiteDown.ARADDR <= SpiControllerBlkDown.CellBufferARADDR(10 downto 0);
    RamIfcAxi4LiteDown.ARPROT <= SpiControllerBlkDown.CellBufferARPROT;
    RamIfcAxi4LiteDown.RREADY <= SpiControllerBlkDown.CellBufferRREADY;
    
    SpiControllerBlkUp.CellBufferAWREADY <= RamIfcAxi4LiteUp.AWREADY;
    SpiControllerBlkUp.CellBufferWREADY <= RamIfcAxi4LiteUp.WREADY;
    SpiControllerBlkUp.CellBufferBVALID <= RamIfcAxi4LiteUp.BVALID;
    SpiControllerBlkUp.CellBufferBRESP <= RamIfcAxi4LiteUp.BRESP;
    SpiControllerBlkUp.CellBufferARREADY <= RamIfcAxi4LiteUp.ARREADY;
    SpiControllerBlkUp.CellBufferRVALID <= RamIfcAxi4LiteUp.RVALID;
    SpiControllerBlkUp.CellBufferRDATA <= RamIfcAxi4LiteUp.RDATA;
    SpiControllerBlkUp.CellBufferRRESP <= RamIfcAxi4LiteUp.RRESP;
		
    i_RamIfcAxi4Lite : entity work.RamIfcAxi4Lite
    port map(
        Clk => Clk,
        Rst => Rst,
        Axi4LiteDown => RamIfcAxi4LiteDown,
        Axi4LiteUp => RamIfcAxi4LiteUp,
        Axi4LiteAccess => open,
        Trace => RamIfcTrace,
        RamBlkDown => RamIfcRamBlkDown,
        RamBlkUp => RamIfcRamBlkUp
    );
    
    prcAckSwBuffer : process (Clk, Rst)
    begin
        if (Rst = '1') then
            ExtReadAckRamDelay <= (others => '0');
        elsif rising_edge(Clk) then
            ExtReadAckRamDelay <= RamIfcRamBlkDown.RTransPulseRam & ExtReadAckRamDelay(0);
        end if;
    end process;
    
    RamIfcRamBlkUp.ExtWriteAckRam <= RamIfcRamBlkDown.WRegPulseRam;
    RamIfcRamBlkUp.ExtReadAckRam <= ExtReadAckRamDelay(1);
    
    SwBufferWriteEnable <= RamIfcRamBlkDown.RamByteSelect and RamIfcRamBlkDown.WRegPulseRam;

end architecture;
