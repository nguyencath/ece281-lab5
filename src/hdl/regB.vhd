----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2024 03:30:25 PM
-- Design Name: 
-- Module Name: regB - Behavioral
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

entity regB is
    Port ( i_regB : in STD_LOGIC_VECTOR (7 downto 0);
           i_cycle : in STD_LOGIC_VECTOR (3 downto 0);
           o_regB : out STD_LOGIC_VECTOR (7 downto 0));
end regB;

architecture Behavioral of regB is

begin


end Behavioral;
