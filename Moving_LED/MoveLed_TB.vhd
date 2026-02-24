----------------------------------------------------------------------------------
--
-- Name: MoveLed_TB 
-- Designer: McCleland Idaewor 
-- 
-- Tech bench file for MoveLed component. It tests all possibile signal
-- combinations to the amount of times the left, right, and reset 
-- button is pressed.
--
----------------------------------------------------------------------------------
---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MoveLed_TB is

end MoveLed_TB;

architecture MoveLed_TB_ARCH of MoveLed_TB is


    
    --unit-under-test---------------------------COMPONENT
    component MoveLed
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            moveLeft  : in std_logic;
            moveRight : in std_logic;
            led_pos   : out std_logic_vector(3 downto 0);
            leds      : out std_logic_vector(15 downto 0));
    end component;        

    --uut-signals-------------------------------SIGNALS
    signal clk     : std_logic;
    signal btnC    : std_logic; 
    signal btnR    : std_logic;
    signal btnL    : std_logic;
    signal led_pos : std_logic_vector(3 downto 0);
    signal leds    : std_logic_vector(15 downto 0);
    
    constant CLOCK_PERIOD: time := 10ns;
    
begin
    --unit-under-test-------------------------------UUT
    UUT: MoveLed port map(
            clk       => clk,
            reset     => btnC,
            moveLeft  => btnL,
            moveRight => btnR,
            leds      => leds,
            led_pos   => led_pos);
        
        
   --CLK----------------------------------------PROCESS    
    clkProcess: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;    
            
   --led_driver---------------------------------PROCESS         
   LED_DRIVER: process 
   begin        
             
       --moves the led to the left------------------ 
       for i in 0 to 15 loop 
          btnR <= '1'; 
          wait for CLOCK_PERIOD;
          btnR <= '0';
          wait for CLOCK_PERIOD;
       end loop; 

       --when both buttons are pressed------------
       btnL <= '1';
       btnR <= '1';
       wait for CLOCK_PERIOD;
       btnL <= '0';
       btnR <= '0';
       wait for CLOCK_PERIOD;

      --moves the led to the right------------------
      for i in 0 to 15 loop 
         btnL <= '1';
         wait for CLOCK_PERIOD;
         btnL <= '0';
         wait for CLOCK_PERIOD;
      end loop;      
      
      --when both buttons are pressed------------
      btnL <= '1';
      btnR <= '1';
      wait for CLOCK_PERIOD;
      btnL <= '0';
      btnR <= '0';
      wait for CLOCK_PERIOD;
     
      --reset button---------------------------------
      btnC <= '1'; 
      wait for CLOCK_PERIOD;
      btnC <= '0';
      wait for CLOCK_PERIOD;       
   end process;               
end MoveLed_TB_ARCH;
