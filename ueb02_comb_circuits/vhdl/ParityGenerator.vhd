-------------------------------------------------------------------------------
-- Odd-Parity Generator
-- Output parity complements input data such that the total number of '1' in
-- data and parity is an odd number.
--
-- Note: The three different architectures described below all result in the
-- same logic and thus have identical HW complexity (in this case 1 LUT,
-- because 4-input combinational circuit).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ParityGenerator is
  port(
    data   : in  std_logic_vector(3 downto 0);
    parity : out std_logic
    );
end ParityGenerator;

-------------------------------------------------------------------------------
-- implementation with explicit one-counter
-------------------------------------------------------------------------------
architecture one_cnt of ParityGenerator is
begin
  
  P_one_cnt: process(data)
    variable onesCount : integer range data'length downto 0;
  begin
    onesCount := 0; -- initialize variable
    for i in data'length-1 downto 0 loop
      if data(i) = '1' then
        onesCount := onesCount+1;
      end if;
    end loop;
    if onesCount mod 2 = 0 then
      parity <= '1';
    else
      parity <= '0';
    end if;
  end process P_one_cnt;
 
end architecture one_cnt;

-------------------------------------------------------------------------------
-- implementation with incremental parity generation
-------------------------------------------------------------------------------
architecture incr_not of ParityGenerator is
begin
  
  P_incr_not: process(data)
    variable v_oddpar : std_logic;
  begin
    v_oddpar := '1'; -- assume data contains no '1'
    for i in data'length-1 downto 0 loop
      if data(i) = '1' then
        v_oddpar := not v_oddpar;
      end if;
    end loop;
    parity <= v_oddpar;
  end process P_incr_not;
  
end architecture incr_not;

-------------------------------------------------------------------------------
-- implementation with XOR chain
-------------------------------------------------------------------------------
architecture xor_chain of ParityGenerator is
begin
  
  P_xor_chain: process(data)
    variable v_xor : std_logic;
  begin
    v_xor := '1'; -- set first XOR input to '1'
    for i in data'length-1 downto 0 loop
      v_xor := v_xor xor data(i);
    end loop;
    parity <= v_xor;
  end process P_xor_chain;
 
end architecture xor_chain;

