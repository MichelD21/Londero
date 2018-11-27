
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.rayTracing_pkg.all;

entity rayTriangle_intersection_tb is
end rayTriangle_intersection_tb;

architecture test of rayTriangle_intersection_tb is

	--Signals
	signal clk, rst    : std_logic := '1';
	signal data_av_i   : std_logic;
	signal done_o      : std_logic;
	signal collision_o : std_logic;
	signal data_i      : data_t;
	signal result_o    : data_t;
	
begin

	-- Generate clk and rst;
	clk <= not clk after 5 ns;
	rst <= '0' after 10.1 ns;

	DUV: entity work.rayTriangle_intersection
        port map (
            clk          => clk,
            rst          => rst,
            data_av_i    => data_av_i, 
            done_o       => done_o, 
            collision_o  => collision_o,
            data_i       => data_i,
            result_o     => result_o
        );
		
	-- Generate others stimuli
	process
	begin
		data_av_i <= '0';
		data_i <= (OTHERS=> '0');
		wait until rising_edge(clk);
		
		data_i <= x"BF2F6B22"; -- OX
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"BEFFF2E5"; -- OY
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3FBBE29A"; -- OZ
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3ED0F0E3"; -- DX
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3ECA222F"; -- DY
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"BF52BB0F"; -- DZ
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"BDCCCCCD"; -- V0X
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"00000000"; -- V0Y
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3E4CCCCD"; -- V0Z
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3ECCCCCD"; -- V1X
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"00000000"; -- V1Y
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"BE4CCCCD"; -- V1Z
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3E19999A"; -- V2X
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"3ECCCCCD"; -- V2Y
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_i <= x"BDCCCCCD"; -- V2Z
		data_av_i <= '1';
		wait until rising_edge(clk);
		
		data_av_i <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		data_av_i <= '1';
		wait until rising_edge(clk);
		data_av_i <= '0';
		wait until done_o = '1';
		
		report "Terminou!!!" severity note;
		wait;
		
	end process;
	
end test;

architecture test_file of rayTriangle_intersection_tb is

	--Signals
	signal clk, rst    : std_logic := '1';
	signal data_av_i   : std_logic;
	signal done_o      : std_logic;
	signal collision_o : std_logic;
	signal data_i      : data_t;
	signal result_o    : data_t;
	
begin

	-- Generate clk and rst;
	clk <= not clk after 5 ns;
	rst <= '0' after 10.1 ns;

	RAY_TRIANGLE_INTERSECTION: entity work.rayTriangle_intersection
        port map (
            clk          => clk,
            rst          => rst,
            data_av_i    => data_av_i, 
            done_o       => done_o, 
            collision_o  => collision_o,
            data_i       => data_i,
            result_o     => result_o
        );
		
	-- Generate others stimuli from file.
	process
	begin
		data_av_i <= '0';
		data_i <= (OTHERS=> '0');
		wait until rising_edge(clk);
	end process;
	
end test_file;
