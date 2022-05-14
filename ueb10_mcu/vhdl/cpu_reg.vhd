-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : mcu_pkg
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- Register block for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 8 x 16
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu_reg is
  port(rst      : in std_logic;
       clk      : in std_logic;
       -- CPU internal interfaces
       reg_in   : in  t_ctr2reg;
       reg_out  : out t_reg2ctr;
       alu_res  : in std_logic_vector(DW-1 downto 0);
       alu_op1  : out std_logic_vector(DW-1 downto 0);
       alu_op2  : out std_logic_vector(DW-1 downto 0)
       );
end cpu_reg;

architecture rtl of cpu_reg is
  
  signal reg_blk : t_regblk;
  
begin

  -----------------------------------------------------------------------------
  -- Mux and register data/address to Control Unit depending on source info.
  -----------------------------------------------------------------------------
  P_mux: process(clk)
  begin
    if rising_edge(clk) then
      reg_out.data <= reg_blk(to_integer(unsigned(reg_in.dest)));
      reg_out.addr <= reg_blk(to_integer(unsigned(reg_in.src1)))(AW-1 downto 0);
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Mux input data to ALU combinationally depending on source info from
  -- control unit.
  -----------------------------------------------------------------------------
  alu_op1 <= reg_blk(to_integer(unsigned(reg_in.src1)));
  alu_op2 <= reg_blk(to_integer(unsigned(reg_in.src2)));
  
  -----------------------------------------------------------------------------
  -- CPU register block
  -- Store ALU result or ld-data depending on destination info from control unit.
  -----------------------------------------------------------------------------
  P_reg: process(rst, clk)
  begin
    if rst = '1' then
      reg_blk    <= (others => (others => '0'));
      reg_blk(0) <= std_logic_vector(to_unsigned(16#0222#,16)); -- preliminary reset value
      reg_blk(1) <= std_logic_vector(to_unsigned(16#02FF#,16)); -- preliminary reset value
      reg_blk(2) <= std_logic_vector(to_unsigned(16#AFFE#,16)); -- preliminary reset value
    elsif rising_edge(clk) then
      if reg_in.enb_res = '1' then
        -- store result from ALU
        reg_blk(to_integer(unsigned(reg_in.dest))) <= alu_res;
      elsif reg_in.enb_data = '1' then
        -- store data from Ctrl (ld instruction)
        reg_blk(to_integer(unsigned(reg_in.dest))) <= reg_in.data;
      end if;
    end if;
  end process;
  
end rtl;
