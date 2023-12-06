library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity Ram is
	port(
		Clk : in std_logic;
		WriteEnable : in std_logic_vector(3 downto 0);
		Address : in std_logic_vector(6 downto 0);
		WriteData : in std_logic_vector(31 downto 0);
		ReadData : out std_logic_vector(31 downto 0)
	);
end entity;

architecture RTL of Ram is

	type ram_type is array (0 to (2 ** Address'length * 4) - 1) of std_logic_vector(WriteData'range);
	signal Ram : ram_type := (others => x"BABABABA");
	signal ReadAddress : std_logic_vector(Address'range);

begin

	RamProc : process(Clk) is
	begin
		if rising_edge(Clk) then
			if WriteEnable(0) = '1' then
				Ram(to_integer(unsigned(Address)))(7 downto 0) <= WriteData(7 downto 0);
			end if;
			if WriteEnable(1) = '1' then
				Ram(to_integer(unsigned(Address)))(15 downto 8) <= WriteData(15 downto 8);
			end if;
			if WriteEnable(2) = '1' then
				Ram(to_integer(unsigned(Address)))(23 downto 16) <= WriteData(23 downto 16);
			end if;
			if WriteEnable(3) = '1' then
				Ram(to_integer(unsigned(Address)))(31 downto 24) <= WriteData(31 downto 24);
			end if;
			ReadAddress <= Address;
		end if;
	end process;

	ReadData <= Ram(to_integer(unsigned(ReadAddress)));

end architecture;
