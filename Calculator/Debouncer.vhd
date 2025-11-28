library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debouncer is
    generic(
        counter_size : integer := 12
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        bouncy    : in  std_logic;
        pulse   : out std_logic
    );
end entity Debouncer;

architecture Behavioral of Debouncer is
    signal counter      : std_logic_vector(counter_size-1 downto 0) := (others => '1');
    signal prev_state   : std_logic := '0';
    signal outputting   : std_logic := '0';
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter    <= (others => '1');
            prev_state <= '0';
            pulse  <= '0';
            outputting <= '0';
        elsif rising_edge(clk) then
            if outputting = '1' then
                -- Output has been updated, wait for next change
                outputting <= '0';
                counter <= (others => '1');
                pulse <= '0';
            else if bouncy /= prev_state then
                -- Button state changed, reset counter
                counter <= (others => '1');
                prev_state <= bouncy;
            else
                if unsigned(counter) > 0 then
                    counter <= std_logic_vector(unsigned(counter) - 1);
                else
                    -- Counter has expired, update clean output
                    pulse <= prev_state;
                    outputting <= '1';
                end if;
            end if;
        end if;
    end process;
end architecture Behavioral;