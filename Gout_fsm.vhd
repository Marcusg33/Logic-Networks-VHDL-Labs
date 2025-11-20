library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Gout_fsm is
    port(
    clk         : in  std_logic;
    nrst         : in  std_logic;
    sensor_A_Gout   : in std_logic;
    sensor_B_Gout   : in std_logic;
    payment_done : in std_logic;
    payment_request : out std_logic;
    payment_accepted : out std_logic;
    barrier     : out std_logic;
    car_exited : out std_logic
    );
end entity Gout_fsm;

architecture behavioural of Gout_fsm is

    type State is (IDLE,WAIT_PAYMENT,PAYMENT_OK,CAR_EXITING, CAR_EXITED_STATE);
    signal current_state : State; 

begin
    compute_current_state : process(clk, nrst) is
    begin
        if nrst = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            car_exited <= '0';
            case current_state is 
                when IDLE =>
                    if sensor_A_Gout = '1' then
                        current_state <= WAIT_PAYMENT;
                    end if;
                
                when WAIT_PAYMENT =>
                    if payment_done = '1' then
                        current_state <= PAYMENT_OK;
                    elsif sensor_A_Gout = '0' then
                        current_state <= IDLE;
                    end if;
               
                when PAYMENT_OK =>
                    if sensor_A_Gout = '0' then
                        current_state <= IDLE;
                    elsif sensor_B_Gout = '1' then
                        current_state <= CAR_EXITING;
                    end if;
                
                when CAR_EXITING =>
                    if sensor_A_Gout = '0' then
                        current_state <= CAR_EXITED_STATE;
                    elsif sensor_B_Gout = '0' then
                        current_state <= PAYMENT_OK;
                    end if;

                when CAR_EXITED_STATE =>
                    if sensor_A_Gout = '1' then
                        current_state <= CAR_EXITING;
                    end if ; 
                    if sensor_B_Gout = '0' then
                        car_exited <= '1';
                        current_state <= IDLE;
                    end if;
                
                when others => 
                    current_state <= IDLE; -- default IDLE, AND car_exited '0'                  
            end case;
        end if;
    end process compute_current_state;

    compute_output_logic : process(current_state) is
    begin
        -- defaulte : IDLE state
        payment_request <= '0';
        payment_accepted <= '0';
        barrier      <= '0';
        case current_state is
            when WAIT_PAYMENT =>
                payment_request <= '1';
            when PAYMENT_OK =>
                payment_accepted <= '1';
                barrier <= '1';
            when CAR_EXITING =>
                barrier <= '1';
            when CAR_EXITED_STATE =>
                barrier <= '1';
            when others =>
                null; -- default IDLE state
        end case;
    end process compute_output_logic;
end architecture behavioural;