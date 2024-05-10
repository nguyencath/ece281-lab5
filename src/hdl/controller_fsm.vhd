----------------------------------------------------------------------------------

-- Company: 

-- Engineer: 

-- 

-- Create Date: 05/02/2024 01:23:21 PM

-- Design Name: 

-- Module Name: controller_fsm - Behavioral

-- Project Name: 

-- Target Devices: 

-- Tool Versions: 

-- Description: 

-- 

-- Dependencies: 

-- 

-- Revision:

-- Revision 0.01 - File Created

-- Additional Comments:

-- 

----------------------------------------------------------------------------------
 
 
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
 
-- Uncomment the following library declaration if using

-- arithmetic functions with Signed or Unsigned values

--use IEEE.NUMERIC_STD.ALL;
 
-- Uncomment the following library declaration if instantiating

-- any Xilinx leaf cells in this code.

--library UNISIM;

--use UNISIM.VComponents.all;
 
entity controller_fsm is

    Port ( i_reset : in STD_LOGIC;

           i_adv : in STD_LOGIC;

           i_clk : in std_logic;

           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));

end controller_fsm;
 
architecture Behavioral of controller_fsm is

    signal f_Q, f_Q_next : std_logic_vector(1 downto 0) := "00";
 
	signal  w_cycle : std_logic_vector (3 downto 0);

	signal  w_enable_adv: std_logic; -- where should this signal go/what is it?
 
 
begin
    
    -- next state logic

    f_Q_next(1) <= (not f_Q(1) and f_Q(0) and i_adv) or
                   (f_Q(1) and not f_Q(0) and i_adv) or
                   (f_Q(1) and not f_Q(0) and not i_adv) or
                   (f_Q(1) and f_Q(0) and not i_adv);
                   
    f_Q_next(0) <= (not f_Q(1) and not f_Q(0) and i_adv) or
                   (not f_Q(1) and f_Q(0) and not i_adv) or
                   (f_Q(1) and not f_Q(0) and i_adv)    or
                   (f_Q(1) and f_Q(0) and not i_adv);
    
    o_cycle(0) <= (not f_Q(1) and not f_Q(0));
    
    o_cycle(1) <= (not f_Q(1) and f_Q(0));
    
    o_cycle(2) <= (f_Q(1) and not f_Q(0));
    
    o_cycle(3) <= (f_Q(1) and f_Q(0));

    
    register_proc: process (i_clk)

    begin
        if (rising_edge (i_clk)) then
            if (i_reset = '1') then

                f_Q <= "00";
            
            elsif(i_adv = '1') then
            
                f_Q <= f_Q_next;

--              wont let me put i_adv <= '0' since it's an input

            else
            
            f_Q <= f_Q;

            end if;

        end if;

    end process register_proc;

 
end Behavioral;
