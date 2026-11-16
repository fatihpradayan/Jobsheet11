library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

-- Tugas 1 + 2: papan catur 640x480 dengan kotak merah yang digeser oleh sw(3 downto 0)
entity js11_tugas_top is
    Port ( clk      : in  STD_LOGIC;
           btnC     : in  STD_LOGIC;
           sw       : in  STD_LOGIC_VECTOR(3 downto 0);
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync    : out STD_LOGIC;
           Vsync    : out STD_LOGIC );
end js11_tugas_top;

architecture Behavioral of js11_tugas_top is
    component clk_wiz_0
        port ( clk_out1 : out STD_LOGIC;
               clk_out2 : out STD_LOGIC;
               clkfb_in  : in  STD_LOGIC;
               clkfb_out : out STD_LOGIC;
               reset    : in  STD_LOGIC;
               locked   : out STD_LOGIC;
               clk_in1  : in  STD_LOGIC );
    end component;

    component vga_sync
        Port ( pclk     : in  STD_LOGIC;
               rst      : in  STD_LOGIC;
               mode     : in  STD_LOGIC;
               hsync    : out STD_LOGIC;
               vsync    : out STD_LOGIC;
               video_on : out STD_LOGIC;
               h_count  : out integer range 0 to 1055;
               v_count  : out integer range 0 to 627 );
    end component;

    component checkerboard_pattern
        Port ( h_count : in  integer range 0 to 1055;
               v_count : in  integer range 0 to 627;
               rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    constant BOX_W : integer := 40;
    constant BOX_Y : integer := 220;
    constant BOX_H : integer := 40;

    signal clk25_raw, clk25 : STD_LOGIC;
    signal fb_raw, fb_buf   : STD_LOGIC;
    signal locked, rst_int  : STD_LOGIC;
    signal video_on         : STD_LOGIC;
    signal h_count          : integer range 0 to 1055;
    signal v_count          : integer range 0 to 627;
    signal rgb_bg, rgb_sel, rgb_out : STD_LOGIC_VECTOR(11 downto 0);
    signal box_x            : integer range 0 to 600;
    signal in_box           : STD_LOGIC;
begin
    u_clk : clk_wiz_0
        port map ( clk_out1 => clk25_raw, clk_out2 => open,
                   clkfb_in => fb_buf, clkfb_out => fb_raw,
                   reset => btnC, locked => locked, clk_in1 => clk );

    -- Feedback MMCM (user-controlled on-chip)
    u_fb : BUFG port map ( I => fb_raw, O => fb_buf );

    -- Output Clocking Wizard dibuat "No buffer", jadi BUFG dipasang di sini
    u_bufg : BUFG port map ( I => clk25_raw, O => clk25 );

    rst_int <= btnC or (not locked);

    u_sync : vga_sync
        port map ( pclk => clk25, rst => rst_int, mode => '0',
                   hsync => Hsync, vsync => Vsync,
                   video_on => video_on, h_count => h_count, v_count => v_count );

    u_bg : checkerboard_pattern
        port map ( h_count => h_count, v_count => v_count, rgb => rgb_bg );

    -- sw = 0..15 -> posisi x = 0..600 (kotak 40 px, maksimum berakhir di 640)
    box_x <= to_integer(unsigned(sw)) * BOX_W;

    in_box <= '1' when (h_count >= box_x) and (h_count < box_x + BOX_W) and
                       (v_count >= BOX_Y) and (v_count < BOX_Y + BOX_H) else '0';

    rgb_sel <= x"F00" when in_box = '1' else rgb_bg;
    rgb_out <= rgb_sel when video_on = '1' else (others => '0');

    vgaRed   <= rgb_out(11 downto 8);
    vgaGreen <= rgb_out(7 downto 4);
    vgaBlue  <= rgb_out(3 downto 0);
end Behavioral;