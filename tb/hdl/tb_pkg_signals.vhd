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

package tb_pkg_signals is

    -- Inpus signal record
    type t_singals_in is
        record
            -- TODO: Add here all your inputs
            in_signal   : std_logic;
            in_signal_1 : std_logic_vector(7 downto 0);
        end record;

    -- Output signal record
    type t_singals_out is
        record
            -- TODO: Add here all your outputs
            my_signal   : std_logic;
            my_signal_1 : std_logic_vector(7 downto 0);
        end record;

    -- Dafault values
    function signals_in_init return t_singals_in;
    function signals_out_init return t_singals_out;

    -- SimStm access prcedures
    procedure write_signal(signal   signals       : out t_singals_out;
                           variable signal_number : in  integer;
                           variable value         : in  integer;
                           variable valid         : out integer);

    procedure read_signal(signal   signals       : in t_singals_in;
                          variable signal_number : in  integer;
                          variable value         : out integer;
                          variable valid         : out integer);

end tb_pkg_signals;

package body tb_pkg_signals is
    -- Iniziled values for the input record
    function signals_in_init return t_singals_in is
        variable signals : t_singals_in;
    begin
        -- TODO: Set here your init values
        signals.in_signal := 'U';
        signals.in_signal_1 := (others => 'U');
        return signals;
    end signals_in_init;

    -- Iniziled values for the output record
    function signals_out_init return t_singals_out is
        variable signals : t_singals_out;
    begin
        -- TODO: Set here your init values
        signals.my_signal := '0';
        signals.my_signal_1 := (others => '0');
        return signals;
    end signals_out_init;

    -- SimStm Mapping for output singals
    procedure write_signal( signal   signals       : out t_singals_out;
                            variable signal_number : in  integer;
                            variable value         : in  integer;
                            variable valid         : out integer) is
        variable temp_var : std_logic_vector(31 downto 0);
    begin
        valid := 1;
        temp_var := std_logic_vector(to_unsigned(value, 32));

        case signal_number is
            -- TODO: add here your SimStm mapping
            when 0 =>
                signals.my_signal <= temp_var(0);
            when 1 =>
                signals.my_signal_1 <= temp_var(signals.my_signal_1'left downto 0);
            when others =>
                valid := 0;
        end case;
        wait for 1 ps;
    end procedure write_signal;

    -- SimStm Mapping for input singals
    procedure read_signal(  signal   signals       : in  t_singals_in;
                            variable signal_number : in  integer;
                            variable value         : out integer;
                            variable valid         : out integer) is
        variable temp_var : std_logic_vector(31 downto 0);
    begin
        valid := 1;
        temp_var := (others => '0');

        case signal_number is
            -- TODO: add here your SimStm mapping
            when 0 =>
                temp_var(0) := signals.in_signal;
            when 1 =>
                temp_var(signals.in_signal_1'left downto 0) := signals.in_signal_1;
            when others =>
                valid := 0;
        end case;

        value := to_integer(unsigned(temp_var));
    end procedure read_signal;

end tb_pkg_signals;
