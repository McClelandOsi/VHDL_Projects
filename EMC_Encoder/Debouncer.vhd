-==============================================================
--Rotary encoder debouncer
--Cynthia Babecka and McCleland Idaewor
--
-- This is the debouncer used for the rotary encoder
-- 
--==============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debouncer is
    generic (
        DEBOUNCE_COUNT : natural := 100_000  -- default: 1 ms at 100 MHz
    );
    port (
        clk  : in  std_logic;
        --signals from Pmod------
        Ain  : in  std_logic;
        Bin  : in  std_logic;
        --debounced signals-----
        Aout : out std_logic;
        Bout : out std_logic
    );
end Debouncer;

architecture Behavioral of Debouncer is

    signal counterA : unsigned(31 downto 0) := (others => '0');
    signal counterB : unsigned(31 downto 0) := (others => '0');
    signal stableA  : std_logic := '0';
    signal stableB  : std_logic := '0';
    signal prevA    : std_logic := '0';
    signal prevB    : std_logic := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            --Debounce A----------
            if Ain /= prevA then --checks current input 
                counterA <= (others => '0');
                prevA    <= Ain;
		     --checks debounce thresohold---------		
            elsif counterA < to_unsigned(DEBOUNCE_COUNT, counterA'length) then
                counterA <= counterA + 1;
            elsif stableA /= Ain then --assigns stable signal 
                stableA <= Ain;
            end if;

            --Debounce B---------------
            if Bin /= prevB then --checks current input
                counterB <= (others => '0');
                prevB    <= Bin;
			 --checks debounce thresohold------------	
            elsif counterB < to_unsigned(DEBOUNCE_COUNT, counterB'length) then
                counterB <= counterB + 1;
            elsif stableB /= Bin then --assigns stable signal 
                stableB <= Bin;
            end if;
        end if;
    end process;

    --assigns stable signal to output 
    Aout <= stableA;
    Bout <= stableB;
