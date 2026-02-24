----------------------------------------------------------------------------------
-- Name: Pattern_Led_TB
-- Design: McCleland Idaewor 
-- 
--      Test bench file for Pattern_Led componoent. It tests all possible signal 
--      combinations to the various combination of switches and the what button
--      is selected. 
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pattern_Led_TB is

end Pattern_Led_TB;

architecture Pattern_Led_TB_ARCH of Pattern_Led_TB is

constant CLOCK_PERIOD: time := 10ns;

--------unit-under-test------------------------------COMPONENT-DEC
    component Pattern_Led
         port (
             numSw   : in  std_logic_vector(2 downto 0);
             rightEn : in  std_logic;   
             leftEn  : in  std_logic;
             leds    : out std_logic_vector(15 downto 0));
    end component;    
    
--uut-signals----------------------------------------SIGNALS    
    signal switches: std_logic_vector(2 downto 0);
    signal btnR    : std_logic;
    signal btnL    : std_logic;
    signal leds    : std_logic_vector(15 downto 0);        
begin
     ----Uint-Under-Test------------------COMPONENT-INSTANCE
     UUT: Pattern_Led port map(
               numSw => switches,
               rightEn     => btnR,
               leftEn     => btnL,
               leds     => leds);

     ----output_driver-------------------------------PROCESS
     OUT_DRIVER: process
     begin
         for i in 0 to 7 loop --runs the left side
             switches <= std_logic_vector(to_unsigned(i,3));
             wait for CLOCK_PERIOD;
             btnL <= '1';
             wait for CLOCK_PERIOD;
             btnR <= '0';
             wait for CLOCK_PERIOD;
         end loop; 
         
         for i in 0 to 7 loop --runs the right side
             switches <= std_logic_vector(to_unsigned(i,3));
             wait for CLOCK_PERIOD;
             btnL <= '0';
             wait for CLOCK_PERIOD;
             btnR <= '1';
             wait for CLOCK_PERIOD;
         end loop; 
     end process;    
end architecture Pattern_Led_TB_ARCH;
