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



entity tb_top_axi4lite is
    generic (
        stimulus_path : string := "../tb/simstm/";
        stimulus_file : string := "TestMainAxi4Lite.stm"
    );
end;

architecture behavioural of tb_top_axi4lite is

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

    signal SpiControllerIfcAxi4LiteDown : T_SpiControllerIfcAxi4LiteDown;
    signal SpiControllerIfcAxi4LiteUp : T_SpiControllerIfcAxi4LiteUp;
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

    tb_FileIo_i : entity work.tb_simstm
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
          
    SpiControllerIfcAxi4LiteDown.AWVALID <= bus_down.axi4lite.AWVALID;
    SpiControllerIfcAxi4LiteDown.AWADDR <= bus_down.axi4lite.AWADDR(SpiControllerIfcAxi4LiteDown.AWADDR'LENGTH - 1 downto 0);
    SpiControllerIfcAxi4LiteDown.AWPROT <= bus_down.axi4lite.AWPROT;
    SpiControllerIfcAxi4LiteDown.WVALID <= bus_down.axi4lite.WVALID;
    SpiControllerIfcAxi4LiteDown.WDATA <= bus_down.axi4lite.WDATA;
    SpiControllerIfcAxi4LiteDown.WSTRB <= bus_down.axi4lite.WSTRB;
    SpiControllerIfcAxi4LiteDown.BREADY <= bus_down.axi4lite.BREADY;
    SpiControllerIfcAxi4LiteDown.ARVALID <= bus_down.axi4lite.ARVALID;
    SpiControllerIfcAxi4LiteDown.ARADDR <= bus_down.axi4lite.ARADDR(SpiControllerIfcAxi4LiteDown.ARADDR'LENGTH - 1 downto 0);
    SpiControllerIfcAxi4LiteDown.ARPROT <= bus_down.axi4lite.ARPROT;
    SpiControllerIfcAxi4LiteDown.RREADY <= bus_down.axi4lite.RREADY;
    
    bus_up.axi4lite.AWREADY <= SpiControllerIfcAxi4LiteUp.AWREADY;
    bus_up.axi4lite.WREADY <= SpiControllerIfcAxi4LiteUp.WREADY;
    bus_up.axi4lite.BVALID <= SpiControllerIfcAxi4LiteUp.BVALID;
    bus_up.axi4lite.BRESP <= SpiControllerIfcAxi4LiteUp.BRESP;
    bus_up.axi4lite.ARREADY <= SpiControllerIfcAxi4LiteUp.ARREADY;
    bus_up.axi4lite.RVALID <= SpiControllerIfcAxi4LiteUp.RVALID;
    bus_up.axi4lite.RDATA <= SpiControllerIfcAxi4LiteUp.RDATA;
    bus_up.axi4lite.RRESP <= SpiControllerIfcAxi4LiteUp.RRESP;
               
    i_SpiControllerWithAxi4LiteBus : entity work.SpiControllerWithAxi4LiteBus
        port map(
            Clk => Clk,
            Rst => Rst,
            SpiControllerIfcAxi4LiteDown =>  SpiControllerIfcAxi4LiteDown,
            SpiControllerIfcAxi4LiteUp => SpiControllerIfcAxi4LiteUp,
            SpiControllerIfcTrace => SpiControllerIfcTrace,
            SClk => SClk,
            MiSo => MiSo,
            MoSi => MoSi,
            nCs => nCs
        );


    WPn <= 'H';
    HOLDn <= 'H';
    MiSo <= 'H';

    -- W25Q128JVxIM: QSPI mode is off by default ( W25Q128JVxIQ: QSPI mode is on by default )
    i_W25Q128JVxIM : entity work.W25Q128JVxIM
        port map(
            CLK => SClk,
            CSn => nCs(0),
            DIO => MoSi,
            DO => MiSo,
            WPn => WPn,
            HOLDn => HOLDn
        );
  
end;