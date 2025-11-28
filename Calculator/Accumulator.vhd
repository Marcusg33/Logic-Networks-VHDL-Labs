library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        ac_init        : in  std_logic;
        ac_enable      : in  std_logic;
        data_in     : in  std_logic_vector(15 downto 0);
        result_out  : out std_logic_vector(15 downto 0)
    );
end entity Accumulator;