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

use work.CellBufferIfcPackage.all;
use work.SpiControllerIfcPackage.all;

entity CmdProcessor is
    generic(ClkPeriodIn16thNs : natural);
    port(
        Clk : in std_logic;
        Rst : in std_logic;
        Activation : in std_logic;
        SwBufferPrepared : in std_logic;
        WTransPulseControlReg  : in std_logic;
        Operation : out std_logic_vector(1 downto 0);
        HwBufferAvailable : out std_logic;
        SelectedBufferNumberOwnedBySw : out std_logic;
        HwBufferAddress : out std_logic_vector(6 downto 0);
        HwBufferWriteEnable : out std_logic_vector(3 downto 0);
        HwBufferWriteData : out std_logic_vector(31 downto 0);
        HwBufferReadData : in std_logic_vector(31 downto 0);
        CPol : out std_logic;
        CPha : out std_logic;
        SClkPeriodInNs : out std_logic_vector(9 downto 0);
        DoTransceivePulse : out std_logic;
        ReleaseTxDataPulse : in std_logic;
        StoreRxDataPulse : in std_logic;
        TxByte : out std_logic_vector(7 downto 0);
        RxByte : in std_logic_vector(7 downto 0);
        nCs : out std_logic_vector(14 downto 0)
    );
end entity;


architecture RTL of CmdProcessor is

    type State_T is (ControllerOff, ControllerIdle, ControllerRestart, SetHwBufferAddress, CmdDispatch,
        TransceiveByteStart, SetTransceiveHwBufferAddress, TransceiveByteEnd,
        StartTimer, RunTimer, Goto, ForLoop, EndOrRestart);
        
    signal State : State_T := ControllerOff;
    signal CmdId : std_logic_vector(3 downto 0);
    signal ReadHwBufferAddressPointer : unsigned(HwBufferAddress'high downto 0);
    signal ReadHwBufferRepeatAddressPointer : unsigned(HwBufferAddress'high downto 0);
    signal WriteHwBufferAddressPointer : unsigned(HwBufferAddress'high downto 0);
    signal ReceiveFrameStartAddress : std_logic_vector(CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_WIDTH - 1 - 2 downto 0);
    signal PacketMultiplier : unsigned(CMDTRANSCEIVECELL_PACKETMULTIPLIER_WIDTH - 1 downto 0);
    signal PacketLength : unsigned(CMDTRANSCEIVECELL_PACKETLENGTH_WIDTH - 1 downto 0);
    signal PacketCount : unsigned(CMDTRANSCEIVECELL_PACKETMULTIPLIER_WIDTH - 1 downto 0);
    signal ByteCount : unsigned(HwBufferAddress'high + 2 downto 0);
    signal ReceiveByteCount : unsigned(HwBufferAddress'high + 2 downto 0);
    signal StoreReceiveByte : std_logic;
    signal ResetReceiveByteCount : std_logic;
    signal WaitNs : unsigned(CMDWAITCELL_WAITNS_WIDTH -1 downto 0);
    signal StartTimerPulse : std_logic;
    signal TimerCount : unsigned(CMDWAITCELL_WAITNS_WIDTH + 4 downto 0);
    signal TimerExpired : std_logic;
    signal CmdGotoAddressToGoto : unsigned(CMDGOTOCELL_ADDRESSTOGOTO_WIDTH - 1 downto 0);
    signal ForLoopCount : unsigned(CMDFORLOOPCELL_FORLOOPCOUNT_WIDTH - 1 downto 0);
    signal LoopCount : unsigned(CMDFORLOOPCELL_FORLOOPCOUNT_WIDTH - 1 downto 0);
    signal CmdEndAddressToGoto : unsigned(CMDENDCELL_ADDRESSTOGOTO_WIDTH - 1 downto 0);
    signal AutoRestart : std_logic;
    signal SwBuffersPending : unsigned(1 downto 0);
    signal HwBufferProcessedPulse : std_logic;
    signal Tranceive : std_logic;

begin

    HwBufferAddress <= std_logic_vector(ReadHwBufferAddressPointer) when HwBufferWriteEnable = "0000" else std_logic_vector(WriteHwBufferAddressPointer);
    CmdId <= HwBufferReadData(31 downto 28);


    prcCmdProcessor : process(Clk, Rst) is
    begin
    
        if Rst = '1' then
        
            SelectedBufferNumberOwnedBySw <= '0';
            ReadHwBufferAddressPointer <= (others => '0');
            ReadHwBufferRepeatAddressPointer <= (others => '0');
            ReceiveFrameStartAddress <= (others => '0');
            nCs <= (others => '1');
            CPol <= '0';
            CPha <= '0';
            SClkPeriodInNs <= (others => '0');
            PacketMultiplier <= (others => '0');
            PacketLength <= (others => '0');
            PacketCount <= (others => '0');
            ByteCount <= (others => '0');
            WaitNs <= (others => '0');
            StartTimerPulse <= '0';
            CmdGotoAddressToGoto <= (others => '0');
            ForLoopCount <= (others => '0');
            CmdEndAddressToGoto <= (others => '0');
            AutoRestart <= '0';
            TxByte <= (others => '0');
            DoTransceivePulse <= '0';        
            StoreReceiveByte <= '0';
            LoopCount <= (others => '0');
            Operation <= OFF;
            ResetReceiveByteCount <= '0';
            Tranceive <= '0';
            HwBufferProcessedPulse <= '0';           
            State <= ControllerOff;
            
        elsif rising_edge(Clk) then
        
            -- default assignments
            StartTimerPulse <= '0';
            DoTransceivePulse <= '0'; 
            HwBufferProcessedPulse <= '0';
            ResetReceiveByteCount <= '0';
            
            case State is

                when ControllerOff =>
                    if Activation = ACTIVATED then
                        Operation <= IDLE;
                        State <= ControllerIdle;
                    end if;

                when ControllerIdle =>
                    if Activation = DEACTIVATED then
                        Operation <= OFF;
                        State <= ControllerOff;
                    elsif SwBuffersPending > 0 then
                        SelectedBufferNumberOwnedBySw <= not SelectedBufferNumberOwnedBySw;                                                                
                        ReadHwBufferAddressPointer <= (others => '0');  
                        ResetReceiveByteCount <= '1';                     
                        Operation <= BUSY;
                        State <= SetHwBufferAddress;
                    end if;

                when ControllerRestart =>
                    if Activation = DEACTIVATED then
                        Operation <= OFF;
                        State <= ControllerOff;
                    elsif SwBuffersPending > 0  then
                        SelectedBufferNumberOwnedBySw <= not SelectedBufferNumberOwnedBySw;                                
                        ReadHwBufferAddressPointer <= (others => '0');       
                        ResetReceiveByteCount <= '1';              
                        State <= SetHwBufferAddress;
                    end if;

                when SetHwBufferAddress =>              
                    State <= CmdDispatch;

                when CmdDispatch =>
                    if CmdId = CMDCONFIGCELL_CONFIGCELLID then
                        ReceiveFrameStartAddress <= HwBufferReadData(CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_POSITION + CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_WIDTH - 1 downto CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_POSITION + 2);
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetHwBufferAddress;
                    elsif CmdId = CMDSETCELL_SETCELLID then
                        if unsigned(HwBufferReadData(CMDSETCELL_CHIPSELECT_POSITION + CMDSETCELL_CHIPSELECT_WIDTH - 1 downto CMDSETCELL_CHIPSELECT_POSITION)) /= to_unsigned(0, CMDSETCELL_CHIPSELECT_WIDTH) - 1 then
                            nCs(to_integer(unsigned(HwBufferReadData(CMDSETCELL_CHIPSELECT_POSITION + CMDSETCELL_CHIPSELECT_WIDTH - 1 downto CMDSETCELL_CHIPSELECT_POSITION)))) <= '0';
                        else
                            nCs <= (others => '1');
                        end if;
                        CPol <= HwBufferReadData(CMDSETCELL_CLKPOLARITY_POSITION);
                        CPha <= HwBufferReadData(CMDSETCELL_CLKPHASE_POSITION);
                        SClkPeriodInNs <= HwBufferReadData(CMDSETCELL_CLKPERIOD_POSITION + CMDSETCELL_CLKPERIOD_WIDTH - 1 downto CMDSETCELL_CLKPERIOD_POSITION);
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetHwBufferAddress;
                    elsif CmdId = CMDTRANSMITCELL_TRANSMITCELLID then
                        PacketMultiplier <= unsigned(HwBufferReadData(CMDTRANSMITCELL_PACKETMULTIPLIER_POSITION + CMDTRANSMITCELL_PACKETMULTIPLIER_WIDTH - 1 downto CMDTRANSMITCELL_PACKETMULTIPLIER_POSITION));
                        PacketLength <= unsigned(HwBufferReadData(CMDTRANSMITCELL_PACKETLENGTH_POSITION + CMDTRANSMITCELL_PACKETLENGTH_WIDTH - 1 downto CMDTRANSMITCELL_PACKETLENGTH_POSITION));
                        PacketCount <= (others => '0');
                        ByteCount <= (others => '0');
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        ReadHwBufferRepeatAddressPointer <= ReadHwBufferAddressPointer + 1;
                        Tranceive <= '0';
                        State <= SetTransceiveHwBufferAddress;
                    elsif CmdId = CMDTRANSCEIVECELL_TRANSCEIVECELLID then
                        PacketMultiplier <= unsigned(HwBufferReadData(CMDTRANSCEIVECELL_PACKETMULTIPLIER_POSITION + CMDTRANSCEIVECELL_PACKETMULTIPLIER_WIDTH - 1 downto CMDTRANSCEIVECELL_PACKETMULTIPLIER_POSITION));
                        PacketLength <= unsigned(HwBufferReadData(CMDTRANSCEIVECELL_PACKETLENGTH_POSITION + CMDTRANSCEIVECELL_PACKETLENGTH_WIDTH - 1 downto CMDTRANSCEIVECELL_PACKETLENGTH_POSITION));
                        PacketCount <= (others => '0');
                        ByteCount <= (others => '0');                      
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        ReadHwBufferRepeatAddressPointer <= ReadHwBufferAddressPointer + 1;
                        Tranceive <= '1';
                        State <= SetTransceiveHwBufferAddress;
                    elsif CmdId = CMDWAITCELL_WAITCELLID then
                        WaitNs <= unsigned(HwBufferReadData(CMDWAITCELL_WAITNS_POSITION + CMDWAITCELL_WAITNS_WIDTH - 1 downto CMDWAITCELL_WAITNS_POSITION));
                        StartTimerPulse <= '1';                      
                        State <= StartTimer;
                    elsif CmdId = CMDGOTOCELL_GOTOCELLID then
                        CmdGotoAddressToGoto <= unsigned(HwBufferReadData(CMDGOTOCELL_ADDRESSTOGOTO_POSITION + CMDGOTOCELL_ADDRESSTOGOTO_WIDTH - 1 downto CMDGOTOCELL_ADDRESSTOGOTO_POSITION));
                        State <= Goto;
                    elsif CmdId = CMDFORLOOPCELL_FORLOOPCELLID then
                        ForLoopCount <= unsigned(HwBufferReadData(CMDFORLOOPCELL_FORLOOPCOUNT_POSITION + CMDFORLOOPCELL_FORLOOPCOUNT_WIDTH - 1 downto CMDFORLOOPCELL_FORLOOPCOUNT_POSITION));
                        State <= ForLoop;
                    elsif CmdId = CMDENDCELL_ENDCELLID then
                        CmdEndAddressToGoto <= unsigned(HwBufferReadData(CMDENDCELL_ADDRESSTOGOTO_POSITION + CMDENDCELL_ADDRESSTOGOTO_WIDTH - 1 downto CMDENDCELL_ADDRESSTOGOTO_POSITION));
                        AutoRestart <= HwBufferReadData(CMDENDCELL_AUTORESTART_POSITION);
                        HwBufferProcessedPulse <= '1';    
                        State <= EndOrRestart;
                    else
                        State <= ControllerIdle;
                    end if;

                when SetTransceiveHwBufferAddress =>
                    State <= TransceiveByteStart;

                when TransceiveByteStart =>
                    if PacketCount < PacketMultiplier then
                        if ByteCount < PacketLength then
                            TxByte <= HwBufferReadData(to_integer(ByteCount(1 downto 0)) * 8 + 7 downto to_integer(ByteCount(1 downto 0)) * 8);
                            DoTransceivePulse <= '1';
                            State <= TransceiveByteEnd;
                        else
                            State <= SetTransceiveHwBufferAddress;
                        end if;
                    else
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetHwBufferAddress;
                    end if;

                when TransceiveByteEnd =>
                    if ReleaseTxDataPulse then
                        if Tranceive then
                            StoreReceiveByte <= '1';
                        else
                            StoreReceiveByte <= '0';
                        end if;
                        if ByteCount < PacketLength - 1 then
                            ByteCount <= ByteCount + 1;
                            if ByteCount( 1 downto 0) = 3 then
                                ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                            end if;
                            State <= SetTransceiveHwBufferAddress;
                        else
                            if PacketCount < PacketMultiplier - 1 then
                                ByteCount <= (others => '0');
                                PacketCount <= PacketCount + 1;
                                ReadHwBufferAddressPointer <= ReadHwBufferRepeatAddressPointer;
                                State <= SetTransceiveHwBufferAddress;
                            else
                                ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                                State <= SetHwBufferAddress;
                            end if;
                        end if;
                    end if;

                when StartTimer =>
                    State <= RunTimer;

                when RunTimer =>
                    if TimerExpired then
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetHwBufferAddress;
                    end if;

                when Goto =>
                    ReadHwBufferAddressPointer <= CmdGotoAddressToGoto(8 downto 2);
                    State <= SetHwBufferAddress;

                when ForLoop =>
                    if LoopCount < ForLoopCount then
                        LoopCount <= LoopCount + 1;
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetHwBufferAddress;
                    else
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 2;
                        LoopCount <= (others => '0');
                        State <= SetHwBufferAddress;
                    end if;

                when EndOrRestart =>                           
                    if AutoRestart then
                        ReadHwBufferAddressPointer <= CmdEndAddressToGoto(8 downto 2);
                        State <= ControllerRestart;
                    else
                        Operation <= IDLE;
                        State <= ControllerIdle;
                    end if;

            end case;
        end if;
        
    end process;

    prcStoreReceiveByte : process (Clk, Rst) is
    begin
        if Rst = '1' then
            WriteHwBufferAddressPointer <= (others => '0');
            HwBufferWriteData <= (others => '0');
            HwBufferWriteEnable <= (others => '0');
            ReceiveByteCount <= (others => '0');
        elsif rising_edge(Clk) then
            HwBufferWriteEnable <= (others => '0'); -- default assignment
            if ResetReceiveByteCount then                   
                ReceiveByteCount <= (others => '0');
            elsif StoreReceiveByte and StoreRxDataPulse then
                WriteHwBufferAddressPointer <= unsigned(ReceiveFrameStartAddress) + ReceiveByteCount(8 downto 2);
                HwBufferWriteData(to_integer(ReceiveByteCount(1 downto 0)) * 8 + 7 downto to_integer(ReceiveByteCount(1 downto 0)) * 8) <= RxByte;
                HwBufferWriteEnable(to_integer(ReceiveByteCount(1 downto 0))) <= '1';
                ReceiveByteCount <= ReceiveByteCount + 1;
            end if;                
        end if;
    end process;

    prcTimer : process (Clk, Rst) is
    begin
        if Rst = '1' then
            TimerCount <= (others => '0');
            TimerExpired <= '0';
        elsif rising_edge(Clk) then
            if StartTimerPulse then
                TimerCount <= (others => '0');
                TimerExpired <= '0';
            else
                if TimerCount < WaitNs * 16 then
                    TimerCount <= TimerCount + ClkPeriodIn16thNs;
                else
                    TimerExpired <= '1';
                end if;
            end if;
        end if;
    end process;

    HwBufferAvailable <= '1' when SwBuffersPending < 2 else '0';

    prcSwBuffer : process (Clk, Rst) is
    begin
        if Rst = '1' then
            SwBuffersPending <= (others =>'0');           
        elsif rising_edge(Clk) then
            if SwBufferPrepared and WTransPulseControlReg then
                if SwBuffersPending < 2 then
                    SwBuffersPending <= SwBuffersPending + 1;
                end if;
            elsif HwBufferProcessedPulse then
                if SwBuffersPending > 0 then
                    SwBuffersPending <= SwBuffersPending - 1;
                end if;
            end if;
        end if;
    end process;


end architecture;
