
library IEEE;
use IEEE.std_logic_1164.all;

entity fpu_starter_tb is
end fpu_starter_tb;

architecture test of fpu_starter_tb is	

	--Signals
	signal clk, rst  : std_logic := '1';
	signal start_i : std_logic;
	signal ready_i   : std_logic;
	signal start_o   : std_logic;
	
begin

	-- Generate clk and rst;
	clk <= not clk after 5 ns;
	rst <= '0' after 5 ns;

	FPU_STARTER: entity work.fpu_starter
        port map (
            clk         => clk,
            rst         => rst,
            start_i     => start_i, 
            ready_i     => ready_i, 
            start_o     => start_o
        );
		
	-- Generate others stimuli
	process
	begin
		start_i <= '0';
		ready_i   <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		start_i <= '1';
		
		for i in 1 to 5 loop
			wait until rising_edge(clk);
		end loop;
		
		ready_i <= '1';
		wait until rising_edge(clk);
		ready_i <= '0';
		
		for i in 1 to 5 loop
			wait until rising_edge(clk);
		end loop;
		
		ready_i <= '1';
		wait until rising_edge(clk);
		ready_i <= '0';
		start_i <= '0';
		
		wait;
	end process;
	    
end test;