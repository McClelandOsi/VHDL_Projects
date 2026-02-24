------------------------------------------------------
-- Name: Encoder_TB 
-- Designers: Cynthia Babecka and McCleland Idaewor
--
--
-- This is the testbench file for the rotary encoder
-- component. It tests all the possibile signal 
-- combinations based on the position of the rotary 
-- encoder, the encoder button, and the reset button
-- 
------------------------------------------------------
---
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity encoder_TB is
--  Port ( );
end encoder_TB;

architecture encoder_TB_ARCH of encoder_TB is

component encoder is
      Port (
            A:in std_logic;
            B: in std_logic;
            led: out std_logic_vector(15 downto 0);
            rotaryButton: in std_logic;
            clock: in std_logic;
            reset: in std_logic);
end component;

signal A: std_logic :='0' ;
signal B: std_logic :='0' ;
signal led: std_logic_vector (15 downto 0);
signal clock: std_logic :='0';
signal reset: std_logic :='0';
signal rotaryButton: std_logic := '0';

begin
        UUT: encoder 
            port map(
                     A => A, B =>B, led => led,rotaryButton => rotaryButton,
                     clock => clock, reset => reset);
                     
        clockDriver: process
        begin
               while true loop
                   clock <= '1';
                   wait for 5 ns;
                   clock <= '0';
                   wait for 5 ns;
               end loop;
        end process;
        

        encoder_Driver: process --(clock, reset) 
        begin
               reset <= '1'; wait until rising_edge(clock);
               reset <= '0'; wait until rising_edge(clock);
               for i in 0 to 10 loop
                     A <= '0'; B <= '0'; wait for 10 ns;
                     A <= '1'; B <= '0'; wait for 10 ns;
                     A <= '1'; B <= '1'; wait for 10 ns;
                     A <= '0'; B <= '1'; wait for 10 ns;
               end loop;
               wait until rising_edge(clock);
               rotaryButton <= '1';
               for i in 0 to 5 loop
                    A <= '0'; B <= '0'; wait for 10 ns;
                    A <= '0'; B <= '1'; wait for 10 ns;
                    A <= '1'; B <= '1'; wait for 10 ns;
                    A <= '1'; B <= '0'; wait for 10 ns;
               end loop;
               wait until rising_edge(clock);
               rotaryButton <= '0';
               wait until rising_edge(clock);
               for i in 0 to 15 loop
                     A <= '0'; B <= '0'; wait for 10 ns;
                     A <= '1'; B <= '0'; wait for 10 ns;
                     A <= '1'; B <= '1'; wait for 10 ns;
                     A <= '0'; B <= '1'; wait for 10 ns;
               end loop;
               --rotaryButton <= '0';
               wait;
        end process;            

end encoder_TB_ARCH;