library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_testbench is
--  Port ( );
end alu_testbench;

architecture Behavioral of alu_testbench is

component alu
  Port(
    a, b : in signed( 15 downto 0 );
    add, subtract, multiply, divide : in std_logic;
    r : out signed( 15 downto 0 )
  );
end component;

signal a : signed(15 downto 0) := (others => '0');
signal b : signed(15 downto 0) := (others => '0');
signal add, subtract, multiply, divide : std_logic := '0';
signal r : signed(15 downto 0) := (others => '0');

begin

   dut: alu
   port map(
      a        => a,
      b        => b,
      add      => add,
      subtract => subtract,
      multiply => multiply,
      divide   => divide,
      r        => r
   );

    alu_test_proc : process
    begin

     wait for 100 ns;

     a <= "0000000000000101"; -- 5
     b <= "0000000000000010"; -- 2

     wait for 10 ns;

     add <= '1';
     wait for 10 ns;
     add <= '0';
     wait for 10 ns;

     subtract <= '1';
     wait for 10 ns;
     subtract <= '0';
     wait for 10 ns;

     multiply <= '1';
     wait for 10 ns;
     multiply <= '0';
     wait for 10 ns;

     divide <= '1';
     wait for 10 ns;
     divide <= '0';
     wait for 10 ns;

    wait;
    end process;

end Behavioral;
