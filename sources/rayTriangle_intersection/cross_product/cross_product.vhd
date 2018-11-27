---------------
-- DATA PATH --
---------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.rayTracing_pkg.all;

entity cross_product is
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
		fpu_i        : in fpu_i_t;                       --Control and Data from fpu.
		fpu_o        : out fpu_o_t                      --Control and Data to fpu.
    );
end cross_product;

architecture behavioral of cross_product is

	-- FMS states
	type state_t is (WAIT_S, MUL_L_X_S, MUL_R_X_S, SUB_LR_X_S, MUL_L_Y_S, MUL_R_Y_S, SUB_LR_Y_S, MUL_L_Z_S, MUL_R_Z_S, SUB_LR_Z_S, DONE_S);
	-- Estado WAIT_S salva vecA_i e vecB_i em dois registradores 
	-- Estado MUL_L_S multiplica a parte esquerda da função
	-- Estado MUL_R_S multiplica a parte direita da função
	-- Estado SUB_LR_S que subtrai a parte Right da Left.
	-- 
	-- a[0] = x , a[1] = y , a[2] = z
	-- b[0] = x , b[1] = y , b[3] = z
	
	-- CurrentState
	signal CurrentState_s	: 	state_t;
	
	-- Input Vectors_registers
	signal vecA_s, vecB_s	:	vector3D_t;

	-- Aux Registers
	signal auxL_s, auxR_s	:	data_t;


begin

	-- Global Process
	process(clk, rst) 
	begin
		-- Reset 
		if (rst = '1') then 
			CurrentState_s 	<= WAIT_S;
			vecA_s 			<= VECTOR3D_RESET_ZERO;
			vecB_s 			<= VECTOR3D_RESET_ZERO;
			result_o        <= VECTOR3D_RESET_ZERO;
			auxL_s 			<= DATA_RESET_ZERO;
			auxR_s 			<= DATA_RESET_ZERO;
		
		-- Clock
		elsif rising_edge(clk) then

			-- States (FSM)
			case CurrentState_s is

				-- Wait a master signal to start. 
				when WAIT_S => 
					-- Mas need FPU to operate? 
					if start_i = '1' then 
						CurrentState_s <= MUL_L_X_S; 
						vecA_s <= vecA_i;
						vecB_s <= vecB_i;
					else 
						CurrentState_s <= WAIT_S;  
					end if; 

				-- Set the start_o, to reset FPU
				when MUL_L_X_S => 
					if fpu_i.ready = '1' then
						CurrentState_s  <= MUL_R_X_S;
						auxL_s			<= fpu_i.result;
					else 
						CurrentState_s	<= MUL_L_X_S; 
					end if; 

				-- Set the start_o to reset FPU
				when MUL_R_X_S =>
					if fpu_i.ready = '1' then
						CurrentState_s 	<= SUB_LR_X_S;
						auxR_s			<= fpu_i.result;
					else 
						CurrentState_s	<= MUL_R_X_S;
					end if;

				-- Set the start_o to reset FPU
				when SUB_LR_X_S =>
					if fpu_i.ready = '1' then
						CurrentState_s	<= MUL_L_Y_S;
						result_o.x		<= fpu_i.result;
					else
						CurrentState_s	<= SUB_LR_X_S;
					end if;

				-- Set the start_o, to reset FPU
				when MUL_L_Y_S => 
					if fpu_i.ready = '1' then
						CurrentState_s  <= MUL_R_Y_S;
						auxL_s			<= fpu_i.result;
					else 
						CurrentState_s	<= MUL_L_Y_S; 
					end if; 
					
				-- Set the start_o to reset FPU
				when MUL_R_Y_S =>
					if fpu_i.ready = '1' then
						CurrentState_s 	<= SUB_LR_Y_S;
						auxR_s			<= fpu_i.result;
					else 
						CurrentState_s	<= MUL_R_Y_S;
					end if;

				-- Set the start_o to reset FPU
				when SUB_LR_Y_S =>
					if fpu_i.ready = '1' then
						CurrentState_s	<= MUL_L_Z_S;
						result_o.y		<= fpu_i.result;
					else
						CurrentState_s	<= SUB_LR_Y_S;
					end if;

				-- Set the start_o, to reset FPU
				when MUL_L_Z_S => 
					if fpu_i.ready = '1' then
						CurrentState_s  <= MUL_R_Z_S;
						auxL_s			<= fpu_i.result;
					else 
						CurrentState_s	<= MUL_L_Z_S; 
					end if;

				-- Set the start_o, to reset FPU	
				when MUL_R_Z_S =>
					if fpu_i.ready = '1' then
						CurrentState_s 	<= SUB_LR_Z_S;
						auxR_s			<= fpu_i.result;
					else 
						CurrentState_s	<= MUL_R_Z_S;
					end if; 

				-- Set the start_o to reset FPU
				when SUB_LR_Z_S =>
					if fpu_i.ready = '1' then
						CurrentState_s	<= DONE_S;
						result_o.z		<= fpu_i.result;
					else
						CurrentState_s	<= SUB_LR_Z_S;
					end if;
					
				-- DONE_S
				when OTHERS =>
						CurrentState_s 	<= WAIT_S;
			end case;
		end if;
	end process;

	-- External signals.
	-- DONE
	done_o 		<= '1' when CurrentState_s = DONE_S else '0';

	-- FPU
	fpu_o.a	<= vecA_s.x when CurrentState_S = MUL_R_Y_S or CurrentState_S = MUL_L_Z_S else 
				   vecA_s.y when CurrentState_S = MUL_L_X_S or CurrentState_S = MUL_R_Z_S else
				   vecA_s.z when CurrentState_S = MUL_R_X_S or CurrentState_S = MUL_L_Y_S else
				   auxL_s;
	
	fpu_o.b	<= vecB_s.x when CurrentState_S = MUL_L_Y_S or CurrentState_S = MUL_R_Z_S else
				   vecB_s.y when CurrentState_S = MUL_R_X_S or CurrentState_S = MUL_L_Z_S else
				   vecB_s.z when CurrentState_S = MUL_L_X_S or CurrentState_S = MUL_R_Y_S else
				   auxR_s;

	fpu_o.op <= FPU_SUB when CurrentState_S = SUB_LR_X_S or CurrentState_S = SUB_LR_Y_S or CurrentState_S = SUB_LR_Z_S else FPU_MUL;
	
	fpu_o.start <= '0' when CurrentState_s = WAIT_S or CurrentState_s = DONE_S else '1';

end behavioral;