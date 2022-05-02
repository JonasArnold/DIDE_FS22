library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gk_pkg is
  
  -----------------------------------------------------------------------------
  -- IEEE-754 floating-point data types
  -----------------------------------------------------------------------------
  -- binary16 -----------------------------------------------------------------
  type t_gk_b16 is record
    s : std_logic;            -- sign
    e : unsigned(4 downto 0); -- exponent
    m : unsigned(9 downto 0); -- mantissa
  end record;
  -- binary32 -----------------------------------------------------------------
  type t_gk_b32 is record
    s : std_logic;             -- sign
    e : unsigned( 7 downto 0); -- exponent
    m : unsigned(22 downto 0); -- mantissa
  end record;

  -----------------------------------------------------------------------------
  -- IEEE-754 floating-point conversion functions (declarations)
  -----------------------------------------------------------------------------
  -- binary16 to fix-point ----------------------------------------------------
  function f_b16_2_fk(b16 : in t_gk_b16) return std_logic_vector;

end package gk_pkg;


package body gk_pkg is

  -----------------------------------------------------------------------------
  -- IEEE-754 floating-point conversion functions (implementations)
  -----------------------------------------------------------------------------
  -- binary16 to fix-point ----------------------------------------------------
  function f_b16_2_fk(b16 : in t_gk_b16) return std_logic_vector is
    -- derive constant values from input type
    constant M : natural := b16.m'LENGTH; -- # of mantissa bits
    constant E : natural := b16.e'LENGTH; -- # of exponent bits
    constant B : natural := 2**(E-1)-1;   -- exponent bias
    constant W : natural := 1; -- ---> ToDo  # of bits in fix-point output
    constant F : natural := 1; -- ---> ToDo  # of fractional bits in fix-point output
    -- define local variables
    variable i : natural;                 -- bit index of leading '1' 
    variable r : std_logic_vector(W-1 downto 0);
  begin
    -- 1) assign default value '0' to all result bits
    r := (others => '0');
    -- 2) from exponent value e derive position of leading '1' within output vector
       -- ---> ToDo
    -- 3) assign mantissa with leading '1' to output vector
       -- ---> ToDo
    -- 4) negate output vector in 2sC format if sign-bit is set
       -- ---> ToDo
    -- return fix-point value
    return r;
  end function;
    
end package body gk_pkg;
