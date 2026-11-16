library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

-- Top-level Jobsheet 11: batang warna VGA, Tugas 3 (SW15 memilih mode)
-- sw15 = '0' : 640x480@60Hz (25 MHz)
-- sw15 = '1' : 800x600@60Hz (40 MHz)
entity js11_top is
    Port ( clk      : in  STD_LOGIC;
           btnC     : in  STD_LOGIC;
           sw15     : in  STD_LOGIC;
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync    : out STD_LOGIC;
           Vsync    : out STD_LOGIC );
end js11_top;

architecture Behavioral of js11_top is
    component clk_wiz_0
        port ( clk_out1 : out STD_LOGIC;   -- 25 MHz
               clk_out2 : out STD_LOGIC;   -- 40 MHz
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

    component color_bar_pattern
        Port ( h_count : in  integer range 0 to 1055;
               mode    : in  STD_LOGIC;
               rgb     : out STD_LOGIC_VECTOR(11 downto 0) );
    end component;

    signal clk25, clk40, pclk : STD_LOGIC;
    signal fb_raw, fb_buf     : STD_LOGIC;
    signal locked, rst_int    : STD_LOGIC;
    signal video_on           : STD_LOGIC;
    signal h_count            : integer range 0 to 1055;
    signal v_count            : integer range 0 to 627;
    signal rgb, rgb_out       : STD_LOGIC_VECTOR(11 downto 0);
    signal mode_s1, mode_s2, mode_prev : STD_LOGIC := '0';
begin
    u_clk : clk_wiz_0
        port map ( clk_out1 => clk25, clk_out2 => clk40,
                   clkfb_in => fb_buf, clkfb_out => fb_raw,
                   reset => btnC, locked => locked, clk_in1 => clk );

    -- Feedback MMCM (user-controlled on-chip)
    u_fb : BUFG port map ( I => fb_raw, O => fb_buf );

    -- Pilih pixel clock tanpa glitch
    u_mux : BUFGMUX
        port map ( O => pclk, I0 => clk25, I1 => clk40, S => sw15 );

    -- Sinkronkan switch ke pclk, reset counter saat mode berubah
    process(pclk)
    begin
        if rising_edge(pclk) then
            mode_s1   <= sw15;
            mode_s2   <= mode_s1;
            mode_prev <= mode_s2;
        end if;
    end process;
    rst_int <= btnC or (not locked) or (mode_s2 xor mode_prev);

    u_sync : vga_sync
        port map ( pclk => pclk, rst => rst_int, mode => mode_s2,
                   hsync => Hsync, vsync => Vsync,
                   video_on => video_on, h_count => h_count, v_count => v_count );

    u_pat : color_bar_pattern
        port map ( h_count => h_count, mode => mode_s2, rgb => rgb );

    rgb_out <= rgb when video_on = '1' else (others => '0');

    vgaRed   <= rgb_out(11 downto 8);
    vgaGreen <= rgb_out(7 downto 4);
    vgaBlue  <= rgb_out(3 downto 0);
end Behavioral;