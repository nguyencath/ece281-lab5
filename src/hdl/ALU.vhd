--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     ADD         000
--|     SUBTRACT    001
--|     AND         010
--|     OR          011
--|     R SHIFT     100
--|     L SHIFT     101
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ALU is
-- TODO
        Port ( i_clk		: in  STD_LOGIC; -- is there a clock signal input?
               i_A		    : in  STD_LOGIC_VECTOR (7 downto 0);
               i_B          : in  STD_LOGIC_VECTOR (7 downto 0);
               i_op         : in STD_LOGIC_VECTOR  (2 downto 0);
               i_cycle      : in STD_LOGIC_VECTOR  (3 downto 0);
               o_result     : out STD_LOGIC_VECTOR (7 downto 0);
               o_flags      : out STD_LOGIC_VECTOR (2 downto 0) --  is this supposed to be a vector?
               );
end ALU;
architecture behavioral of ALU is 
	-- declare components and signals
--    component adder is 
--        port (
--        i_A     : in std_logic_vector (7 downto 0);
--        i_B     : in std_logic_vector (7 downto 0);
--        i_cIn   : in std_logic;
--        o_add   : out std_logic_vector (7 downto 0);
--        o_cOut  : out std_logic
--        );
--    end component;
--    component gates is
--        port (
--        i_A         : in std_logic_vector (7 downto 0);
--        i_B         : in std_logic_vector (7 downto 0);
--        i_select    : in std_logic;
--        o_andOr     : out std_logic_vector (7 downto 0)
--        );
--    end component;
    signal w_Result, w_B: std_logic_vector (7 downto 0) := "00000000";
    signal w_carryResult : std_logic_vector (8 downto 0) := "000000000";
begin
	-- PORT MAPS ----------------------------------------
    -- how do i port map a mux?
--    adder_inst : adder
--    port map(
--        i_A     => i_A,
--        i_B     => w_B,
--        i_cIn   => i_op(0),
--        o_cOut  => w_carryResult(8),
--        o_add   => w_Result
--    );
--    gates_inst   :   gates
--    port map(
--        i_A         => i_A,
--        i_B         => i_B,
--        i_select    => i_op(0),
--        o_andOR     => w_Result
--    );
 
	-- CONCURRENT STATEMENTS ----------------------------
--	w_B <= i_B when i_op(0) = '0' else
--	       not i_B;

    w_B <= i_B;
--   w_carryResult <= std_logic_vector(unsigned('0'&i_A) + unsigned('0'&w_B)) when i_op = "000" else
--                    std_logic_vector(unsigned('0'&i_A) and unsigned('0'&w_B)) when i_op = "010" else
--                    std_logic_vector(unsigned('0'&i_A) - not unsigned('0'&w_B)) when i_op = "010";
--                -- +/- logic
--    w_Result <= std_logic_vector(unsigned(i_A) + unsigned(w_B)) when i_op = "000" else
--                std_logic_vector(unsigned(i_A) - not unsigned(w_B)) when i_op = "001" else
----                -- and/or logic
--                std_logic_vector(unsigned(i_A) and unsigned(w_B)) when i_op = "010" else
--                std_logic_vector(unsigned(i_A) or not unsigned(w_B)) when i_op = "011" else
--                -- right/left shift logic
--                std_logic_vector(shift_right(unsigned(i_A),to_integer(unsigned(i_B)))) when i_op = "100" else
--                std_logic_vector(shift_left(unsigned(i_A),to_integer(unsigned(i_B)))) when i_op = "101";
 
 
    w_carryResult <= std_logic_vector(unsigned('0'&i_A) + unsigned('0'&w_B)) when i_op = "000" else
                     std_logic_vector((unsigned('0'&i_A)) + (unsigned(not '0'&w_B)+1)) when i_op = "001" else
                    std_logic_vector(unsigned('0'&i_A) and unsigned('0'&w_B)) when i_op = "010";
                             -- +/- logic
     w_Result <= std_logic_vector(unsigned(i_A) + unsigned(w_B)) when i_op = "000" else
                 std_logic_vector(unsigned(i_A) + (unsigned(not w_B) + 1)) when i_op = "001" else
 --                -- and/or logic
                 std_logic_vector(unsigned(i_A) and unsigned(w_B)) when i_op = "010" else
                 std_logic_vector(unsigned(i_A) or unsigned(w_B)) when i_op = "011" else
--                 -- right/left shift logic
                 std_logic_vector(shift_right(unsigned(i_A),to_integer(unsigned(i_B)))) when i_op = "100" else
                 std_logic_vector(shift_left(unsigned(i_A),to_integer(unsigned(i_B)))) when i_op = "101" else
                 
                 std_logic_vector(not(unsigned(i_A) and unsigned(w_B))) when i_op = "110" else
                 std_logic_vector(not(unsigned(i_A) or unsigned(w_B))) when i_op = "111";
                 
    -- Pass the answer to the output
    o_Result <= w_Result;
    -- Re-check these Lines Later!
    -- Need to figure out a way to pass the flags only when on cycle "1000" or cycle that completes the calculation
    o_flags(1) <= '1' when (w_Result = "00000000" and i_cycle = "0100") else '0';
    o_flags(0) <= w_carryResult(8) when i_cycle = "1000";
--                '1' when (w_carryResult(8) = '0' and w_carryResult(7 downto 0 = ("11111111") and i_cycle = "1000") else '0';
    o_flags(2) <= w_Result(7) when i_cycle = "1000";
end behavioral;