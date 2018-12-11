
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.rayTracing_pkg.all;
use std.textio.all;
use ieee.std_logic_textio.all;

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
	
	--Component
	component rayTriangle_intersection
    port (  
        clk           : in  std_logic;                 -- Clock
        rst           : in  std_logic;                 -- Reset
        
        -- CONTROL
        data_av_i     : in  std_logic;                 -- Data is available
        done_o        : out std_logic;                 -- Operation is DONE
		collision_o   : out std_logic;                 -- Occurred or not a collision.

		-- DATA
		data_i        : in  data_t;                    -- Data   input
		result_o      : out data_t                     -- Result output
    );
	end component;
	
begin

	-- Generate clk and rst;
	clk <= not clk after 5 ns;
	rst <= '0' after 10.1 ns;

	DUV: rayTriangle_intersection port map (clk, rst, data_av_i, done_o, collision_o, data_i, result_o);
		
	-- Generate others stimuli
	process
	begin
		data_av_i <= '0';
		data_i <= (OTHERS=> '0');
		wait until falling_edge(clk);
		
		data_i <= x"BF2F6B22"; -- OX
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"BEFFF2E5"; -- OY
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3FBBE29A"; -- OZ
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3ED0F0E3"; -- DX
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3ECA222F"; -- DY
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"BF52BB0F"; -- DZ
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"BDCCCCCD"; -- V0X
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"00000000"; -- V0Y
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3E4CCCCD"; -- V0Z
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3ECCCCCD"; -- V1X
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"00000000"; -- V1Y
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"BE4CCCCD"; -- V1Z
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3E19999A"; -- V2X
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"3ECCCCCD"; -- V2Y
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_i <= x"BDCCCCCD"; -- V2Z
		data_av_i <= '1';
		wait until falling_edge(clk);
		
		data_av_i <= '0';
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		data_av_i <= '1';
		wait until falling_edge(clk);
		data_av_i <= '0';
		wait until done_o = '1';
		
		report "Terminou!!!" severity note;
		wait;
		
	end process;
	
end test;

architecture test_file of rayTriangle_intersection_tb is

	--Files
	constant inputFileName  : string := "in_100.txt";
	constant outputFileName : string := "out.txt";

	--Signals
	signal clk, rst    : std_logic := '1';
	signal data_av_i   : std_logic;
	signal done_o      : std_logic;
	signal collision_o : std_logic;
	signal data_i      : data_t;
	signal result_o    : data_t;
	
	--Line count
	signal line_count  : integer;
	
	--Component
	component rayTriangle_intersection
    port (  
        clk           : in  std_logic;                 -- Clock
        rst           : in  std_logic;                 -- Reset
        
        -- CONTROL
        data_av_i     : in  std_logic;                 -- Data is available
        done_o        : out std_logic;                 -- Operation is DONE
		collision_o   : out std_logic;                 -- Occurred or not a collision.

		-- DATA
		data_i        : in  data_t;                    -- Data   input
		result_o      : out data_t                     -- Result output
    );
	end component;
	
begin

	-- Generate clk and rst;
	clk <= not clk after 2 ns;

	DUV: rayTriangle_intersection port map (clk, rst, data_av_i, done_o, collision_o, data_i, result_o);
		
	-- Generate others stimuli from file.
	process
		--FILES
		FILE inFile : text;
		FILE outFile  : text;
		
		--LINES
		variable inLine  : line;
		variable outLine : line;
		
		--Vector and results.
		variable O, D,V0, V1, V2 : vector3D_t;
		variable result_circ, result_f : data_t;
		variable coll   : std_logic;
		
		--Counters
		variable correct_c, wrong_c, nInf_wrong_c : integer;
		--Bit error
		variable w_0b_c, w_1b_c, w_2b_c, w_3b_c, w_4b_c, w_5b_c, w_6b_c, w_7b_c, w_more8b_c : integer;
	begin
		--Reset DUV.
		rst <= '1';
		O  := VECTOR3D_RESET_ZERO;
		D  := VECTOR3D_RESET_ZERO;
		V0 := VECTOR3D_RESET_ZERO;
		V1 := VECTOR3D_RESET_ZERO;
		V2 := VECTOR3D_RESET_ZERO;
		data_i <= (OTHERS=>'0');
		data_av_i <= '0';
		correct_c := 0;
		wrong_c := 0;
		nInf_wrong_c := 0;
		w_0b_c := 0; w_1b_c := 0; w_2b_c := 0; w_3b_c := 0; 
		w_4b_c := 0; w_5b_c := 0; w_6b_c := 0; w_7b_c := 0; 
		w_more8b_c := 0;
		line_count <= 0;
		--Open files
		FILE_OPEN(inFile, inputFileName, READ_MODE);
		FILE_OPEN(outFile, outputFileName, WRITE_MODE);
			
		--Wait a clk
		wait until falling_edge(clk);
		--Enable the DUV and wait a clk.
		rst <= '0';
		
		--Loop over the input file.
		while not endfile(inFile) loop
			--Read a line
			readline(inFile, inLine);
			--Read the arguments.
			--O
				hread(inLine, O.x);
				hread(inLine, O.y);
				hread(inLine, O.z);
			--D
				hread(inLine, D.x);
				hread(inLine, D.y);
				hread(inLine, D.z);
			--V0
				hread(inLine, V0.x);
				hread(inLine, V0.y);
				hread(inLine, V0.z);
			--V1
				hread(inLine, V1.x);
				hread(inLine, V1.y);
				hread(inLine, V1.z);
			--V2
				hread(inLine, V2.x);
				hread(inLine, V2.y);
				hread(inLine, V2.z);
			wait until falling_edge(clk);
			
			--Send the arguments.
			data_i <= O.x; -- OX
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= O.y; -- OY
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= O.z; -- OZ
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= D.x; -- DX
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= D.y; -- DY
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= D.z; -- DZ
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V0.x; -- V0X
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V0.y; -- V0Y
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V0.z; -- V0Z
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V1.x; -- V1X
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V1.y; -- V1Y
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V1.z; -- V1Z
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V2.x; -- V2X
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V2.y; -- V2Y
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_i <= V2.z; -- V2Z
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_av_i <= '0';
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			
			data_av_i <= '1';
			wait until falling_edge(clk);
			
			data_av_i <= '0';
			
			--Wait circuit calculate.
			wait until done_o = '1';
			wait until falling_edge(clk);
			
			result_circ := result_o;
			coll := collision_o;
			
			--Read result from file.
			hread(inLine, result_f);
			
			--Simple test
			if result_circ /= result_f then --or (coll = '1' and result_circ(31 downto 5) /= result_f(31 downto 5))
				wrong_c := wrong_c + 1;
				if coll = '1' then
					nInf_wrong_c := nInf_wrong_c + 1;
				end if;
				
				if result_circ(31 downto 8) /= result_f(31 downto 8) then
					w_more8b_c := w_more8b_c + 1;
				elsif result_circ(31 downto 7) /= result_f(31 downto 7) then
					w_7b_c := w_7b_c + 1;
				elsif result_circ(31 downto 6) /= result_f(31 downto 6) then
					w_6b_c := w_6b_c + 1;
				elsif result_circ(31 downto 5) /= result_f(31 downto 5) then
					w_5b_c := w_5b_c + 1;
				elsif result_circ(31 downto 4) /= result_f(31 downto 4) then
					w_4b_c := w_4b_c + 1;
				elsif result_circ(31 downto 3) /= result_f(31 downto 3) then
					w_3b_c := w_3b_c + 1;
				elsif result_circ(31 downto 2) /= result_f(31 downto 2) then
					w_2b_c := w_2b_c + 1;
				elsif result_circ(31 downto 1) /= result_f(31 downto 1) then
					w_1b_c := w_1b_c + 1;
				else
					w_0b_c := w_0b_c + 1;
				end if;
					
			else
				--Certo
				correct_c := correct_c + 1;
			end if;
			--Write the result.
			hwrite(outLine, result_circ);
			writeline(outFile, outLine);
			line_count <= line_count + 1;
			wait until falling_edge(clk);
		end loop;
		
		--End of file. Print the results and stop the simulation
		report "Total calculations: " & integer'image(correct_c + wrong_c);
		report "Correct results: " & integer'image(correct_c);
		report "Wrong results: " & integer'image(wrong_c);
		report "Not Inf Wrong results: " & integer'image(nInf_wrong_c);
		report "Wrong bit(0) results: " & integer'image(w_0b_c);
		report "Wrong bit(1) results: " & integer'image(w_1b_c);
		report "Wrong bit(2) results: " & integer'image(w_2b_c);
		report "Wrong bit(3) results: " & integer'image(w_3b_c);
		report "Wrong bit(4) results: " & integer'image(w_4b_c);
		report "Wrong bit(5) results: " & integer'image(w_5b_c);
		report "Wrong bit(6) results: " & integer'image(w_6b_c);
		report "Wrong bit(7) results: " & integer'image(w_7b_c);
		report "Wrong bit(>=8) results: " & integer'image(w_more8b_c);
		report "END!!!" severity failure;
		wait;
	end process;
	
end test_file;

