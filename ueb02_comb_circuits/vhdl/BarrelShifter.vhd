library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BarrelShifter is
  port(
    dataIn  : in  std_logic_vector(7 downto 0);  -- 8-bit input
    shift   : in  std_logic_vector(3 downto 0);  -- 2sC shift value 
    dataOut : out std_logic_vector(7 downto 0)   -- 8-bit output
    );
end BarrelShifter;

architecture rtl of BarrelShifter is
begin

    P_abs: process(dataIn, shift)
        variable v_shift : integer range 0 to + 2**(shift'length-1)-1;  -- range -7 to 

    begin
        v_shift := abs(to_integer(signed(shift)));
        
        -- default assignment (only planned in event queue)
        -- if nothing else is written to dataOut => it will be set to 0000000
        dataOut <= (others => '0');  
        
        -- setting dataOut to the shifted dataIn value
        if signed(shift) < 0 then  -- shift right
           dataOut(7-v_shift downto 0) <= dataIn(7 downto v_shift);
        else  -- shift left
           dataOut(7 downto v_shift) <= dataIn(7-v_shift downto 0);
        end if;
        
    end process P_abs;
    
end rtl;





      




