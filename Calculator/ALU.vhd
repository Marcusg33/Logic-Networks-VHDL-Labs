library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU entity definition: inputs must take the sign into account
entity ALU is
    Port (
        a        : in  signed( 15 downto 0 );
        b        : in  signed( 15 downto 0 );  
        add      : in  std_logic;
        subtract : in  std_logic;
        multiply : in  std_logic;
        divide   : in  std_logic;
        r        : out signed( 15 downto 0 )
    );
end ALU;

-- ALU architecture definition
architecture Behavioral of ALU is
    signal temp_res : signed(31 downto 0);
begin

    process (a, b, add, subtract, multiply, divide, temp_res)
    begin
        r <= (others => '0');  -- default assignment

        if add = '1' then
        r <= a + b;

        elsif subtract = '1' then
        r <= a - b;

        elsif multiply = '1' then
        temp_res <= a * b;
        r <= temp_res(15 downto 0);  -- lower 16 bits

        elsif divide = '1' then
        r <= a / b;

        end if;
    end process;

end Behavioral;