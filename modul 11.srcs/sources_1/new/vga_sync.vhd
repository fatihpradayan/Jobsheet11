library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Pembangkit sinkronisasi VGA
-- mode '0' = 640x480@60Hz (pclk 25 MHz, sync aktif rendah)
-- mode '1' = 800x600@60Hz (pclk 40 MHz, sync aktif tinggi)
entity vga_sync is
    Port ( pclk     : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           mode     : in  STD_LOGIC;
           hsync    : out STD_LOGIC;
           vsync    : out STD_LOGIC;
           video_on : out STD_LOGIC;
           h_count  : out integer range 0 to 1055;
           v_count  : out integer range 0 to 627 );
end vga_sync;

architecture Behavioral of vga_sync is
    -- 640x480@60Hz
    constant H_DISP_A : integer := 640;
    constant H_FP_A   : integer := 16;
    constant H_SYN_A  : integer := 96;
    constant H_TOT_A  : integer := 800;
    constant V_DISP_A : integer := 480;
    constant V_FP_A   : integer := 10;
    constant V_SYN_A  : integer := 2;
    constant V_TOT_A  : integer := 525;

    -- 800x600@60Hz
    constant H_DISP_B : integer := 800;
    constant H_FP_B   : integer := 40;
    constant H_SYN_B  : integer := 128;
    constant H_TOT_B  : integer := 1056;
    constant V_DISP_B : integer := 600;
    constant V_FP_B   : integer := 1;
    constant V_SYN_B  : integer := 4;
    constant V_TOT_B  : integer := 628;

    signal hc : integer range 0 to 1055 := 0;
    signal vc : integer range 0 to 627  := 0;

    signal h_disp, h_fp, h_syn, h_tot : integer range 0 to 1056;
    signal v_disp, v_fp, v_syn, v_tot : integer range 0 to 628;
    signal hs_raw, vs_raw : std_logic;
begin
    h_disp <= H_DISP_A when mode = '0' else H_DISP_B;
    h_fp   <= H_FP_A   when mode = '0' else H_FP_B;
    h_syn  <= H_SYN_A  when mode = '0' else H_SYN_B;
    h_tot  <= H_TOT_A  when mode = '0' else H_TOT_B;
    v_disp <= V_DISP_A when mode = '0' else V_DISP_B;
    v_fp   <= V_FP_A   when mode = '0' else V_FP_B;
    v_syn  <= V_SYN_A  when mode = '0' else V_SYN_B;
    v_tot  <= V_TOT_A  when mode = '0' else V_TOT_B;

    process(pclk)
    begin
        if rising_edge(pclk) then
            if rst = '1' then
                hc <= 0;
                vc <= 0;
            elsif hc = h_tot - 1 then
                hc <= 0;
                if vc = v_tot - 1 then
                    vc <= 0;
                else
                    vc <= vc + 1;
                end if;
            else
                hc <= hc + 1;
            end if;
        end if;
    end process;

    -- Pulsa sync (aktif '1'), polaritas disesuaikan di bawah
    hs_raw <= '1' when (hc >= h_disp + h_fp) and
                       (hc <  h_disp + h_fp + h_syn) else '0';
    vs_raw <= '1' when (vc >= v_disp + v_fp) and
                       (vc <  v_disp + v_fp + v_syn) else '0';

    hsync <= not hs_raw when mode = '0' else hs_raw;
    vsync <= not vs_raw when mode = '0' else vs_raw;

    video_on <= '1' when (hc < h_disp) and (vc < v_disp) else '0';

    h_count <= hc;
    v_count <= vc;
end Behavioral;