library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        ac_init        : in  std_logic;
        ac_enable      : in  std_logic;
        data_in     : in  signed(15 downto 0);
        result_out  : out signed(15 downto 0)
    );
end entity Accumulator;

architecture Behavioral of Accumulator is
begin
    process(clk, rst)
    begin
        if rst = '0' then
            result_out <= (others => '0');
        elsif rising_edge(clk) then
            if ac_init = '1' then
                result_out <= (others => '0');
            elsif ac_enable = '1' then
                result_out <= data_in;
            end if;
        end if;
    end process;
end architecture Behavioral;