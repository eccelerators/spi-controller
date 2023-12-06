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
use work.tb_bus_pkg.all;
use work.tb_signals_pkg.all;
use work.tb_base_pkg.all;


entity tb_top_wishbone is
    generic (
        stimulus_path : string := "../tb/simstm/";
        stimulus_file : string := "TestMainWishbone.stm"
    );
end;

architecture behavioural of tb_top_wishbone is

    signal simdone : std_logic := '0';
    
    signal Clk : std_logic := '0';
    signal Rst : std_logic := '1';
    signal TimeoutAck_Detected : std_logic := '0';
    signal TimeoutAck_Rec_Clear : std_logic := '0';
    
    signal executing_line : integer := 0;
    signal executing_file : text_line;
    signal marker : std_logic_vector(15 downto 0) := (others => '0');
    
    signal signals_in : t_signals_in;
    signal signals_out : t_signals_out;

    signal bus_down : t_bus_down;
    signal bus_up : t_bus_up;    

    signal SpiControllerIfcWishboneDown : T_SpiControllerIfcWishboneDown;
    signal SpiControllerIfcWishboneUp : T_SpiControllerIfcWishboneUp;
    signal SpiControllerIfcTrace : T_SpiControllerIfcTrace;
    
    signal SClk : std_logic;
    signal MiSo : std_logic;
    signal MoSi : std_logic;
    signal nCs : std_logic_vector(14 downto 0);
    signal WPn : std_logic;
    signal HOLDn : std_logic;
    
begin

    Rst <= transport '0' after 100 ns;
    Clk <= transport (not Clk) and (not SimDone)  after 10 ns / 2; -- 100MHz

    signals_in.in_signal <= '0';
    signals_in.in_signal_1 <= (others => '0');
    signals_in.in_signal_2 <= '0';
    signals_in.in_signal_3 <= '0';
    
    i_tb_simstm : entity work.tb_simstm
        generic map (
            stimulus_path => stimulus_path,
            stimulus_file => stimulus_file          
        )
        port map (
            clk => Clk,
            rst => Rst,
            simdone => SimDone,       
            executing_line => executing_line,
            executing_file => executing_file,
            marker => marker,
            signals_in => signals_in,
            signals_out => signals_out,
            bus_down => bus_down,
            bus_up => bus_up
        );
        
    SpiControllerIfcWishboneDown.Adr <= bus_down.wishbone.adr(SpiControllerIfcWishboneDown.Adr'LENGTH - 1 downto 0);
    SpiControllerIfcWishboneDown.Sel <= bus_down.wishbone.sel;
    SpiControllerIfcWishboneDown.DatIn <= bus_down.wishbone.data;
    SpiControllerIfcWishboneDown.We <= bus_down.wishbone.we;
    SpiControllerIfcWishboneDown.Stb <= bus_down.wishbone.stb;
    SpiControllerIfcWishboneDown.Cyc <= bus_down.wishbone.cyc;
    
    bus_up.wishbone.data <= SpiControllerIfcWishboneUp.DatOut;
    bus_up.wishbone.ack <= SpiControllerIfcWishboneUp.Ack;
               
    i_SpiController : entity work.SpiControllerWithWishboneBus
        port map(
            Clk => Clk,
            Rst => Rst,
            SpiControllerIfcWishboneDown =>  SpiControllerIfcWishboneDown,
            SpiControllerIfcWishboneUp => SpiControllerIfcWishboneUp,
            SpiControllerIfcTrace => SpiControllerIfcTrace,
            SClk => SClk,
            MiSo => MiSo,
            MoSi => MoSi,
            nCs => nCs
        );


    WPn <= '1';
    HOLDn <= '1';
    MiSo <= 'H';

    i_s25fl129p00 : entity work.s25fl129p00
        generic map (
            mem_file_name => "./../tb-ip/hdl/Infineon/s25fl129p00/mem/flash.mem",
            otp_file_name => "./../tb-ip/hdl/Infineon/s25fl129p00/mem/otp.mem"
        )
        port map(
            SCK => SClk,
            CSNeg => nCs(0),
            SI => MoSi,
            SO => MiSo,
            WPNeg => WPn,
            HOLDNeg => HOLDn
        );   
  
end;