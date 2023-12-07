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
        FetchTxBytePulse : out std_logic;
        ReadyToFetchTxByte : in std_logic;
        FetchRxBytePulse : in std_logic;
        RxByteIsPending : in std_logic;
        TxByte : out std_logic_vector(7 downto 0);
        RxByte : in std_logic_vector(7 downto 0);
        nCs : out std_logic_vector(14 downto 0)
    );
end entity;



architecture RTL of CmdProcessor is


    type State_T is (ControllerOff, ControllerIdle, ControllerRestart, SetCmdReadAddress, CmdDispatch,
        SetTxDataReadAddress, TransceiveByteStart, SetRxDataWriteToNext, SetRxDataWriteToEnd, TransceiveByteEnd, SetLastRxDataWrite, StoreLastRxByte,
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
    signal FetchedRxByte : std_logic_vector(7 downto 0);
    signal FetchedRxByteIsPending : std_logic;
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
    signal StateNumbered : unsigned(4 downto 0);


begin


    -- For GHDL and HW debug
    prcNumberStates : process(State) is
    begin
        case State is
            when ControllerOff =>
                StateNumbered <= to_unsigned(0, StateNumbered'length);
            when ControllerIdle =>
                StateNumbered <= to_unsigned(1, StateNumbered'length);
            when ControllerRestart =>
                StateNumbered <= to_unsigned(2, StateNumbered'length);
            when SetCmdReadAddress =>
                StateNumbered <= to_unsigned(3, StateNumbered'length);
            when CmdDispatch =>
                StateNumbered <= to_unsigned(4, StateNumbered'length);

            when SetTxDataReadAddress =>
                StateNumbered <= to_unsigned(5, StateNumbered'length);
            when TransceiveByteStart =>
                StateNumbered <= to_unsigned(6, StateNumbered'length);
            when SetRxDataWriteToNext =>
                StateNumbered <= to_unsigned(7, StateNumbered'length);
            when SetRxDataWriteToEnd =>
                StateNumbered <= to_unsigned(8, StateNumbered'length);
            when TransceiveByteEnd =>
                StateNumbered <= to_unsigned(9, StateNumbered'length);
            when SetLastRxDataWrite =>
                StateNumbered <= to_unsigned(10, StateNumbered'length);
            when StoreLastRxByte =>
                StateNumbered <= to_unsigned(11, StateNumbered'length);

            when StartTimer =>
                StateNumbered <= to_unsigned(12, StateNumbered'length);
            when RunTimer =>
                StateNumbered <= to_unsigned(13, StateNumbered'length);
            when Goto =>
                StateNumbered <= to_unsigned(14, StateNumbered'length);
            when ForLoop =>
                StateNumbered <= to_unsigned(15, StateNumbered'length);
            when EndOrRestart =>
                StateNumbered <= to_unsigned(16, StateNumbered'length);

            when others =>
                StateNumbered <= to_unsigned(31, StateNumbered'length);
        end case;
    end process;


    HwBufferAddress <= std_logic_vector(WriteHwBufferAddressPointer) when HwBufferWriteEnable /= "0000" else std_logic_vector(ReadHwBufferAddressPointer);
    CmdId <= HwBufferReadData(31 downto 28);


    prcCmdProcessor : process(Clk, Rst) is
        procedure init is
        begin
            Operation <= OFF;
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
            CmdGotoAddressToGoto <= (others => '0');
            ForLoopCount <= (others => '0');
            CmdEndAddressToGoto <= (others => '0');
            AutoRestart <= '0';
            LoopCount <= (others => '0');
            ReceiveByteCount <= (others => '0');
            Tranceive <= '0';
            WriteHwBufferAddressPointer <= (others => '0');
            HwBufferWriteData <= (others => '0');
            ReceiveByteCount <= (others => '0');
            TxByte <= (others => '0');
            FetchedRxByte <= (others => '0');
            FetchedRxByteIsPending  <= '0';
            State <= ControllerOff;
        end procedure;

        procedure setDefaults is
        begin
            StartTimerPulse <= '0';
            FetchTxBytePulse <= '0';
            HwBufferProcessedPulse <= '0';
            HwBufferWriteEnable <= (others => '0');
        end procedure;

    begin

        if Rst = '1' then
            init;
            setDefaults;

        elsif rising_edge(Clk) then
            setDefaults;
            -- 
            if FetchRxBytePulse then
                FetchedRxByte <= RxByte;
                FetchedRxByteIsPending <= '1';
            end if;

            case State is

                when ControllerOff => -- 0
                    if Activation = ACTIVATED then
                        Operation <= IDLE;
                        State <= ControllerIdle;
                    end if;

                when ControllerIdle => -- 1
                    if Activation = DEACTIVATED then
                        init;
                    elsif SwBuffersPending > 0 then
                        SelectedBufferNumberOwnedBySw <= not SelectedBufferNumberOwnedBySw;
                        ReadHwBufferAddressPointer <= (others => '0');
                        ReceiveByteCount <= (others => '0');
                        Operation <= BUSY;
                        State <= SetCmdReadAddress;
                    end if;

                when ControllerRestart => -- 2
                    if Activation = DEACTIVATED then
                        init;
                    elsif SwBuffersPending > 0  then
                        SelectedBufferNumberOwnedBySw <= not SelectedBufferNumberOwnedBySw;
                        ReadHwBufferAddressPointer <= (others => '0');
                        ReceiveByteCount <= (others => '0');
                        State <= SetCmdReadAddress;
                    end if;

                when SetCmdReadAddress => -- 3
                    State <= CmdDispatch;

                when CmdDispatch => -- 4
                    if CmdId = CMDCONFIGCELL_CONFIGCELLID then
                        ReceiveFrameStartAddress <= HwBufferReadData(CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_POSITION + CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_WIDTH - 1 downto CMDCONFIGCELL_RECEIVEFRAMESTARTADDRESS_POSITION + 2);
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetCmdReadAddress;
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
                        State <= SetCmdReadAddress;
                    elsif CmdId = CMDTRANSMITCELL_TRANSMITCELLID then
                        PacketMultiplier <= unsigned(HwBufferReadData(CMDTRANSMITCELL_PACKETMULTIPLIER_POSITION + CMDTRANSMITCELL_PACKETMULTIPLIER_WIDTH - 1 downto CMDTRANSMITCELL_PACKETMULTIPLIER_POSITION));
                        PacketLength <= unsigned(HwBufferReadData(CMDTRANSMITCELL_PACKETLENGTH_POSITION + CMDTRANSMITCELL_PACKETLENGTH_WIDTH - 1 downto CMDTRANSMITCELL_PACKETLENGTH_POSITION));
                        PacketCount <= (others => '0');
                        ByteCount <= (others => '0');
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        ReadHwBufferRepeatAddressPointer <= ReadHwBufferAddressPointer + 1;
                        Tranceive <= '0';
                        State <= SetTxDataReadAddress;
                    elsif CmdId = CMDTRANSCEIVECELL_TRANSCEIVECELLID then
                        PacketMultiplier <= unsigned(HwBufferReadData(CMDTRANSCEIVECELL_PACKETMULTIPLIER_POSITION + CMDTRANSCEIVECELL_PACKETMULTIPLIER_WIDTH - 1 downto CMDTRANSCEIVECELL_PACKETMULTIPLIER_POSITION));
                        PacketLength <= unsigned(HwBufferReadData(CMDTRANSCEIVECELL_PACKETLENGTH_POSITION + CMDTRANSCEIVECELL_PACKETLENGTH_WIDTH - 1 downto CMDTRANSCEIVECELL_PACKETLENGTH_POSITION));
                        PacketCount <= (others => '0');
                        ByteCount <= (others => '0');
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        ReadHwBufferRepeatAddressPointer <= ReadHwBufferAddressPointer + 1;
                        Tranceive <= '1';
                        State <= SetTxDataReadAddress;
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


                when SetTxDataReadAddress => -- 5
                    State <= TransceiveByteStart;

                when TransceiveByteStart => -- 6
                    if ReadyToFetchTxByte then
                        if FetchedRxByteIsPending then
                            if Tranceive then
                                WriteHwBufferAddressPointer <= unsigned(ReceiveFrameStartAddress) + ReceiveByteCount(8 downto 2);
                                HwBufferWriteData(to_integer(ReceiveByteCount(1 downto 0)) * 8 + 7 downto to_integer(ReceiveByteCount(1 downto 0)) * 8) <= FetchedRxByte;
                                HwBufferWriteEnable(to_integer(ReceiveByteCount(1 downto 0))) <= '1';
                                ReceiveByteCount <= ReceiveByteCount + 1;
                            end if;
                            FetchedRxByteIsPending <= '0';
                        end if;
                        if PacketCount < PacketMultiplier then
                            if ByteCount < PacketLength then
                                TxByte <= HwBufferReadData(to_integer(ByteCount(1 downto 0)) * 8 + 7 downto to_integer(ByteCount(1 downto 0)) * 8);
                                FetchTxBytePulse <= '1';
                                State <= SetRxDataWriteToEnd;
                            else
                                State <= SetRxDataWriteToNext;
                            end if;
                        else
                            ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                            State <= SetCmdReadAddress;
                        end if;
                    end if;

                when SetRxDataWriteToNext => -- 7
                    State <= SetTxDataReadAddress;

                when SetRxDataWriteToEnd => -- 8
                    State <= TransceiveByteEnd;

                when TransceiveByteEnd => -- 9
                    if ReadyToFetchTxByte then
                        if FetchedRxByteIsPending = '1' then
                            if Tranceive then
                                WriteHwBufferAddressPointer <= unsigned(ReceiveFrameStartAddress) + ReceiveByteCount(8 downto 2);
                                HwBufferWriteData(to_integer(ReceiveByteCount(1 downto 0)) * 8 + 7 downto to_integer(ReceiveByteCount(1 downto 0)) * 8) <= FetchedRxByte;
                                HwBufferWriteEnable(to_integer(ReceiveByteCount(1 downto 0))) <= '1';
                                ReceiveByteCount <= ReceiveByteCount + 1;
                            end if;
                            FetchedRxByteIsPending <= '0';
                        end if;
                        if ByteCount < PacketLength - 1 then
                            ByteCount <= ByteCount + 1;
                            if ByteCount( 1 downto 0) = 3 then
                                ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                            end if;
                            State <= SetRxDataWriteToNext;
                        else
                            if PacketCount < PacketMultiplier - 1 then
                                ByteCount <= (others => '0');
                                PacketCount <= PacketCount + 1;
                                ReadHwBufferAddressPointer <= ReadHwBufferRepeatAddressPointer;
                                State <= SetRxDataWriteToNext;
                            else
                                ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                                State <= SetLastRxDataWrite;
                            end if;
                        end if;
                    end if;

                when SetLastRxDataWrite => -- 10
                    if RxByteIsPending or FetchedRxByteIsPending then
                        State <= StoreLastRxByte;
                    else
                        State <= SetCmdReadAddress;
                    end if;

                when StoreLastRxByte => -- 11
                    if FetchedRxByteIsPending then
                        if Tranceive then
                            WriteHwBufferAddressPointer <= unsigned(ReceiveFrameStartAddress) + ReceiveByteCount(8 downto 2);
                            HwBufferWriteData(to_integer(ReceiveByteCount(1 downto 0)) * 8 + 7 downto to_integer(ReceiveByteCount(1 downto 0)) * 8) <= FetchedRxByte;
                            HwBufferWriteEnable(to_integer(ReceiveByteCount(1 downto 0))) <= '1';
                            ReceiveByteCount <= ReceiveByteCount + 1;
                        end if;
                        FetchedRxByteIsPending <= '0';
                    end if;
                    State <= SetLastRxDataWrite;

                when StartTimer => -- 12
                    State <= RunTimer;

                when RunTimer => -- 13
                    if TimerExpired then
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetCmdReadAddress;
                    end if;

                when Goto => -- 14
                    ReadHwBufferAddressPointer <= CmdGotoAddressToGoto(8 downto 2);
                    State <= SetCmdReadAddress;

                when ForLoop => -- 15
                    if LoopCount < ForLoopCount then
                        LoopCount <= LoopCount + 1;
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 1;
                        State <= SetCmdReadAddress;
                    else
                        ReadHwBufferAddressPointer <= ReadHwBufferAddressPointer + 2;
                        LoopCount <= (others => '0');
                        State <= SetCmdReadAddress;
                    end if;

                when EndOrRestart => -- 16
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
            SwBuffersPending <= (others => '0');
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
