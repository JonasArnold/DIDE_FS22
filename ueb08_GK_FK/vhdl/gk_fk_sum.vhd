-------------------------------------------------------------------------------
-- Entity: gk_fk_sum
-- Author: Waj
-------------------------------------------------------------------------------
-- Description: (DIDE Uebung 8) "Gleitkomma-Summe"
-- First, the two GK binary16 inputs are converted to FK inputs, such that all
-- normalized FK-numbers can be represented with full precision.
-- Second, the two inputs are added in FK-format with full-precision and range.
-- Third, the FK sum is rounded and saturated to the output format given by the
-- generic parameters W and F.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.gk_pkg.all;

entity gk_fk_sum is
  generic(
    W : natural := 20;  -- Output FK-Format W
    F : natural :=  8   -- Output FK-Format F
    );
  port(
    clk_pi : in  std_logic;
    a_pi   : in  t_gk_b16;                  
    b_pi   : in  t_gk_b16;  
    sum_po : out signed(W-1 downto 0) 
    );
end gk_fk_sum;

architecture rtl of gk_fk_sum is

  -- pos/neg max values of output format for saturation
  constant c_pos_max : signed(W-1 downto 0) := (W-1 => '0', others => '1');
  constant c_neg_max : signed(W-1 downto 0) := (W-1 => '1', others => '0');
  
begin
  
  -----------------------------------------------------------------------------
  -- sequential process: Convert GK to FK with full precision/range (stage 1)
  -----------------------------------------------------------------------------
  P_1: process(clk_pi)
  begin
    if rising_edge(clk_pi) then
      
    -- ToDo ............. 
      
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Add FK numbers with full precision/range (stage 2)
  -----------------------------------------------------------------------------
  P_2: process(clk_pi)
  begin
    if rising_edge(clk_pi) then
    
    -- ToDo ............. 
      
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- sequential process: Round and saturate FK to output format (stage 3)
  -----------------------------------------------------------------------------
  P_3: process(clk_pi)
  begin
    if rising_edge(clk_pi) then
      -- round-off 24-F LSBs of FK sum
      
      -- ToDo ............. 
      
      -- saturate rounded fk sum to output range
      
      -- ToDo ............. 
      
    end if;
  end process;

end rtl;
