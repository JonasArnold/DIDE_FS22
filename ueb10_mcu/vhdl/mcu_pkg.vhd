-------------------------------------------------------------------------------
-- Project: Hand-made MCU
-- Entity : mcu_pkg
-- Author : Waj
-------------------------------------------------------------------------------
-- Description:
-- VHDL package for definition of design parameters and types used throughout
-- the MCU.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mcu_pkg is

  -----------------------------------------------------------------------------
  -- Helper functions (prototypes)
  -----------------------------------------------------------------------------
  -- std_logic_vector(to_signed(i,w))
  function i2slv(i : integer; w : positive) return std_logic_vector;
  -- std_logic_vector(to_unsigned(n,w))
  function n2slv(n : natural; w : positive) return std_logic_vector;
  -- form instruction word for NOP instruction
  function iw_nop return std_logic_vector;

  -----------------------------------------------------------------------------
  -- system clock frequency in Hz (for simulation only)
  -----------------------------------------------------------------------------
  constant CF : natural :=  125_000_000;  -- 125 MHz (PL ref clock on ZYBO)
  
  -----------------------------------------------------------------------------
  -- design parameters: Memory Map
  -----------------------------------------------------------------------------
  -- bus architecture parameters
  constant DW    : natural range 4 to 64 := 16;     -- data word width
  constant AW    : natural range 2 to 64 := 10;     -- total address width
  constant AWH   : natural range 1 to 64 :=  4;     -- high address width
  constant AWROM : natural range 1 to 64 := AW-1;   -- address width ROM
  constant AWRAM : natural range 1 to 64 := AW-2;   -- address width RAM
  constant AWPER : natural range 1 to 64 := AW-AWH; -- address width peripherals
  -- memory map
  type t_bus_slave is (ROM, RAM, GPIO, FMC, TIM, UART); -- list of bus slaves
  type t_ba is array (t_bus_slave) of std_logic_vector(AW-1 downto 0);
  constant BA : t_ba := (             -- full base addresses !!!!!!!!!!!!!!!!!!!!! ToDo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
         ROM  => "0-" & "----" & "----",
         RAM  => "10" & "----" & "----",
         GPIO => "11" & "00--" & "----",
         FMC  => "11" & "01--" & "----",
         TIM  => "11" & "10--" & "----",
         UART => "11" & "11--" & "----"
         );
  type t_hba is array (t_bus_slave) of std_logic_vector(AWH-1 downto 0);
  constant HBA : t_hba := (            -- high base address for decoding
         ROM  => BA(ROM) (AW-1 downto AW-AWH),
         RAM  => BA(RAM) (AW-1 downto AW-AWH),
         GPIO => BA(GPIO)(AW-1 downto AW-AWH),
         FMC  => BA(FMC) (AW-1 downto AW-AWH),
         TIM  => BA(TIM) (AW-1 downto AW-AWH),
         UART => BA(UART)(AW-1 downto AW-AWH)
         );

  -----------------------------------------------------------------------------
  -- design parameters: CPU Instructions
  -----------------------------------------------------------------------------
  -- CPU instruction set
  -- Note: Defining the OPcode in the way shown below, allows assembler-style
  -- programming with mnemonics rather than machine coding (see rom.vhd).
  constant OPCW : natural range 1 to DW := 5;    -- Opcode word width
  constant OPAW : natural range 1 to DW := 4;    -- ALU operation word width
  constant IOWW : natural range 1 to DW := 8;    -- immediate operand word width
  type t_instr is (add, sub, andi, ori, xori, slai, srai, mov,
                   opc8, opc9, opc10, opc11,
                   addil, addih, setil, setih,
                   ld, st, opc18,
                   opc19, opc20, opc21, opc22, opc23,
                   jmp, bne, bge, blt, bca, bov,
                   opc30, nop);
  -- Instructions targeted at the ALU are defined by means of a sub-type.
  -- This allows changing the opcode of instructions without having to
  -- modify the source code of the ALU.
  subtype t_alu_instr is t_instr range add to setih;
  type t_opcode is array (t_instr) of std_logic_vector(OPCW-1 downto 0);
  constant OPC : t_opcode := (  -- OPcode
         -- ALU operations -------------------------------
         add   => "00000",      --  0: addition
         sub   => "00001",      --  1: subtraction
         andi  => "00010",      --  2: bit-wise AND
         ori   => "00011",      --  3: bit-wise OR 
         xori  => "00100",      --  4: bit-wise XOR 
         slai  => "00101",      --  5: shift-left arithmetically
         srai  => "00110",      --  6: shift-right arithmetically
         mov   => "00111",      --  7: move between register
         opc8  => "01000",      --  8: RESERVED 
         opc9  => "01001",      --  9: RESERVED 
         opc10 => "01010",      -- 10: RESERVED 
         opc11 => "01011",      -- 11: RESERVED 
         -- Immediate Operands ---------------------------
         addil => "01100",      -- 12: add imm. constant low
         addih => "01101",      -- 13: add imm. constant high
         setil => "01110",      -- 14: set imm. constant low
         setih => "01111",      -- 15: set imm. constant high
         -- Memory load/store ----------------------------
         ld    => "10000",      -- 16: load from memory
         st    => "10001",      -- 17: store to memory
         opc18 => "10010",      -- 18: RESERVED 
         -- RESERVED -------------------------------------
         opc19 => "10011",      -- 19: RESERVED 
         opc20 => "10100",      -- 20: RESERVED 
         opc21 => "10101",      -- 12: RESERVED 
         opc22 => "10110",      -- 22: RESERVED 
         opc23 => "10111",      -- 23: RESERVED 
         -- Jump/Branch ----------------------------------
         jmp   => "11000",      -- 24: absolute jump
         bne   => "11001",      -- 25: branch if not equal (not Z)
         bge   => "11010",      -- 26: branch if greater/equal (not N or Z)
         blt   => "11011",      -- 27: branch if less than (N)
         bca   => "11100",      -- 28: branch if carry set (C)
         bov   => "11101",      -- 29: branch if overflow set (O)
         -- Others ---------------------------------------
         opc30 => "11110",      -- 30: RESERVED 
         nop   => "11111"       -- 31: no operation     
         );
  type t_flags is (Z, N, C, O); -- ALU flags (zero, negative, carry, overflow)
  type t_flag_arr is array (t_flags) of std_logic;
  -- register block
  constant RIDW : natural range 1 to DW := 3; -- register ID word width
  type t_regid is array(0 to 7) of std_logic_vector(RIDW-1 downto 0);
  constant reg : t_regid := ("000","001","010","011","100","101","110","111");  
  type t_regblk is array(0 to 7) of std_logic_vector(DW-1 downto 0);
  -- CPU address generation 
  type t_pc_mode  is (linear, abs_jump, rel_offset);  -- addr calcultion modi
  type t_addr_exc is (no_err, lin_err, rel_err);      -- address exceptions
 
  -----------------------------------------------------------------------------
  -- global types
  -----------------------------------------------------------------------------
  -- Master bus interface -----------------------------------------------------
  type t_bus2cpu is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  type t_cpu2bus is record
    data   : std_logic_vector(DW-1 downto 0);
    addr   : std_logic_vector(AW-1 downto 0);
    rd_enb : std_logic;
    wr_enb : std_logic;
  end record;
  -- ROM bus interface  ------------------------------------------------------
  type t_bus2rom is record
    addr   : std_logic_vector(AWROM-1 downto 0);
  end record;
  type t_rom2bus is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  -- RAM bus interface -------------------------------------------------------
  type t_bus2ram is record
    addr   : std_logic_vector(AWRAM-1 downto 0);
    data   : std_logic_vector(DW-1 downto 0);
    wr_enb : std_logic;
  end record;
  type t_ram2bus is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  -- read/write peripheral bus interface -------------------------------------
  type t_bus2rws is record
    addr   : std_logic_vector(AWPER-1 downto 0);
    data   : std_logic_vector(DW-1 downto 0);
    rd_enb : std_logic; -- use of this signal is optional, depending on slave
    wr_enb : std_logic;
  end record;
  type t_rws2bus is record
    data : std_logic_vector(DW-1 downto 0);
  end record;
  
  -----------------------------------------------------------------------------
  -- CPU internal types
  -----------------------------------------------------------------------------
  -- Control Unit / Register Block interface ----------------------------------
  type t_ctr2reg is record
    src1     : std_logic_vector(RIDW-1 downto 0);
    src2     : std_logic_vector(RIDW-1 downto 0);
    dest     : std_logic_vector(RIDW-1 downto 0);
    enb_res  : std_logic;
    data     : std_logic_vector(DW-1 downto 0);
    enb_data : std_logic;
  end record;
  type t_reg2ctr is record
    data : std_logic_vector(DW-1 downto 0);
    addr : std_logic_vector(AW-1 downto 0);
  end record;
  -- Control Unit / Program Counter interface --------------------------------
  type t_ctr2prc is record
    enb  : std_logic;
    mode : t_pc_mode;
    addr : std_logic_vector(AW-1 downto 0);
  end record;
  type t_prc2ctr is record
    pc  : std_logic_vector(AW-1 downto 0);
    exc : t_addr_exc;
  end record;
  -- Control Unit / ALU interface ---------------------------------------------
  type t_ctr2alu is record
    op  : std_logic_vector(OPAW-1 downto 0);  -- operation
    imm : std_logic_vector(IOWW-1 downto 0);  -- immediate operand
    enb : std_logic;                          -- enable flag update
  end record;
  type t_alu2ctr is record
    flag : t_flag_arr;
  end record;
    
  -----------------------------------------------------------------------------
  -- GPIO peripheral parameters
  -----------------------------------------------------------------------------
  -- GPIO design parameters
  constant c_gpio_port_ww         : natural range 1 to 16 := 8;   -- GPIO word width
  -- Relative GPIO Register Addresses
  constant c_addr_gpio_0_data_in  : std_logic_vector(AWPER-1 downto 0) := n2slv( 0, AWPER);
  constant c_addr_gpio_0_data_out : std_logic_vector(AWPER-1 downto 0) := n2slv( 1, AWPER);
  constant c_addr_gpio_0_out_enb  : std_logic_vector(AWPER-1 downto 0) := n2slv( 2, AWPER);
  constant c_addr_gpio_1_data_in  : std_logic_vector(AWPER-1 downto 0) := n2slv( 3, AWPER);
  constant c_addr_gpio_1_data_out : std_logic_vector(AWPER-1 downto 0) := n2slv( 4, AWPER);
  constant c_addr_gpio_1_out_enb  : std_logic_vector(AWPER-1 downto 0) := n2slv( 5, AWPER);
  -- GPIO address decoding type
  type t_gpio_addr_sel is (none, gpio_0_data_in, gpio_0_data_out, gpio_0_out_enb,
                                 gpio_1_data_in, gpio_1_data_out, gpio_1_out_enb);

  -----------------------------------------------------------------------------
  -- FMC peripheral parameters
  -----------------------------------------------------------------------------
  -- FMC design parameters
  constant c_fmc_num_chn       : natural range 1 to   8 :=  1;    -- # of FMC channels
  constant c_fmc_rom_aw        : natural range 1 to  10 := 10;    -- FMC ROM addr width
  constant c_fmc_rom_dw        : natural range 1 to  20 := 20;    -- FMC ROM data width
  constant c_fmc_tone_ww       : natural range 1 to  16 :=  6;    -- FMC duration word width
  constant c_fmc_dur_ww        : natural range 1 to  16 := 14;    -- FMC tone word width
  constant c_fmc_max_step      : natural range 1 to 127 := 80;    -- # of steps in same direction
  constant c_fmc_last_tone     : unsigned(c_fmc_dur_ww-1 downto 0) := (others => '1'); 
  -- Relative FMC Register Addresses
  constant c_addr_fmc_chn_enb  : std_logic_vector(AWPER-1 downto 0) := n2slv( 0, AWPER);
  constant c_addr_fmc_tmp_ctrl : std_logic_vector(AWPER-1 downto 0) := n2slv( 1, AWPER);
  -- FMC address decoding type
  type t_fmc_addr_sel is (none, fmc_chn_enb, fmc_tmp_ctrl);

end package mcu_pkg;


package body mcu_pkg is
  -----------------------------------------------------------------------------
  -- Function Implementations
  -----------------------------------------------------------------------------
  -- std_logic_vector(to_signed(i,w))
  function i2slv(i : integer;w : positive) return std_logic_vector is
  begin 
    return std_logic_vector(to_signed(i,w));
  end function i2slv;
  -- std_logic_vector(to_unsigned(n,w))
  function n2slv(n : natural;w : positive) return std_logic_vector is
  begin 
    return std_logic_vector(to_unsigned(n,w));
  end function n2slv;
  -- form instruction word for NOP instruction
  function iw_nop return std_logic_vector is
    variable v : std_logic_vector(DW-1 downto 0);
  begin
    for k in DW-1 downto DW-OPCW loop
      v(k) := OPC(nop)(k-DW+OPCW);
    end loop;
    for k in DW-OPCW-1 downto 0 loop
      v(k) := '0';
    end loop;
    return v;
  end function iw_nop;

end package body mcu_pkg;
