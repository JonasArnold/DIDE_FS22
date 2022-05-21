-------------------------------------------------------------------------------
-- Project: Hand-Made MCU
-- Entity : cpu_alu
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- ALU for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: 0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mcu_pkg.all;

entity cpu_alu is
  port(rst      : in std_logic;
       clk      : in std_logic;
       -- CPU internal interfaces
       alu_in   : in  t_ctr2alu;
       alu_out  : out t_alu2ctr;
       oper1    : in std_logic_vector(DW-1 downto 0);
       oper2    : in std_logic_vector(DW-1 downto 0);
       result   : out std_logic_vector(DW-1 downto 0)
       );
end cpu_alu;

architecture rtl of cpu_alu is
  
  -- internal signals for ALU
  signal alu_op1  : std_logic_vector(DW-1 downto 0);
  signal alu_op2  : std_logic_vector(DW-1 downto 0);
  signal alu_opr  : std_logic_vector(OPAW-1 downto 0);
  signal alu_res  : std_logic_vector(DW-1 downto 0);
  signal set_imm  : std_logic_vector(DW/2-1 downto 0);
  signal add_imml : std_logic_vector(DW-1 downto 0);
  signal add_immh : std_logic_vector(DW-1 downto 0);
  -- internal signals for flag setting
  signal alu_enb  : std_logic;
  signal op1_msb  : std_logic;
  signal op2_msb  : std_logic;
  signal op2a_msb : std_logic;
  signal res_msb  : std_logic;
  signal flag     : t_flag_arr;
  -- constants for sign-extension
  constant ext_0  : std_logic_vector(DW/2-1 downto 0) := (others => '0');
  constant ext_1  : std_logic_vector(DW/2-1 downto 0) := (others => '1');

begin
  
  -----------------------------------------------------------------------------
  -- ALU output assignments
  -----------------------------------------------------------------------------
  alu_out.flag(N) <= flag(N);
  alu_out.flag(Z) <= flag(Z); 
  alu_out.flag(C) <= flag(C); 
  alu_out.flag(O) <= flag(O);

  -----------------------------------------------------------------------------
  -- assign ALU operands, operator and result signals
  -----------------------------------------------------------------------------
  alu_op1  <= oper1;              -- Operand 1
  alu_op2  <= oper2;              -- Operand 2
  alu_opr  <= alu_in.op;          -- Operation
  set_imm  <= alu_in.imm;         -- Immediate Operand for setil/ih instructions
  result   <= alu_res;            -- Result
  add_immh <= alu_in.imm & ext_0; -- helper signals for addil/addih instructions with sign extension
  add_imml <= (ext_1 & alu_in.imm) when signed(alu_in.imm) < 0 else
              (ext_0 & alu_in.imm);

  -----------------------------------------------------------------------------
  -- ALU operations
  -- Note: The 1st more elegant version is not used due to risk of simulation
  --       mismatch in Vivado 2019.2, see MCU Task 2 (GPIO).
  -----------------------------------------------------------------------------
  -- with t_alu_instr'val(to_integer(unsigned(alu_opr))) select alu_res <=
  --   std_logic_vector(unsigned(alu_op1) + unsigned(alu_op2))  when add,
  --   std_logic_vector(unsigned(alu_op1) - unsigned(alu_op2))  when sub,
  --   alu_op1 and alu_op2                                      when andi,
  --   alu_op1 or  alu_op2                                      when ori,
  --   alu_op1 xor alu_op2                                      when xori, 
  --   alu_op1(DW-2 downto 0) & '0'                             when slai,
  --   alu_op1(DW-1) & alu_op1(DW-1 downto 1)                   when srai,
  --   alu_op1                                                  when mov,
  --   std_logic_vector(unsigned(alu_op1) + unsigned(add_imml)) when addil,
  --   std_logic_vector(unsigned(alu_op1) + unsigned(add_immh)) when addih,
  --   alu_op1(DW-1 downto DW/2) & set_imm                      when setil,
  --   set_imm & alu_op1(DW/2-1 downto 0)                       when setih,
  --   (others => '0')                                          when others;  -- (ensures memory-less process)

  with to_integer(unsigned(alu_opr)) select alu_res <=
    std_logic_vector(unsigned(alu_op1) + unsigned(alu_op2))  when 0,
    std_logic_vector(unsigned(alu_op1) - unsigned(alu_op2))  when 1,
    alu_op1 and alu_op2                                      when 2,
    alu_op1 or  alu_op2                                      when 3,
    alu_op1 xor alu_op2                                      when 4, 
    alu_op1(DW-2 downto 0) & '0'                             when 5,
    alu_op1(DW-1) & alu_op1(DW-1 downto 1)                   when 6,
    alu_op1                                                  when 7,
    std_logic_vector(unsigned(alu_op1) + unsigned(add_imml)) when 12, 
    std_logic_vector(unsigned(alu_op1) + unsigned(add_immh)) when 13, 
    alu_op1(DW-1 downto DW/2) & set_imm                      when 14,
    set_imm & alu_op1(DW/2-1 downto 0)                       when 15,
    (others => '0')                                          when others;  -- (ensures memory-less process)

  -----------------------------------------------------------------------------
  -- assign signals to be used for flag setting
  -----------------------------------------------------------------------------
  alu_enb <= alu_in.enb;         -- ALU enable
  op1_msb <= alu_op1(DW-1);      -- Operand 1 MSB
  op2_msb <= alu_op2(DW-1);      -- Operand 2 MSB
  res_msb <= alu_res(DW-1);      -- Result MSB
  -- Operand 2 MSB for different types of addition instructions
  with t_alu_instr'val(to_integer(unsigned(alu_opr))) select
    op2a_msb <= alu_op2(DW-1)  when add,
                add_imml(DW-1) when addil,
                add_immh(DW-1) when others;  
  
  -----------------------------------------------------------------------------
  -- Update flags N, Z, C, O depending on ALU operations, operands and result
  -----------------------------------------------------------------------------
  P_flag: process(rst, clk)
  begin
    if rst = '1' then
      flag <= (others => '0');
    elsif rising_edge(clk) then
      -- flags only update with ALU enable ------------------------------------
      if alu_enb = '1' then
        -- N, updated with each ALU operation ---------------------------------
        flag(N) <= res_msb;
        -- Z, updated with each ALU operation ---------------------------------
        flag(Z) <= '0';
        if to_integer(unsigned(alu_res)) = 0 then
          flag(Z) <= '1';
        end if;
        -- C,O updated with add/addil/addih/sub only --------------------------
        case t_alu_instr'val(to_integer(unsigned(alu_opr))) is
          when add | addil | addih => -- use op2a_msb
            flag(C) <= (     op1_msb and     op2a_msb) or
                       (     op1_msb and not  res_msb) or
                       (    op2a_msb and not  res_msb);
            flag(O) <= (not  op1_msb and not op2a_msb and     res_msb) or
                       (     op1_msb and     op2a_msb and not res_msb);
          when sub =>                 -- use op2_msb
            flag(C) <= (     op2_msb and not  op1_msb) or
                       (     res_msb and not  op1_msb) or
                       (     op2_msb and      res_msb);
            flag(O) <= (     op1_msb and not  op2_msb and not res_msb) or
                       (not  op1_msb and      op2_msb and     res_msb);
          when others =>
            null;
        end case;
      end if;
    end if;
  end process;

end rtl;
