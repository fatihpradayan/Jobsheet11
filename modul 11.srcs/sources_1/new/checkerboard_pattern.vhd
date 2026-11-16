library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Tugas 1: papan catur, kotak 32x32 piksel (bit 5 dari h_count xor v_count)
entity checkerboard_pattern is
    Port ( h_count : in  integer range 0 to 1055;
           v_count : in  integer range 0 to 627;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end checkerboard_pattern;

architecture Behavioral of checkerboard_pattern is
    signal h_u, v_u : unsigned(10 downto 0);
begin
    h_u <= to_unsigned(h_count, 11);
    v_u <= to_unsigned(v_count, 11);
    rgb <= x"FFF" when (h_u(5) xor v_u(5)) = '1' else x"007";
end Behavioral;