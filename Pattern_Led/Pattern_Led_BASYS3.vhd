----------------------------------------------------------------------------------
-- Name:  Pattern_Led_BASYS3 
-- Designer: McCleland Idaewor
-- 
--
-- Description: wrapper file for the Pattern_Led component. This wrapper is targeting 
--  the Basys3 board from Digilent. The configuration file for the Basys3 was 
--  retrieved from the digilent GitHub account.
--
--  The lower 3 slide switches determines the amount of LEDS that will be lit up.
--  the btnR and btnL on the board will determine if the right leds or left leds 
--  will light up. The Seven-segment display the total number of LEDS that will
--  be lit up. 
--
--               
-- 
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pattern_Led_BASYS3 is
    Port ( sw   : in STD_LOGIC_VECTOR (2 downto 0);
           btnL : in STD_LOGIC;
           btnR : in STD_LOGIC;
           led  : out STD_LOGIC_VECTOR (15 downto 0);
           seg  : out STD_LOGIC_VECTOR (6 downto 0);
           an   : out STD_LOGIC_VECTOR (3 downto 0));
end Pattern_Led_BASYS3;

architecture Pattern_Led_BASYS3_ARCH of Pattern_Led_BASYS3 is
    signal num  : integer range 0 to 7;
    
    component Pattern_Led
            port (  numSw    : in std_logic_vector(2 downto 0);
                    leftEn   : in std_logic;
                    rightEn  : in std_logic;
                    leds     : out std_logic_vector(15 downto 0));   
    end component;                  
begin
    UUT: Pattern_Led port map(
                numSw   => sw,
                leftEn  => btnL,
                rightEn => btnR,
                leds    => led);
               
     num  <=   to_integer(unsigned(sw));          
     process(num)
     begin
        an <= "1110"; --enables the seven-segment   
         case num is
             when 0 => seg <= "1000000"; -- 0           
             when 1 => seg <= "1111001"; -- 1  
             when 2 => seg <= "0100100"; -- 2
             when 3 => seg <= "0110000"; -- 3
             when 4 => seg <= "0011001"; -- 4
             when 5 => seg <= "0010010"; -- 5
             when 6 => seg <= "0000010"; -- 6
             when 7 => seg <= "1111000"; -- 7
             when others => seg <= "1111111"; -- blank
         end case;
     end process;        
end Pattern_Led_BASYS3_ARCH;
