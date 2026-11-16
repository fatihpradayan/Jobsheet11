library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Batang warna vertikal, 8 zona (80 px untuk 640, 100 px untuk 800)
entity color_bar_pattern is
    Port ( h_count : in  integer range 0 to 1055;
           mode    : in  STD_LOGIC;
           rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
end color_bar_pattern;

architecture Behavioral of color_bar_pattern is
    signal zone : integer range 0 to 7;
begin
    process(h_count, mode)
        variable z : integer;
    begin
        if mode = '0' then
            z := h_count / 80;
        else
            z := h_count / 100;
        end if;
        if z > 7 then z := 7; end if;
        zone <= z;
    end process;

    with zone select
        rgb <= x"FFF" when 0,  -- putih
               x"FF0" when 1,  -- kuning
               x"0FF" when 2,  -- cyan
               x"0F0" when 3,  -- hijau
               x"F0F" when 4,  -- magenta
               x"F00" when 5,  -- merah
               x"00F" when 6,  -- biru
               x"000" when others; -- hitam
end Behavioral;