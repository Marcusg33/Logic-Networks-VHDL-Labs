library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU entity definition: inputs must take the sign into account!
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

-- Definizione architettura ALU
architecture Behavioral of ALU is
    signal moltiplica : signed(31 downto 0);
begin

    process (a, b, add, subtract, multiply, divide, moltiplica)
        variable to_devide : signed(15 downto 0);
        variable result    : signed(15 downto 0);
    begin
        r <= (others => '0');  -- default assignment

        if add = '1' then
        r <= a + b;

        elsif subtract = '1' then
        r <= a - b;

        elsif multiply = '1' then
        moltiplica <= a * b;
        r <= moltiplica(15 downto 0);  -- lower 16 bits

        elsif divide = '1' then
        to_devide := a;
        result := (others => '0');  -- reset result each time
        while to_devide >= b loop
            to_devide := to_devide - b;
            result := result + 1;
        end loop;
        r <= result;
        end if;
    end process;

end Behavioral;