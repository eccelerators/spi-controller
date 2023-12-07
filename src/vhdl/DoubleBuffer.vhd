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

entity DoubleBuffer is
    port(
        Clk : in std_logic;
        Rst : in std_logic; -- @suppress "Unused port: Rst is not used in work.DualBuffer(RTL)"
        SelectedBufferNumberOwnedBySw : in std_logic;
        HwBufferWriteEnable : in std_logic_vector(3 downto 0);
        HwBufferAddress : in std_logic_vector(6 downto 0);
        HwBufferWriteData : in std_logic_vector(31 downto 0);
        HwBufferReadData : out std_logic_vector(31 downto 0);
        SwBufferWriteEnable : in std_logic_vector(3 downto 0);
        SwBufferAddress : in std_logic_vector(6 downto 0);
        SwBufferWriteData : in std_logic_vector(31 downto 0);
        SwBufferReadData : out std_logic_vector(31 downto 0)
    );
end entity;

architecture RTL of DoubleBuffer is
    signal BufferWriteEnable0 : std_logic_vector(3 downto 0);
    signal BufferAddress0 : std_logic_vector(6 downto 0);
    signal BufferWriteData0 : std_logic_vector(31 downto 0);
    signal BufferReadData0 : std_logic_vector(31 downto 0);
    signal BufferWriteEnable1 : std_logic_vector(3 downto 0);
    signal BufferAddress1 : std_logic_vector(6 downto 0);
    signal BufferWriteData1 : std_logic_vector(31 downto 0);
    signal BufferReadData1 : std_logic_vector(31 downto 0);

begin

    prcBufferSwitch : process(SelectedBufferNumberOwnedBySw, BufferReadData0, BufferReadData1, HwBufferAddress, HwBufferWriteData, HwBufferWriteEnable, SwBufferAddress, SwBufferWriteData, SwBufferWriteEnable) is
    begin
        if SelectedBufferNumberOwnedBySw = '0' then
            BufferWriteEnable0 <= SwBufferWriteEnable;
            BufferAddress0 <= SwBufferAddress;
            BufferWriteData0 <= SwBufferWriteData;
            SwBufferReadData <= BufferReadData0;
            BufferWriteEnable1 <= HwBufferWriteEnable;
            BufferAddress1 <= HwBufferAddress;
            BufferWriteData1 <= HwBufferWriteData;
            HwBufferReadData <= BufferReadData1;
        else
            BufferWriteEnable1 <= SwBufferWriteEnable;
            BufferAddress1 <= SwBufferAddress;
            BufferWriteData1 <= SwBufferWriteData;
            SwBufferReadData <= BufferReadData1;
            BufferWriteEnable0 <= HwBufferWriteEnable;
            BufferAddress0 <= HwBufferAddress;
            BufferWriteData0 <= HwBufferWriteData;
            HwBufferReadData <= BufferReadData0;
        end if;

    end process;

    i0_Ram : entity work.Ram
        port map(
            Clk => Clk,
            WriteEnable => BufferWriteEnable0,
            Address => BufferAddress0,
            WriteData => BufferWriteData0,
            ReadData => BufferReadData0
        );

    i1_Ram : entity work.Ram
        port map(
            Clk => Clk,
            WriteEnable => BufferWriteEnable1,
            Address => BufferAddress1,
            WriteData => BufferWriteData1,
            ReadData => BufferReadData1
        );

end architecture;
