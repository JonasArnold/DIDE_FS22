-------------------------------------------------------------------------------
-- Company    :  HSLU, Waj
-- Project    :  ECS/DIDE, Uebung 2
-- Description:  Testbench for enable gate with configuration selection
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity tb_EnableGate is
end tb_EnableGate;

architecture TB of tb_EnableGate is

  component EnableGate
    port(
      x  : in  std_logic_vector(3 downto 0);
      en : in  std_logic;
      y  : out std_logic_vector(3 downto 0));
  end component EnableGate;

  -- configure architecture of UUT to be simulated
  for UUT : EnableGate use entity work.EnableGate(A_conc_sig_ass_1);

  signal x  : std_logic_vector(3 downto 0);
  signal en : std_logic;
  signal y  : std_logic_vector(3 downto 0);

begin

  -- Unit Under Test port map
  UUT : EnableGate
    port map (
      x  => x,
      en => en,
      y  => y
      );

  process
  begin
    for e in std_logic'('0') to std_logic'('1') loop
      en <= e;
      for i in 0 to 3 loop
        x <= (others => '0');
        x(i) <= '1';
        wait for 1 us;  -- wait before checking response and applying next stimuli vector
        if e = '1' then
          assert y = x report "ERROR: Simulation failed!!!" severity failure;
        else
          assert y = "0000" report "ERROR: Simulation failed!!!" severity failure;
        end if;
      end loop;
    end loop;
    report "Simulation done. No error detected." severity note; -- failure: stop simulation 
                                                    -- note: continue simulation
    wait; -- suspend process forever
  end process;
  
end TB;

