-------------------------------------------------------------------------------
-- Company    :  HSLU, Waj
-- Project    :  ECS/DIDE, Uebung 2
-- Description:  Combinational circuit (Enable gate) described in different ways
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity EnableGate is
  port(
    x  : in  std_logic_vector(3 downto 0);
    en : in  std_logic;
    y  : out std_logic_vector(3 downto 0)
    );
end EnableGate;

-- concurrent signal assignment (naive)
architecture A_conc_sig_ass_1 of EnableGate is
begin
  y(0) <= x(0) and en;
  y(1) <= x(1) and en;
  y(2) <= x(2) and en;
  y(3) <= x(3) and en;
end architecture;

-- process statement with sequential signal ass. (naive)
architecture A_proc_seq_sig_ass_1 of EnableGate is
begin
  process(x, en)
  begin
    y(0) <= x(0) and en;
    y(1) <= x(1) and en;
    y(2) <= x(2) and en;
    y(3) <= x(3) and en;
  end process;
end architecture;

