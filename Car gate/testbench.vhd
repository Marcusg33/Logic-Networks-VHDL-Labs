library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end entity tb;

architecture behaviour of tb is

    component Car_Parking_System_VHDL is 
        port(
            clk : in std_logic;
            reset_n : in std_logic;
            front_sensor : in std_logic;
            back_sensor : in std_logic;
            password_1 : in std_logic_vector(1 downto 0);
            password_2 : in std_logic_vector(1 downto 0);
            pswd_in : in std_logic;
            GREEN_LED : out std_logic;
            RED_LED : out std_logic;
            HEX_1 : out std_logic_vector(6 downto 0);
            HEX_2 : out std_logic_vector(6 downto 0);
            car_count : out std_logic_vector(6 downto 0)
        );
    end component Car_Parking_System_VHDL;

    constant clock_period : time := 20 ns;

    signal clock : std_logic := '1';
    signal reset : std_logic := '1';
    signal front_sensor : std_logic := '0';
    signal back_sensor : std_logic := '0';
    signal password_1 : std_logic_vector(1 downto 0) := "00";
    signal password_2 : std_logic_vector(1 downto 0) := "00";
    signal pswd_in : std_logic := '0';
    signal GREEN_LED : std_logic;
    signal RED_LED : std_logic;
    signal HEX_1 : std_logic_vector(6 downto 0);
    signal HEX_2 : std_logic_vector(6 downto 0);
    signal car_count : std_logic_vector(6 downto 0);

begin

    DUT : Car_Parking_System_VHDL port map( -- Device under test
        clk => clock,
        reset_n => reset,
        front_sensor => front_sensor,
        back_sensor => back_sensor,
        password_1 => password_1,
        password_2 => password_2,
        pswd_in => pswd_in,
        GREEN_LED => GREEN_LED,
        RED_LED => RED_LED,
        HEX_1 => HEX_1,
        HEX_2 => HEX_2,
        car_count => car_count
    );

    -- Define the signal clock
    clock_process : process
    begin
        wait for clock_period / 2;
        clock <= not clock;
    end process clock_process;

    -- Testbench process
    main_tb : process
    begin
        -- Initial reset
        wait for clock_period;
        reset <= '0';
        wait for clock_period;
        reset <=  '1';
        wait for clock_period;

        -- Normal entry
        front_sensor <=  '1'; -- Car approaches
        wait for 2*clock_period;
        password_1 <= "01";
        password_2 <= "10";
        pswd_in <= '1'; -- The password is set
        wait for 10*clock_period;
        front_sensor <= '0'; -- The car starts moving
        password_1 <= "00";
        password_2 <= "00";
        pswd_in <= '0'; -- The password is reset
        wait for 2*clock_period;
        back_sensor <= '1'; -- The car is now inside the parking
        wait for 2*clock_period;
        back_sensor <= '0'; -- The car leaves the parking entrance

        wait for 20*clock_period;

        -- Wrong password
        front_sensor <= '1'; -- Car approaches
        wait for 2*clock_period;
        password_1 <= "11";
        password_2 <= "11";
        pswd_in <= '1'; -- The wrong password is set
        wait for 12*clock_period;
        password_1 <= "01";
        password_2 <= "10";
        pswd_in <= '1'; -- The right password is set
        wait for 12*clock_period;
        front_sensor <= '0'; 
        back_sensor <= '1'; -- The car moves inside
        password_1 <= "00";
        password_2 <= "00";
        pswd_in <= '0'; -- The password is reset
        wait for 2*clock_period;
        back_sensor <= '0'; -- The car leaves the parking entrance

        wait for 20*clock_period;

        -- Multiple cars
        front_sensor <=  '1'; -- Car approaches
        wait for 2*clock_period;
        password_1 <= "01";
        password_2 <= "10";
        pswd_in <= '1'; -- The password is set
        wait for 10*clock_period;
        back_sensor <= '1'; -- The first car enters, but another one follows
        wait for 3*clock_period;
        back_sensor <= '0'; -- The first car leaves the parking entrance
        wait for 15*clock_period;
        front_sensor <= '0';
        back_sensor <= '1'; -- The second car enters
        password_1 <= "00";
        password_2 <= "00";
        pswd_in <= '0'; -- The password is reset
        wait for 2*clock_period;
        back_sensor <= '0'; -- The second car leaves the parking entrance

        wait for 20*clock_period;
        
        -- Timeout
        front_sensor <=  '1'; -- Car approaches
        wait for 30*clock_period; -- The password is not set in time
        password_1 <= "01";
        password_2 <= "10";
        pswd_in <= '1'; -- The password is set
        wait for 10*clock_period;
        front_sensor <= '0'; -- The car starts moving
        password_1 <= "00";
        password_2 <= "00";
        pswd_in <= '0'; -- The password is reset
        wait for 2*clock_period;
        back_sensor <= '1'; -- The car is now inside the parking
        wait for 2*clock_period;
        back_sensor <= '0'; -- The car leaves the parking entrance

        wait for 20*clock_period;

        -- Reset
        front_sensor <=  '1'; -- Car approaches
        wait for 2*clock_period;
        password_1 <= "01";
        password_2 <= "10";
        pswd_in <= '1'; -- The password is set
        wait for 13*clock_period;
        front_sensor <= '0';
        reset <= '0'; -- Reset value is given
        wait for 3*clock_period;
        
        wait;

    end process main_tb;
        
end architecture behaviour;