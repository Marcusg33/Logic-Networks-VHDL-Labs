library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is 
    port(
        clk : in std_logic;
        reset_n : in std_logic; -- Active low asynchronus
        front_sensor : in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0); -- Correct "01"
        password_2 : in std_logic_vector(1 downto 0); -- Correct "10"
        pswd_in : in std_logic; -- Flag (1 when the password is set by the user)
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0); -- Segments gfedcba
        HEX_2 : out std_logic_vector(6 downto 0); -- Segments gfedcba
        car_count : out std_logic_vector(6 downto 0) -- Car counter
    );
end Car_Parking_System_VHDL;

architecture behaviour of Car_Parking_System_VHDL is
    type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP, TIMEOUT); -- States for the FSM machine
    signal current_state : FSM_States;

    signal counter : std_logic_vector(4 downto 0) := "00000";
    signal internal_car_count : std_logic_vector(6 downto 0) := (others => '0'); -- Counter for the cars

begin

    -- Update the current state based on the inputs
    compute_current_state : process(clk, reset_n)
    begin
        if reset_n = '0' then -- Reset condition
            current_state <= IDLE;
            internal_car_count <=  (others => '0');

        elsif rising_edge(clk) then
            current_state <= IDLE; -- Set default state

            case current_state is
                when IDLE => 
                    if front_sensor = '1' then
                        current_state <= WAIT_PASSWORD;
                    end if;
                
                when WAIT_PASSWORD => 
                    if front_sensor = '1' then
                        if counter < "01001" then -- Counter < 9
                            current_state <= WAIT_PASSWORD;

                        elsif pswd_in = '0' then -- The password has been inputted
                            current_state <= TIMEOUT;
                        
                        elsif (password_1 & password_2) = "0110" then -- Right password
                            current_state <= RIGHT_PASS;

                        else
                            current_state <= WRONG_PASS;
                        end if;
                    end if;

                when WRONG_PASS => 
                    if counter < "01100" then -- Counter < 12, used to display a bit longer the state
                        current_state <= WRONG_PASS;
                    end if;

                when RIGHT_PASS => 
                    if front_sensor = '1' and back_sensor = '1' then
                        current_state <= STOP;
                        internal_car_count <= std_logic_vector(unsigned(internal_car_count) + 1); -- Increase car counter by 1

                    elsif back_sensor = '0' then -- Wait when the car is passed
                        current_state <= RIGHT_PASS;
                        
                    else
                        internal_car_count <= std_logic_vector(unsigned(internal_car_count) + 1); -- Increase car counter by 1
                    end if;
                
                when STOP => 
                    if front_sensor = '1' and back_sensor = '1' then
                        current_state <= STOP;
                    end if;

                when TIMEOUT => 
                    if counter < "10100" then -- Counter < 20
                        current_state <= TIMEOUT;
                    end if;
            end case;

        end if;
    end process compute_current_state;   


    -- Update the output values at the following clock 
    output_values : process(clk, reset_n)
    begin
        if reset_n = '0' then -- Reset status
            GREEN_LED <= '0';
            RED_LED <= '0';
            HEX_1 <= (others => '1');
            HEX_2 <= (others => '1');
            car_count <= (others => '0');
            counter <= "00000";
            
        elsif rising_edge(clk) then
            -- Default values
            GREEN_LED <= '0';
            RED_LED <= '0';
            HEX_1 <= (others => '1');
            HEX_2 <= (others => '1');
            counter <= "00000";
            car_count <= internal_car_count;

            case current_state is
                when WAIT_PASSWORD => 
                    counter <= std_logic_vector(unsigned(counter) + 1); -- Increase counter by 1
                    RED_LED <= '1';
                    HEX_1 <= "0000110"; -- E
                    HEX_2 <= "0101011"; -- n

                when WRONG_PASS => 
                    counter <= std_logic_vector(unsigned(counter) + 1); -- Increase counter by 1
                    RED_LED <= clk;
                    HEX_1 <= "0000110"; -- E
                    HEX_2 <= "0000110"; -- E

                when RIGHT_PASS => 
                    GREEN_LED <= clk;
                    HEX_1 <= "0000010"; -- G
                    HEX_2 <= "1000000"; -- O
                
                when STOP => 
                    RED_LED <= clk;
                    HEX_1 <= "0100100"; -- S
                    HEX_2 <= "0001100"; -- P
                    
                when TIMEOUT =>
                    counter <= std_logic_vector(unsigned(counter) + 1); -- Increase counter by 1
                    HEX_1 <= "1110000"; -- t
                    HEX_2 <= "1100010"; -- o

                when others => 
                    null;
            end case;
        
        elsif falling_edge(clk) then
            -- Continues the LED blinking outside the rising edges of the clock
            case current_state is
                when WRONG_PASS => 
                    RED_LED <= clk;

                when RIGHT_PASS => 
                    GREEN_LED <= clk;

                when STOP => 
                    RED_LED <= clk;

                when others => 
                    null;
            end case;

        end if;
    end process output_values;

end architecture behaviour;