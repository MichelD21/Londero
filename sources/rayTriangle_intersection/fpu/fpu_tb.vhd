library ieee;
use ieee.std_logic_1164.all;

entity fpu_tb is
end fpu_tb;

architecture behavioral of fpu_tb is

component fpu 
    port (
        clk_i       	: in std_logic;
        opa_i       	: in std_logic_vector(31 downto 0);   
        opb_i       	: in std_logic_vector(31 downto 0);
        fpu_op_i		: in std_logic_vector(2 downto 0);
        rmode_i 		: in std_logic_vector(1 downto 0);  
        output_o    	: out std_logic_vector(31 downto 0);
		ine_o 			: out std_logic;
        overflow_o  	: out std_logic;
        underflow_o 	: out std_logic;
        div_zero_o  	: out std_logic;
        inf_o			: out std_logic;
        zero_o			: out std_logic;
        qnan_o			: out std_logic;
        snan_o			: out std_logic;
        start_i	  		: in  std_logic;
        ready_o 		: out std_logic;
		altb_o			: out std_logic;
		blta_o			: out std_logic;
		aeqb_o			: out std_logic;
		cmp_unordered_o	: out std_logic;
		cmp_inf_o		: out std_logic;
		cmp_zero_o		: out std_logic
	);   
end component;

signal clock									: std_logic := '1';
signal fpu_op									: std_logic_vector(2 downto 0);
signal rmode									: std_logic_vector(1 downto 0);
signal opa, opb	    							: std_logic_vector(31 downto 0);
signal output									: std_logic_vector(31 downto 0);
signal start									: std_logic := '0';
signal ready									: std_logic;
signal altb, blta, aeqb							: std_logic;

begin
	
    i_fpu: fpu
		port map (
				clk_i => clock,
				opa_i => opa,
				opb_i => opb,
				fpu_op_i => fpu_op,
				rmode_i =>  rmode,
				output_o => output,
				start_i => start,
				ready_o => ready,
				ine_o => open,
				overflow_o => open,
				underflow_o => open,
				div_zero_o => open,
				inf_o => open,
				zero_o => open,
				qnan_o => open,
				snan_o => open,
				altb_o => altb,
				blta_o => blta,
				aeqb_o => aeqb,
				cmp_unordered_o => open,
				cmp_inf_o => open,
				cmp_zero_o => open
				);
	
	clock <= not(clock) after 5 ns;
	
    tb : process
	
    begin
	
		opa <= "00000000000000000000000000000000";
		opb <= "00000000000000000000000000000000";
		fpu_op <= "000";
		rmode <= "00";		
		start <= '0';
		
		wait for 10 ns;
		
		-- 3 - 2 = 1
		opa <= "01000000010000000000000000000000";
		opb <= "01000000000000000000000000000000";
		fpu_op <= "001";	
		start <= '1';
		
		wait for 10 ns;
		
		start <= '0';
		
		wait for 90 ns;
		
		-- 3 * 2 = 3
		fpu_op <= "010";
		start <= '1';
		
		wait for 10 ns;
		
		start <= '0';
		
		wait for 140 ns;
		
		-- 3 / 2 = 1.5
		fpu_op <= "011";	
		start <= '1';
		
		wait for 10 ns;
		
		start <= '0';
		
		wait for 360 ns;
		
		-- 3 ? 2 = altb
		fpu_op <= "100";
		start <= '1';
		
		wait for 10 ns;
		
		start <= '0';
				
    	wait;

    end process tb;

end behavioral;