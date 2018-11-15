
library IEEE;
use IEEE.std_logic_1164.all;
use work.rayTracing_pkg.all;

entity sub_vector is
    port (  
        clk           : in  std_logic;                     -- Clock
        rst           : in  std_logic;                     -- Reset
        
        -- CONTROL_MASTER
        start_i       : in  std_logic;                     -- Start the operation (sub_vec)
        done_o        : out std_logic;                     -- Operation is DONE   (sub_vec)   

		-- DATA_MASTER
		vecA_i        : in  vector3D_t;                    -- Vector_A
		vecB_i        : in  vector3D_t;                    -- Vector_B
		result_o      : out vector3D_t;                    -- Vector_A - Vector_B
		
		-- FPU
		fpu_io        : inout fpu_t                       --Control and Data to/from fpu.
    );
end sub_vector;

architecture behavioral of sub_vector is
    
	-- FMS states
	type state_t is (WAIT_S, SUB_X_S, SUB_Y_S, SUB_Z_S, DONE_S);
	
	-- CurrentState
	signal CurrentState_s : state_t;
	
	-- Input Vectors_registers
	signal vecA_s, vecB_s : vector3D_t;
	
begin
	
    --Global Process
	process(clk, rst)
	begin
		--Reset
		if rst = '1' then
			CurrentState_s <= WAIT_S;
			vecA_s   <= VECTOR3D_RESET_ZERO;
			vecB_s   <= VECTOR3D_RESET_ZERO;
			result_o <= VECTOR3D_RESET_ZERO;
		
		--Clock
		elsif rising_edge(clk) then
			
			--States (FSM)
			case CurrentState_s is
			
				-- Wait a master signal to start.
				when WAIT_S =>
					-- Master need FPU to operate?
					if start_i = '1' then
						CurrentState_s <= SUB_X_S;
						vecA_s <= vecA_i;
						vecB_s <= vecB_i;
					else
						CurrentState_s <= WAIT_S;
					end if;
				
			    -- Subtract x dimension.
				when SUB_X_S  =>
					if fpu_io.ready_o = '1' then
						CurrentState_s <= SUB_Y_S;
						result_o.x <= fpu_io.result_o;
					else
						CurrentState_s <= SUB_X_S;
					end if;
					
				-- Subtract y dimension.
				when SUB_Y_S  =>
					if fpu_io.ready_o = '1' then
						CurrentState_s <= SUB_Z_S;
						result_o.y <= fpu_io.result_o;
					else
						CurrentState_s <= SUB_Y_S;
					end if;

				-- Subtract z dimension.
				when SUB_Z_S  =>
					if fpu_io.ready_o = '1' then
						CurrentState_s <= DONE_S;
						result_o.z <= fpu_io.result_o;
					else
						CurrentState_s <= SUB_Z_S;
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
	fpu_io.a_i     <= vecA_s.x when CurrentState_s = SUB_X_S else
					  vecA_s.y when CurrentState_s = SUB_Y_S else
					  vecA_s.z;
					  
	fpu_io.b_i     <= vecB_s.x when CurrentState_s = SUB_X_S else
					  vecB_s.y when CurrentState_s = SUB_Y_S else
					  vecB_s.z;
					  
	fpu_io.op_i    <= FPU_SUB;
	
	fpu_io.start_i <= '1' when CurrentState_s = SUB_X_S or CurrentState_s = SUB_Y_S or CurrentState_s = SUB_Z_S else '0';
	    
end behavioral;