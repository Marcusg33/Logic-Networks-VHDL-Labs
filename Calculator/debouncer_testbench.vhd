library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer_testbench is
--  Port ( );
end debouncer_testbench;

architecture Behavioral of debouncer_testbench is

component debouncer
  generic (
    counter_size : integer := 12
  );
  port (
    clock, reset : in std_logic;
    bouncy : in std_logic;
    pulse : out std_logic
  );
end component;

signal clock : std_logic := '0';
signal reset : std_logic := '0';
signal bouncy : std_logic := '0';
signal pulse : std_logic := '0';

begin

   dut : debouncer
   port map(
      clock  => clock,
      reset  => reset,
      bouncy => bouncy,
      pulse   => pulse
   );

   clock <= not(clock) after 5 ns;

   dut_test_proc : process
   begin

      reset <= '0';
      wait for 10 ns;
      reset <= '1';
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
