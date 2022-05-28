-------------------------------------------------------------------------------
-- Project: Hand-Made MCU
-- Entity : cpu_alu
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- ALU for the RISC-CPU of the von-Neuman MCU.
-------------------------------------------------------------------------------
-- Total # of FFs: XX
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
  
  -- internal signals after stage 1 pipeline registers
  signal alu_op1_s1  : std_logic_vector(DW-1 downto 0);
  signal alu_op2_s1  : std_logic_vector(DW-1 downto 0);
  signal alu_opr_s1  : std_logic_vector(OPAW-1 downto 0);
  signal alu_res_s1  : std_logic_vector(DW-1 downto 0);
  signal set_imm_s1  : std_logic_vector(DW/2-1 downto 0);
  signal add_imml_s1 : std_logic_vector(DW-1 downto 0);
  signal add_immh_s1 : std_logic_vector(DW-1 downto 0);
  signal alu_enb_s1  : std_logic;
  -- internal signals after stage 2 pipeline registers
  signal op1_msb_s2  : std_logic;
  signal op2_msb_s2  : std_logic;
  signal op2a_msb_s2 : std_logic;
  signal res_msb_s2  : std_logic;
  signal alu_opr_s2  : std_logic_vector(OPAW-1 downto 0);
  signal alu_res_s2  : std_logic_vector(DW-1 downto 0);
  signal alu_enb_s2  : std_logic;
  -- internal signals after stage 3 pipeline registers
  signal flag_s3     : t_flag_arr;
  -- constants for sign-extension
  constant ext_0     : std_logic_vector(DW/2-1 downto 0) := (others => '0');
  constant ext_1     : std_logic_vector(DW/2-1 downto 0) := (others => '1');

begin
  
  -----------------------------------------------------------------------------
  -- ALU output assignments
  -----------------------------------------------------------------------------
  result       <= alu_res_s2;
  alu_out.flag <= flag_s3;

  -----------------------------------------------------------------------------
  -- Stage 1 registers (ALU inputs)
  -----------------------------------------------------------------------------
  P_s1_reg: process(clk)
  begin
    if rising_edge(clk) then
      -- generate helper signals for addil/addih instructions with sign extension
      if alu_in.imm(alu_in.imm'left) = '0' then
        add_imml_s1 <= (ext_0 & alu_in.imm);
      else
        add_imml_s1 <= (ext_1 & alu_in.imm);
      end if;
      add_immh_s1 <= alu_in.imm & ext_0;
      set_imm_s1  <= alu_in.imm;
      -- assign ALU operands, operator and result signals
      alu_op1_s1 <= oper1;      
      alu_op2_s1 <= oper2;      
      alu_opr_s1 <= alu_in.op;  
      alu_enb_s1 <= alu_in.enb; 
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- ALU operations (using stage 1 signals)
  -----------------------------------------------------------------------------
  with t_alu_instr'val(to_integer(unsigned(alu_opr_s1))) select alu_res_s1 <=
    std_logic_vector(unsigned(alu_op1_s1) + unsigned(alu_op2_s1))  when add,
    std_logic_vector(unsigned(alu_op1_s1) - unsigned(alu_op2_s1))  when sub,
    alu_op1_s1 and alu_op2_s1                                      when andi,
    alu_op1_s1 or  alu_op2_s1                                      when ori,
    alu_op1_s1 xor alu_op2_s1                                      when xori, 
    alu_op1_s1(DW-2 downto 0) & '0'                                when slai,
    alu_op1_s1(DW-1) & alu_op1_s1(DW-1 downto 1)                   when srai,
    alu_op1_s1                                                     when mov,
    std_logic_vector(unsigned(alu_op1_s1) + unsigned(add_imml_s1)) when addil,
    std_logic_vector(unsigned(alu_op1_s1) + unsigned(add_immh_s1)) when addih,
    alu_op1_s1(DW-1 downto DW/2) & set_imm_s1                      when setil,
    set_imm_s1 & alu_op1_s1(DW/2-1 downto 0)                       when setih,
    (others => '0')                                                when others;  -- (ensures memory-less process)

  -----------------------------------------------------------------------------
  -- Stage 2 registers (ALU result and inputs required for flag setting)
  -----------------------------------------------------------------------------
  P_s2_reg: process(clk)
  begin
    if rising_edge(clk) then
      -- ALU result
      alu_res_s2 <= alu_res_s1;
      -- MSBs relevant for flag setting 
      op1_msb_s2 <= alu_op1_s1(DW-1);
      op2_msb_s2 <= alu_op2_s1(DW-1);
      res_msb_s2 <= alu_res_s1(DW-1);
      if to_integer(unsigned(alu_opr_s1)) = 0 then
        -- add: use normal operand 2
        op2a_msb_s2 <= alu_op2_s1(DW-1);
      elsif to_integer(unsigned(alu_opr_s1)) = 12 then
        -- addil: use low-part of immediate operand
        op2a_msb_s2 <= add_imml_s1(DW-1);
      else
        -- addih: use high-part of immediate operand
        op2a_msb_s2 <= add_immh_s1(DW-1);
      end if;
      -- ALU enable and operation 
      alu_enb_s2 <= alu_enb_s1;
      alu_opr_s2 <= alu_opr_s1;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Stage 3 registers (Update flags N, Z, C, O)
  -----------------------------------------------------------------------------
  P_s3_reg: process(clk)
  begin
    if rising_edge(clk) then
      -- flags only update with ALU enable ------------------------------------
      if alu_enb_s2 = '1' then
        -- N, updated with each ALU operation ---------------------------------
        flag_s3(N) <= res_msb_s2;
        -- Z, updated with each ALU operation ---------------------------------
        flag_s3(Z) <= '0';
        if to_integer(unsigned(alu_res_s2)) = 0 then
          flag_s3(Z) <= '1';
        end if;
        -- C,O updated with add/addil/addih/sub only --------------------------
        case t_alu_instr'val(to_integer(unsigned(alu_opr_s2))) is
          when add | addil | addih => -- use op2a_msb
            flag_s3(C) <= (     op1_msb_s2 and     op2a_msb_s2) or
                          (     op1_msb_s2 and not  res_msb_s2) or
                          (    op2a_msb_s2 and not  res_msb_s2);
            flag_s3(O) <= (not  op1_msb_s2 and not op2a_msb_s2 and     res_msb_s2) or
                          (     op1_msb_s2 and     op2a_msb_s2 and not res_msb_s2);
          when sub =>                 -- use op2_msb
            flag_s3(C) <= (     op2_msb_s2 and not  op1_msb_s2) or
                          (     res_msb_s2 and not  op1_msb_s2) or
                          (     op2_msb_s2 and      res_msb_s2);
            flag_s3(O) <= (     op1_msb_s2 and not  op2_msb_s2 and not res_msb_s2) or
                          (not  op1_msb_s2 and      op2_msb_s2 and     res_msb_s2);
          when others =>  null;
        end case;
      end if;
    end if;
  end process;

end rtl;
