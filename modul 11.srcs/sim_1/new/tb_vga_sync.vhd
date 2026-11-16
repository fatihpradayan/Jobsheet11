library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench vga_sync: verifikasi lebar pulsa Hsync/Vsync di kedua mode.
-- Jalankan dengan "run all" (butuh sekitar 100 ms simulasi).
entity tb_vga_sync is
end tb_vga_sync;

architecture sim of tb_vga_sync is
    component vga_sync
        Port ( pclk : in STD_LOGIC; rst : in STD_LOGIC; mode : in STD_LOGIC;
               hsync : out STD_LOGIC; vsync : out STD_LOGIC; video_on : out STD_LOGIC;
               h_count : out integer range 0 to 1055;
               v_count : out integer range 0 to 627 );
    end component;

    signal pclk, rst, mode : STD_LOGIC := '0';
    signal hsync, vsync, video_on : STD_LOGIC;
    signal h_count : integer range 0 to 1055;
    signal v_count : integer range 0 to 627;
    signal period  : time := 40 ns;  -- 25 MHz
begin
    uut : vga_sync
        port map ( pclk => pclk, rst => rst, mode => mode, hsync => hsync,
                   vsync => vsync, video_on => video_on,
                   h_count => h_count, v_count => v_count );

    clk_proc : process
    begin
        pclk <= '0'; wait for period/2;
        pclk <= '1'; wait for period/2;
    end process;

    stim : process
        variable t0 : time;
    begin
        ---------------- Mode 0: 640x480, sync aktif rendah ----------------
        mode <= '0'; period <= 40 ns;
        rst <= '1'; wait for 200 ns; rst <= '0';

        wait until falling_edge(hsync); t0 := now;
        wait until rising_edge(hsync);
        assert (now - t0) = 96 * 40 ns
            report "Mode 0: lebar hsync salah (harus 96 clock)" severity error;

        wait until falling_edge(vsync); t0 := now;
        wait until rising_edge(vsync);
        assert (now - t0) = 2 * 800 * 40 ns
            report "Mode 0: lebar vsync salah (harus 2 baris = 1600 clock)" severity error;

        ---------------- Mode 1: 800x600, sync aktif tinggi ----------------
        mode <= '1'; period <= 25 ns;  -- 40 MHz
        rst <= '1'; wait for 200 ns; rst <= '0';

        wait until rising_edge(hsync); t0 := now;
        wait until falling_edge(hsync);
        assert (now - t0) = 128 * 25 ns
            report "Mode 1: lebar hsync salah (harus 128 clock)" severity error;

        wait until rising_edge(vsync); t0 := now;
        wait until falling_edge(vsync);
        assert (now - t0) = 4 * 1056 * 25 ns
            report "Mode 1: lebar vsync salah (harus 4 baris = 4224 clock)" severity error;

        report "Simulasi selesai: semua assert lulus" severity note;
        wait;
    end process;
end sim;