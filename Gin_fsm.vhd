library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Gin_fsm is
    port(
    clk         : in  std_logic;
    nrst         : in  std_logic;
    sensor_A_Gin   : in std_logic;
    sensor_B_Gin   : in std_logic;
    enable      : in std_logic;
    car_detected: out std_logic;
    car_entered : out std_logic;
    barrier     : out std_logic
    );
end entity Gin_fsm;

architecture behavioural of Gin_fsm is

    type State is (IDLE,CAR_DETECTED_STATE,GATE_OPEN,CAR_ENTERING, CAR_ENTERED_STATE);
    signal current_state : State; 

begin
    compute_current_state : process(clk, nrst) is
    begin
        if nrst = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            car_entered <= '0';
            case current_state is 
                when IDLE =>
                    if sensor_A_Gin = '1' then
                        current_state <= CAR_DETECTED_STATE;
                    end if;
                
                when CAR_DETECTED_STATE =>
                    if enable = '1' then
                        current_state <= GATE_OPEN;
                    elsif sensor_A_Gin = '0' then
                        current_state <= IDLE;
                    end if;
               
                when GATE_OPEN =>
                    if sensor_A_Gin = '0' then
                        current_state <= IDLE;
                    elsif sensor_B_Gin = '1' then
                        current_state <= CAR_ENTERING;
                    end if;
                
                when CAR_ENTERING =>
                    if sensor_A_Gin = '0' then
                        current_state <= CAR_ENTERED_STATE;
                    elsif sensor_B_Gin = '0' then
                        current_state <= GATE_OPEN;
                    end if;

                when CAR_ENTERED_STATE =>
                    if sensor_A_Gin = '1' then
                        current_state <= CAR_ENTERING;
                    end if ; 
                    if sensor_B_Gin = '0' then
                        car_entered <= '1';
                        current_state <= IDLE;
                    end if;
                
                when others => 
                    current_state <= IDLE; -- default IDLE, AND car_entered '0'                  
            end case;
        end if;
    end process compute_current_state;

    compute_output_logic : process(current_state) is
    begin
        -- defaulte : IDLE state
        car_detected <= '0'; 
        barrier      <= '0';
        case current_state is
            when CAR_DETECTED_STATE =>
                car_detected <= '1';
            when GATE_OPEN =>
                barrier <= '1';
            when CAR_ENTERING =>
                barrier <= '1';
            when CAR_ENTERED_STATE =>
                barrier <= '1';
            when others =>
                null; -- default IDLE state
        end case;
    end process compute_output_logic;
end architecture behavioural;