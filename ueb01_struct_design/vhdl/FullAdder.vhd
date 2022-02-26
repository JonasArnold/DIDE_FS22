library ieee;
use ieee.std_logic_1164.all;

entity FullAdder is
    port(
    a_pi           : in  std_logic;    -- Input A
    b_pi           : in  std_logic;    -- Input B
    c_pi           : in std_logic;     -- Input Carry
    s_po           : out std_logic;    -- Sum
    c_po           : out std_logic     -- Carry
    );
end FullAdder;

architecture struct of FullAdder is
   
    signal HA1S : std_logic;    -- Half Adder 1 Sum
    signal HA1C : std_logic;    -- Half Adder 1 Carry
    signal HA2C : std_logic;    -- Half Adder 2 Carry
    
begin
    halfAdder1: entity work.HalfAdder
    port map(
        A => a_pi,
        B => b_pi,
        S => HA1S,
        C => HA1C);
        
    halfAdder2: entity work.HalfAdder
    port map(
        A => HA1S,
        B => c_pi,
        S => s_po,
        C => HA2C);
        
    or1: entity work.MyOr
    port map(
        x_pi => HA1C,
        y_pi => HA2C,
        z_po => c_po); 
                    
end struct;
