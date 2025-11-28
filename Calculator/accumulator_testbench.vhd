----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 04/25/2020 04:57:11 PM
-- Design Name:
-- Module Name: accumulator_testbench - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity accumulator_testbench is
--  Port ( );
end accumulator_testbench;

architecture Behavioral of accumulator_testbench is

component accumulator
  Port (
    clock, reset : in std_logic;
    acc_init, acc_enable : in std_logic;
    acc_in : in signed( 15 downto 0 );
    acc_out : out signed( 15 downto 0 )
  );
end component;

signal clock : std_logic := '0';
signal reset : std_logic := '0';
signal acc_init : std_logic := '0';
signal acc_enable : std_logic := '0';
signal acc_in : signed(15 downto 0) := (others => '0');
signal acc_out : signed(15 downto 0) := (others => '0');

begin

 uut : accumulator
 port map(
    clock      => clock,
    reset      => reset,
    acc_init   => acc_init,
    acc_enable => acc_enable,
    acc_in     => acc_in,
    acc_out    => acc_out
 );

 clock <= not(clock) after 5 ns;

 uut_test_proc : process
 begin

    reset <= '1';
    wait for 20 ns;
    reset <= '0';

    wait for 10 ns;

    acc_in <= "0000000000000011"; --3
    wait for 10 ns;

    acc_enable <= '1';
    wait for 10 ns;
    acc_enable <= '0';

    wait for 50 ns;

    acc_init <= '1';
    wait for 10 ns;
    acc_init <= '0';

 wait;
 end process;

end Behavioral;
