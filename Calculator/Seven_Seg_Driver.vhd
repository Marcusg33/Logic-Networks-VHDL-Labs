library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Seven_segment_driver is
    generic (
        size : integer := 20
    );
    Port (
        clk : in std_logic;
        rst : in std_logic; -- Low active reset
        binary_input : in std_logic_vector( 15 downto 0 );
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
        AN : out std_logic_vector( 3 downto 0 )
  );

end Seven_segment_driver;

architecture Behavioral of Seven_segment_driver is
    -- We will use a counter to derive the frequency for the displays
    -- clk is 100 MHz, we use 3 bits to address the display, so we count every
    -- size - 3 bits. To get ~100 Hz per digit, we need 20 bits, so that we divide
    -- by 2^20.
    signal flick_counter : unsigned( size - 1 downto 0 );
    -- The digit is temporarily stored here
    signal digit : std_logic_vector( 3 downto 0 );
    -- Collect the values of the cathodes here
    signal cathodes : std_logic_vector( 7 downto 0 );

    -- Divide the input into different digits
    signal digit0 : std_logic_vector( 3 downto 0 );
    signal digit1 : std_logic_vector( 3 downto 0 );
    signal digit2 : std_logic_vector( 3 downto 0 );
    signal digit3 : std_logic_vector( 3 downto 0 );

    -- Select which digit to display
    signal selector : std_logic_vector( 1 downto 0 );

begin

    -- Update the digits
    digit0 <= binary_input( 3 downto 0 );
    digit1 <= binary_input( 7 downto 4 );
    digit2 <= binary_input( 11 downto 8 );
    digit3 <= binary_input( 15 downto 12 );

    -- Divide the clk
    process ( clk, rst ) begin
        if rst = '0' then
        flick_counter <= ( others => '0' );
        elsif rising_edge( clk ) then
        flick_counter <= flick_counter + 1;
        end if;
    end process;

    -- Update the selector
        selector <= std_logic_vector( flick_counter( size - 1 downto size - 2 ) );
    -- Select the anode
    with selector select
        AN <=
        "1110" when "00",
        "1101" when "01",
        "1011" when "10",
        "0111" when others;

    -- Select the digit
    with selector select
        digit <=
        digit0 when "00",
        digit1 when "01",
        digit2 when "10",
        digit3 when others;

    -- Decode the digit
    with digit select
        cathodes <=
        -- DP, CG, CF, CE, CD, CC, CB, CA
        "11000000" when "0000",
        "11111001" when "0001",
        "10100100" when "0010",
        "10110000" when "0011",
        "10011001" when "0100",
        "10010010" when "0101",
        "10000010" when "0110",
        "11111000" when "0111",
        "10000000" when "1000",
        "10010000" when "1001",
        "10001000" when "1010",
        "10000011" when "1011",
        "11000110" when "1100",
        "10100001" when "1101",
        "10000110" when "1110",
        "10001110" when others;

    DP <= cathodes( 7 );
    CG <= cathodes( 6 );
    CF <= cathodes( 5 );
    CE <= cathodes( 4 );
    CD <= cathodes( 3 );
    CC <= cathodes( 2 );
    CB <= cathodes( 1 );
    CA <= cathodes( 0 );

end Behavioral;