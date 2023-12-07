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

entity SpiControllerWithAvalonBus is
    port(
        Clk : in std_logic;
        Rst : in std_logic;
        SpiControllerIfcAvalonDown : in T_SpiControllerIfcAvalonDown;
        SpiControllerIfcAvalonUp : out T_SpiControllerIfcAvalonUp;
        SpiControllerIfcTrace : out T_SpiControllerIfcTrace;
        SClk : out std_logic;
        MiSo : in std_logic;
        MoSi : out std_logic;
        nCs : out std_logic_vector(14 downto 0)
    );
end entity;

architecture RTL of SpiControllerWithAvalonBus is

    signal SpiControllerBlkDown : T_SpiControllerIfcSpiControllerBlkDown;
    signal SpiControllerBlkUp : T_SpiControllerIfcSpiControllerBlkUp;

    signal SelectedBufferNumberOwnedBySw : std_logic;
    signal SwBufferWriteEnable : std_logic_vector(3 downto 0);
    signal HwBufferWriteEnable : std_logic_vector(3 downto 0);
    signal HwBufferAddress : std_logic_vector(6 downto 0);
    signal HwBufferWriteData : std_logic_vector(31 downto 0);
    signal HwBufferReadData : std_logic_vector(31 downto 0);

    signal FetchTxBytePulse : std_logic;
    signal ReadyToFetchTxByte : std_logic;
    signal FetchRxBytePulse : std_logic;
    signal RxByteIsPending : std_logic;
    signal TxByte : std_logic_vector(7 downto 0);
    signal RxByte : std_logic_vector(7 downto 0);
    signal CPol : std_logic;
    signal CPha : std_logic;
    signal SClkPeriodInNs : std_logic_vector(9 downto 0);

    signal WaitRequestSwBuffer : std_logic;


begin

    i_SpiControllerIfcAvalon : entity work.SpiControllerIfcAvalon
        port map(
            Clk => Clk,
            Rst => Rst,
            AvalonDown => SpiControllerIfcAvalonDown,
            AvalonUp => SpiControllerIfcAvalonUp,
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
            FetchTxBytePulse => FetchTxBytePulse,
            ReadyToFetchTxByte => ReadyToFetchTxByte,
            FetchRxBytePulse => FetchRxBytePulse,
            RxByteIsPending => RxByteIsPending,
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
            FetchTxBytePulse => FetchTxBytePulse,
            ReadyToFetchTxByte => ReadyToFetchTxByte,
            FetchRxBytePulse => FetchRxBytePulse,
            RxByteIsPending => RxByteIsPending,
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
            SwBufferAddress => SpiControllerBlkDown.CellBufferAddress(8 downto 2),
            SwBufferWriteData => SpiControllerBlkDown.CellBufferWriteData,
            SwBufferReadData => SpiControllerBlkUp.CellBufferReadData
        );


    prcWaitRequestSwBuffer : process (Clk, Rst)
    begin
        if (Rst = '1') then
            WaitRequestSwBuffer <= '1';
        elsif rising_edge(Clk) then
            WaitRequestSwBuffer <= not ((SpiControllerBlkDown.CellBufferWrite or SpiControllerBlkDown.CellBufferRead) and WaitRequestSwBuffer);
        end if;
    end process;

    SpiControllerBlkUp.CellBufferWaitRequest <= WaitRequestSwBuffer;

    SwBufferWriteEnable <= SpiControllerBlkDown.CellBufferByteEnable when not WaitRequestSwBuffer and SpiControllerBlkDown.CellBufferWrite else "0000";

end architecture;
