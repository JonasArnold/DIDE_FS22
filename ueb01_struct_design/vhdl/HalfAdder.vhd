library ieee;
use ieee.std_logic_1164.all;

entity HalfAdder is
  port(
    A : in  std_logic;   -- Input A
    B : in  std_logic;   -- Input B
    S : out std_logic;   -- Sum
    C : out std_logic    -- Carry
    );
end HalfAdder;

architecture struct of HalfAdder is

begin
  and1: entity work.MyAnd
  port map(
     x_pi => A,
     y_pi => B,
     z_po => C);
  
  xor1: entity work.MyXor
  port map(
     x_pi => A,
     y_pi => B,
     z_po => S);

end struct;
