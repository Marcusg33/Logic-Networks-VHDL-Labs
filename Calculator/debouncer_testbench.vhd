library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer_testbench is
--  Port ( );
end debouncer_testbench;

architecture Behavioral of debouncer_testbench is

component Debouncer
  generic (
    counter_size : integer := 12
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    bouncy : in std_logic;
    pulse : out std_logic
  );
end component;

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal bouncy : std_logic := '0';
signal pulse : std_logic := '0';

begin

   dut : Debouncer
   port map(
      clk  => clk,
      rst  => rst,
      bouncy => bouncy,
      pulse   => pulse
   );

   clk <= not(clk) after 5 ns;

   dut_test_proc : process
   begin

      rst <= '0';
      wait for 10 ns;
      rst <= '1';
      wait for 10 ns;

      bouncy <= '0';
      wait for 10 ns;

      bouncy <= '1';
      wait for 10 ns;

      bouncy <= '0';
      wait for 10 ns;

      bouncy <= '1';
      wait for 15 us;

      bouncy <= '0';
      wait for 10 ns;

      bouncy <= '1';
      wait for 45 us;

      bouncy <= '0';
      wait for 100 ns;

   wait;
   end process;

end Behavioral;
