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

-- concurrent signal assignment (a bit more clever)
architecture A_conc_sig_ass_2 of EnableGate is
begin
  y <= x and (en & en & en & en);
end architecture;

-- process statement with seq. sig. ass. (a bit more clever)
architecture A_proc_seq_sig_ass_2 of EnableGate is
begin
  process(x, en)
  begin
    y <= x and (en & en & en & en);
  end process;
end architecture;

-- process statement with "for" loop (clever)
architecture A_proc_for_loop of EnableGate is
begin
  process(x, en)
  begin
    for i in 0 to x'length-1 loop -- loop param i only visible
      y(i) <= x(i) and en;        -- within loop
    end loop;
  end process;
end architecture;

-- conditional signal assignment (clever)
architecture A_cond_sig_ass of EnableGate is
begin
  y <= x when en = '1' else (others => '0');
end architecture;

-- process statem. replacing cond. signal ass. (clever)
architecture A_proc_cond_sig_ass of EnableGate is
begin
  process(x, en)
  begin
    if en = '1' then
      y <= x;
    else
      y <= (others => '0');
    end if;
  end process;
end architecture;

-- process with case statement (clever)
architecture A_proc_with_case of EnableGate is
begin
  process(x, en)
  begin
    case en is
      when '1' =>
        y <= x;
      when others =>
        y <= (others => '0');
    end case;
  end process;
end architecture;

-- selected signal assignment (clever)
architecture A_sel_sig_ass of EnableGate is
begin
  with en select
    y <= x               when '1',
         (others => '0') when others;
end architecture;

-- concurrent signal assignment with generate loop (expert)
architecture A_generate_loop of EnableGate is
begin
  gen: for i in 0 to x'length-1 generate
    y(i) <= x(i) and en;
  end generate;
end architecture;
