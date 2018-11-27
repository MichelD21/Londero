
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.rayTracing_pkg.all;

entity cross_product_tb is
end cross_product_tb;

architecture test of cross_product_tb is
	
	--Signals
	signal clk, rst   : std_logic := '1';
	signal start_i    : std_logic;
	signal done_o     : std_logic;
	signal vecA, vecB : vector3D_t;
	signal result_o   : vector3D_t;
	signal fpu_s      : fpu_t;
	signal fpu_start  : std_logic;
	signal fpu_A      : data_t;
	signal fpu_B      : data_t;
	  
begin
 
	-- Generate clk and rst;
	clk <= not clk after 5 ns;
	rst <= '0' after 5 ns;

	CROSS_PRODUCT: entity work.cross_product
        port map (
            clk        => clk,
            rst        => rst,
            start_i    => start_i, 
            done_o     => done_o, 
            vecA_i     => vecA,
            vecB_i     => vecB,
            result_o   => result_o,
            fpu_io     => fpu_s
        );
		
		
	FPU_STARTER: entity work.fpu_starter
        port map (
            clk         => clk,
            rst         => rst,
            start_i     => fpu_s.start_i, 
            ready_i     => fpu_s.ready_o, 
            start_o     => fpu_start
        );
		
	FPU_teste: entity work.fpu
		port map (
				clk_i				=> clk,	
				opa_i				=> fpu_s.a_i,		
				opb_i				=> fpu_s.b_i,
				fpu_op_i			=> fpu_s.op_i,
				rmode_i				=> FPU_ROUNDING_MODE,		  
				output_o			=> fpu_s.result_o,
				start_i				=> fpu_start,
				ready_o				=> fpu_s.ready_o,
				ine_o 				=> open,
				overflow_o  		=> open,	
				underflow_o 		=> open,
				div_zero_o  		=> open,
				inf_o				=> open,			
				zero_o				=> open,
				qnan_o				=> open,
				snan_o				=> open,
				altb_o				=> fpu_s.agtb_o,
				blta_o				=> fpu_s.altb_o,
				aeqb_o				=> fpu_s.aeqb_o,
				cmp_unordered_o		=> open,
				cmp_inf_o			=> open, 
				cmp_zero_o			=> open
		);   

	---- SIMULATED FPU.
	--process(clk, rst)
	--	variable cycle_count : integer;
	--	variable stop        : boolean;
	--	variable mult_64bits : std_logic_vector(fpu.result_o'length*2-1 downto 0);
	--begin
	--	if rst = '1' then
	--		fpu.ready_o  <= '0';
	--		fpu.result_o <= (OTHERS=>'0');
	--		fpu_A <= (OTHERS=>'0');
	--		fpu_B <= (OTHERS=>'0');
	--		fpu.result_o <= (OTHERS=>'0');
	--		mult_64bits  := (OTHERS=>'0');
	--		stop         := false;
	--		
	--	elsif rising_edge(clk) then
	--		-- Start
	--		if fpu_start = '1' then
	--			fpu_A     <= fpu.a_i;
	--			fpu_B 	  <= fpu.b_i;
	--			cycle_count := 0;
	--			stop      := false;
	--			
	--		--Do nothing, just wait new start.	
	--		elsif stop = true then
	--			fpu.ready_o <= '0';
	--			
	--		--Simulate FPU behavior.
	--		else
	--			-- Simulate operation delay and generate the result.
	--			case fpu.op_i is
	--				--SUB
	--				when FPU_SUB =>
	--					if cycle_count < 20 then
	--						cycle_count := cycle_count + 1;
	--					else
	--						fpu.result_o <= fpu_A - fpu_B;
	--						fpu.ready_o  <= '1';
	--						stop         := true;
	--					end if;
	--				
	--				--MUL				
	--				when FPU_MUL =>
	--					if cycle_count < 40 then
	--						cycle_count := cycle_count + 1;
	--					else
	--						mult_64bits  := fpu_A * fpu_B;
	--						fpu.result_o <= mult_64bits(fpu.result_o'range);
	--						fpu.ready_o  <= '1';
	--						stop         := true;
	--					end if;
	--					
	--				--ADD				
	--				when FPU_ADD =>
	--					if cycle_count < 15 then
	--						cycle_count := cycle_count + 1;
	--					else
	--						fpu.result_o <= fpu_A + fpu_B;
	--						fpu.ready_o  <= '1';
	--						stop         := true;
	--					end if;						
	--					
	--				-- OTHERS
	--				when OTHERS  =>
	--					--NADA AINDA.
	--					stop := true;
	--					fpu.ready_o  <= '1';
	--					
	--			end case;
	--			
	--		end if;
	--	end if;
	--end process;
	
	
	-- Generate others stimuli
	process
	begin
		start_i <= '0';
		vecA    <= VECTOR3D_RESET_ZERO;
		vecB    <= VECTOR3D_RESET_ZERO;
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		vecA <= (x"3F800000",x"40000000",x"40400000");
		vecB <= (x"40400000",x"40000000",x"3F800000");
		start_i <= '1';
		
		wait until done_o = '1';
		wait until rising_edge(clk);
		start_i <= '0';
		
		--Another test
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		vecA <= (x"3F800000",x"40000000",x"40400000");
		vecB <= (x"41200000",x"41100000",x"41000000");
		start_i <= '1';
		
		wait until done_o = '1';
		wait until rising_edge(clk);
		start_i <= '0';
		wait;
	end process;
	    
end test;