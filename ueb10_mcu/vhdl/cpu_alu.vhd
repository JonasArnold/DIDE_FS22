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
  
  signal imml         : std_logic_vector(DW-1 downto 0);
  signal immh         : std_logic_vector(DW-1 downto 0);
  signal result_int   : std_logic_vector(DW-1 downto 0);
  signal result_reg   : std_logic_vector(DW-1 downto 0);
  signal oper1_reg    : std_logic_vector(DW-1 downto 0);
  signal oper2_reg    : std_logic_vector(DW-1 downto 0);
  signal imm_reg      : std_logic_vector(DW/2-1 downto 0);
  signal alu_op_reg   : std_logic_vector(OPAW-1 downto 0);
  signal op2add       : std_logic_vector(DW-1 downto 0);
  signal alu_enb_reg1 : std_logic;
  signal alu_enb_reg2 : std_logic;

  constant ext_0      : std_logic_vector(IOWW-1 downto 0) := (others => '0');
  constant ext_1      : std_logic_vector(IOWW-1 downto 0) := (others => '1');

begin

  -- output assignments
  result <= result_reg;
  
  -----------------------------------------------------------------------------
  -- register ALU operands and result
  -----------------------------------------------------------------------------
  P_alu_op: process(clk)
  begin
    if rising_edge(clk) then
      -- register ALU inputs once
      oper1_reg    <= oper1;
      oper2_reg    <= oper2;
      imm_reg      <= alu_in.imm;
      alu_op_reg   <= alu_in.op;
      -- regsiter enable for flag computation twice
      alu_enb_reg1 <= alu_in.enb;
      alu_enb_reg2 <= alu_enb_reg1;
      -- register results
      result_reg   <= result_int;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Use the type-attribute 'val to determine the value of an enumeration type
  -- signal based on the position of this value in the defintion of the type.
  -- (Note: The complementary attribute to 'val is 'pos)
  -----------------------------------------------------------------------------
  -- ALU operations
  -----------------------------------------------------------------------------
  -- helper signals for addil/addih instructions with sign extension
  imml <= (ext_0 & imm_reg) when  imm_reg(imm_reg'left) = '0' else
          (ext_1 & imm_reg  );         
  immh <= imm_reg & ext_0;
  -- Operand 2 for add/addil/addih
  with to_integer(unsigned(alu_op_reg)) select op2add <=
    oper2_reg when  0,     -- add
    imml      when 12,     -- addil
    immh      when others; -- addih
  -- ALU result
  with to_integer(unsigned(alu_op_reg)) select result_int <=
    -- Opcode 0: add
    std_logic_vector(unsigned(oper1_reg) + unsigned(oper2_reg)) when 0,
    -- Opcode 1: sub
    std_logic_vector(unsigned(oper1_reg) - unsigned(oper2_reg)) when 1,
    -- Opcode 2: and
    oper1_reg and oper2_reg                                     when 2,
    -- Opcode 3: or
    oper1_reg or oper2_reg                                      when 3,
    -- Opcode 4: xor
    oper1_reg xor oper2_reg                                     when 4,
    -- Opcode 5: slai
    oper1_reg(DW-2 downto 0) & '0'                              when 5,
    -- Opcode 6: srai
    oper1_reg(DW-1) & oper1_reg(DW-1 downto 1)                  when 6,
    -- Opcode 7: mov
    oper1_reg                                                   when 7,
    -- Opcode 12: addil
    std_logic_vector(unsigned(oper1_reg) + unsigned(imml))      when 12,
    -- Opcode 13: addih
    std_logic_vector(unsigned(oper1_reg) + unsigned(immh))      when 13,
    -- Opcode 14: setil
    oper1_reg(DW-1 downto DW/2) & imm_reg                       when 14,
    -- Opcode 15: setih
    imm_reg & oper1_reg(DW/2-1 downto 0)                        when 15,
    -- other (ensures memory-less process)
    (others => '0')                                     when others;

  -- Vivado Simulation problems with this code!!
  --with t_alu_instr'val(to_integer(unsigned(alu_in.op))) select result_int <=
  --  std_logic_vector(unsigned(oper1) + unsigned(oper2))   when add,
  --  std_logic_vector(unsigned(oper1) - unsigned(oper2))   when sub,
  --  oper1 and oper2                                       when andi,
  --  oper1 or oper2                                        when ori,
  --  oper1 xor oper2                                       when xori,
  --  oper1(DW-2 downto 0) & '0'                            when slai,
  --  oper1(DW-1) & oper1(DW-1 downto 1)                    when srai,
  --  oper1                                                 when mov,
  --  std_logic_vector(unsigned(oper1) + unsigned(imml))    when addil,
  --  std_logic_vector(unsigned(oper1) + unsigned(immh))    when addih,
  --  oper1(DW-1 downto DW/2) & alu_in.imm                  when setil,
  --  alu_in.imm & oper1(DW/2-1 downto 0)                   when setih,
  --  (others =>'0')                                        when others;

  -----------------------------------------------------------------------------
  -- Update flags N, Z, C, O from ALU results
  -----------------------------------------------------------------------------
  P_flag: process(clk)
  begin
    if rising_edge(clk) then
      -- flag update with ALU enable ------------------------------------------
      if alu_enb_reg2 = '1' then
        -- N, updated with each ALU operation ---------------------------------
        alu_out.flag(N) <= result_reg(DW-1);
        -- Z, updated with each ALU operation ---------------------------------
        alu_out.flag(Z) <= '0';
        if to_integer(unsigned(result_reg)) = 0 then
          alu_out.flag(Z) <= '1';
        end if;
        -- C, updated with add/addil/addih/sub only ---------------------------
        if (to_integer(unsigned(alu_op_reg)) =  0) or
           (to_integer(unsigned(alu_op_reg)) = 12) or   
           (to_integer(unsigned(alu_op_reg)) = 13) then 
          -- add/addil/addih (use op2add)
          alu_out.flag(C) <= (oper1_reg(DW-1)  and     op2add(DW-1))     or
                             (oper1_reg(DW-1)  and not result_reg(DW-1)) or
                             (op2add(DW-1)     and not result_reg(DW-1));
        elsif to_integer(unsigned(alu_op_reg)) = 1 then
          -- sub (use oper2)
          alu_out.flag(C) <= (oper2_reg(DW-1)  and not oper1_reg(DW-1))   or
                             (result_reg(DW-1) and not oper1_reg(DW-1))   or
                             (oper2_reg(DW-1)  and     result_reg(DW-1));
        end if;
        -- O, updated with add/addil/addih/sub only ---------------------------
        if (to_integer(unsigned(alu_op_reg)) =  0) or
           (to_integer(unsigned(alu_op_reg)) = 12) or   
           (to_integer(unsigned(alu_op_reg)) = 13) then 
          -- add/addil/addih (use op2add)
          alu_out.flag(O) <= (not oper1_reg(DW-1) and not op2add(DW-1) and     result_reg(DW-1)) or
                             (    oper1_reg(DW-1) and     op2add(DW-1) and not result_reg(DW-1));
        elsif to_integer(unsigned(alu_op_reg)) = 1 then
          -- sub (use oper2)
          alu_out.flag(O) <= (    oper1_reg(DW-1) and not oper2_reg(DW-1) and not result_reg(DW-1)) or
                             (not oper1_reg(DW-1) and     oper2_reg(DW-1) and     result_reg(DW-1));
        end if;     
      end if;
    end if;
  end process;

end rtl;
