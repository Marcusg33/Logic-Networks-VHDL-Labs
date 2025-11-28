library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity calcolatrice_testbench is
--  Port ( );
end calcolatrice_testbench;

architecture Behavioral of calcolatrice_testbench is
  signal clock, reset : std_logic;
  signal SW : std_logic_vector( 15 downto 0 );
  signal LED : std_logic_vector( 15 downto 0 );
  signal CA, CB, CC, CD, CE, CF, CG, DP : std_logic;
  signal AN : std_logic_vector( 3 downto 0 );
  signal BTNC, BTNU, BTNL, BTNR, BTND : std_logic;
begin

  -- Instantiate the dut
  dut : entity work.calcolatrice( Behavioral ) port map (
    clock => clock,
    reset => reset,
    SW => SW,
    LED => LED,
    CA => CA, CB => CB, CC => CC, CD => CD, CE => CE, CF => CF, CG => CG, DP => DP,
    AN => AN,
    BTNC => BTNC, BTNU => BTNU, BTNL => BTNL, BTNR => BTNR, BTND => BTND
  );

  process begin
    clock <= '1'; wait for 5 ns;
    clock <= '0'; wait for 5 ns;
  end process;

  process begin
    reset <= '0'; wait for 130 ns;
    reset <= '1';
    wait;
  end process;

  process begin
    SW <= "0000000000000000";
    BTNC <= '0';
    BTNU <= '0';
    BTNL <= '0';
    BTNR <= '0';
    BTND <= '0';
    wait for 156 ns;

    -- set number '41' on the switches
    SW <= "0000000000101001"; -- 41
    wait for 2 ns;

    -- Initialize the accumulator (click on center button)
    BTNC <= '1';
    wait for 11 ms;
    BTNC <= '0';
    wait for 100 ns;

    -- Perform a single accumulation (click on the up button)
    BTNU <= '1';
    wait for 11 ms;
    BTNU <= '0';
    wait for 100 ns;

    -- set number '6' on the switches
    SW <= "0000000000000110"; -- 6

    -- Perform a single multiplication (click on the right button)
    BTNR <= '1';
    wait for 11 ms;
    BTNR <= '0';
    wait;
  end process;

end Behavioral;
