
library IEEE;
use IEEE.std_logic_1164.all;
use work.rayTracing_pkg.all;

entity dot_product is
    port (  
        clk           : in  std_logic;                     -- Clock
        rst           : in  std_logic;                     -- Reset
        
        -- CONTROL_MASTER
        start_i       : in  std_logic;                     -- Start the operation (sub_vec)
        done_o        : out std_logic;                     -- Operation is DONE   (sub_vec)   

		-- DATA_MASTER
		vecA_i        : in  vector3D_t;                    -- Vector_A
		vecB_i        : in  vector3D_t;                    -- Vector_B
		result_o      : out data_t;                        -- Vector_A . Vector_B
		
		-- FPU
		fpu_i        : in fpu_i_t;                       --Control and Data from fpu.
		fpu_o        : out fpu_o_t                      --Control and Data to fpu.
    );
end dot_product;

architecture behavioral of dot_product is
    
	-- FMS states
	type state_t is (WAIT_S, MUL_X_S, MUL_Y_S, ADD_XY_S, MUL_Z_S, ADD_XYZ_S, DONE_S);
	
	-- CurrentState
	signal CurrentState_s : state_t;
	
	-- Input Vectors_registers
	signal vecA_s, vecB_s : vector3D_t;
	
	-- Output register
	signal result_s       : data_t;
	
	-- Aux register
	signal aux_s          : data_t;
	
begin
	
	-- Result is the exit of result_s register;
	result_o <= result_s;
	
    --Global Process
	process(clk, rst)
	begin
		--Reset
		if rst = '1' then
			CurrentState_s <= WAIT_S;
			vecA_s   <= VECTOR3D_RESET_ZERO;
			vecB_s   <= VECTOR3D_RESET_ZERO;
			result_s <= DATA_RESET_ZERO;
			aux_s    <= DATA_RESET_ZERO;
		
		--Clock
		elsif rising_edge(clk) then
			
			--States (FSM)
			case CurrentState_s is
			
				-- Wait a master signal to start.
				when WAIT_S =>
					-- Master need FPU to operate?
					if start_i = '1' then
						CurrentState_s <= MUL_X_S;
						vecA_s <= vecA_i;
						vecB_s <= vecB_i;
					else
						CurrentState_s <= WAIT_S;
					end if;
				
			    -- Set the start_o, to reset FPU.
				when MUL_X_S  =>
					if fpu_i.ready = '1' then
						CurrentState_s <= MUL_Y_S;
						result_s <= fpu_i.result;
					else
						CurrentState_s <= MUL_X_S;
					end if;
						
			    -- Set the start_o, to reset FPU.
				when MUL_Y_S  =>
					if fpu_i.ready = '1' then
						CurrentState_s <= ADD_XY_S;
						aux_s <= fpu_i.result;
					else
						CurrentState_s <= MUL_Y_S;
					end if;
						
			    -- Set the start_o, to reset FPU.
				when ADD_XY_S  =>
					if fpu_i.ready = '1' then
						CurrentState_s <= MUL_Z_S;
						result_s <= fpu_i.result;
					else
						CurrentState_s <= ADD_XY_S;
					end if;

			    -- Set the start_o, to reset FPU.
				when MUL_Z_S  =>
					if fpu_i.ready = '1' then
						CurrentState_s <= ADD_XYZ_S;
						aux_s <= fpu_i.result;
					else
						CurrentState_s <= MUL_Z_S;
					end if;

			    -- Set the start_o, to reset FPU.
				when ADD_XYZ_S  =>
					if fpu_i.ready = '1' then
						CurrentState_s <= DONE_S;
						result_s <= fpu_i.result;
					else
						CurrentState_s <= ADD_XYZ_S;
					end if;
				
				--DONE_S.
				when OTHERS  =>
					CurrentState_s <= WAIT_S;
					
			end case;
		end if;
	end process;
	
	-- External signals.
	-- DONE
	done_o <= '1' when CurrentState_s = DONE_S else '0';
	
	-- FPU
	fpu_o.a     <= vecA_s.x when CurrentState_s = MUL_X_S else
					  vecA_s.y when CurrentState_s = MUL_Y_S else
					  vecA_s.z when CurrentState_s = MUL_Z_S else
					  result_s;
					  
	fpu_o.b     <= vecB_s.x when CurrentState_s = MUL_X_S else
					  vecB_s.y when CurrentState_s = MUL_Y_S else
					  vecB_s.z when CurrentState_s = MUL_Z_S else
					  aux_s;
					  
	fpu_o.op    <= FPU_ADD  when CurrentState_s = ADD_XY_S or CurrentState_s = ADD_XYZ_S else FPU_MUL;
	
	fpu_o.start <= '0' when CurrentState_s = WAIT_S or CurrentState_s = DONE_S else '1';
	    
end behavioral;