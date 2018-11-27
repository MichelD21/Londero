
library IEEE;
use IEEE.std_logic_1164.all;
use work.rayTracing_pkg.all;

entity rayTriangle_intersection is
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
end rayTriangle_intersection;

architecture behavioral of rayTriangle_intersection is
    
	-- FPU Component
	component fpu 
		port (
			clk_i : in std_logic; opa_i : in std_logic_vector(31 downto 0); opb_i : in std_logic_vector(31 downto 0);
			fpu_op_i : in std_logic_vector(2 downto 0); rmode_i : in std_logic_vector(1 downto 0); output_o : out std_logic_vector(31 downto 0);
			ine_o : out std_logic; overflow_o : out std_logic; underflow_o : out std_logic; div_zero_o : out std_logic; inf_o : out std_logic;
			zero_o : out std_logic; qnan_o : out std_logic; snan_o : out std_logic; start_i : in  std_logic; ready_o : out std_logic;
			altb_o : out std_logic; blta_o : out std_logic; aeqb_o : out std_logic; cmp_unordered_o	: out std_logic; cmp_inf_o : out std_logic;
			cmp_zero_o : out std_logic
		);   
	end component;
	
	-- CROSS_PRODUCT Component
	--component cross_product
	--	port (
	--		clk : in std_logic; rst : in std_logic; start_i : in std_logic; done_o : out std_logic; vecA_i : in  vector3D_t;
	--		vecB_i : in vector3D_t; result_o : out vector3D_t; fpu_i : in fpu_i_t; fpu_o : out fpu_o_t
	--	);
	--end component;

	-- DOT_PRODUCT Component
	component dot_product
		port (  
        		clk : in std_logic; rst : in std_logic; start_i : in std_logic; done_o : out std_logic;	vecA_i : in vector3D_t;
			vecB_i : in vector3D_t; result_o : out data_t; fpu_i : in fpu_i_t; fpu_o : out fpu_o_t
		);
	end component;

	-- SUB_VECTOR Component
	component sub_vector
		port (
			clk : in std_logic; rst : in std_logic; start_i : in std_logic; done_o : out std_logic; vecA_i : in vector3D_t;
			vecB_i : in vector3D_t; result_o : out vector3D_t; fpu_i : in fpu_i_t; fpu_o : out fpu_o_t
		);
	end component;

	component fpu_starter
		port (
			clk : in std_logic; rst : in std_logic; start_i : in std_logic; ready_i : in std_logic; start_o : out std_logic
		);
	end component;
	
	-- FMS states
	type state_t is (WAIT_OX_S, WAIT_OY_S, WAIT_OZ_S, WAIT_DX_S, WAIT_DY_S, WAIT_DZ_S, WAIT_V0X_S, WAIT_V0Y_S, WAIT_V0Z_S, WAIT_V1X_S, WAIT_V1Y_S, WAIT_V1Z_S, WAIT_V2X_S, WAIT_V2Y_S, WAIT_V2Z_S, WAIT_START_S, EDGE1_S, EDGE2_S, H_S, A_S, IF1_A_S, F_S, S_S, U_DOT_S, U_S, IF2_U1_S, Q_S, V_DOT_S, V_S, IF3_V0_S, ADD_UV_S, IF3_UV1_S, T_DOT_S, T_S, IF4_T_S, DONE_S);
	
	-- CurrentState_s
	signal CurrentState_s : state_t;
	
	-- Input Vectors registers
	signal rayO_s, rayD_s, triV0_s, triV1_s, triV2_s : vector3D_t;
	
	-- Aux Vectors registers
	signal vecEdge1_s, vecEdge2_s, vecH_s, vecS_s, vecQ_s : vector3D_t;
	
	-- Aux Data registers
	signal regA_s, regU_s, regV_s : data_t;
	
	-- FPU connection
	signal fpu_i_s     : fpu_o_t; --Input of FPU, output of top.
	signal fpu_o_s     : fpu_i_t; --Output of FPU, input of top.
	
	-- rayTriangle_intersection(top) fpu signals.
	signal top_fpu_s  : fpu_o_t;
	signal regA_mod_s : data_t;
	
	-- Cross_Product connection
	signal crossP_s  : subCirc_vivo_t;
	
	-- Dot_Product   connection
	signal dotP_s    : subCirc_vido_t;
	
	-- Sub_Vector    connection
	signal subVec_s  : subCirc_vivo_t;
	
	-- FPU_Starter   connection
	signal fpu_start : std_logic;
	
begin
	
    --Global Process
	process(clk, rst)
	begin
		--Reset
		if rst = '1' then
			-- State
			CurrentState_s <= WAIT_OX_S;
			-- Inputs
			rayO_s         <= VECTOR3D_RESET_ZERO;
			rayD_s         <= VECTOR3D_RESET_ZERO;
			triV0_s        <= VECTOR3D_RESET_ZERO;
			triV1_s        <= VECTOR3D_RESET_ZERO;
			triV2_s        <= VECTOR3D_RESET_ZERO;
			-- Aux Vecs
			vecEdge1_s     <= VECTOR3D_RESET_ZERO;
			vecEdge2_s     <= VECTOR3D_RESET_ZERO;
			vecH_s         <= VECTOR3D_RESET_ZERO;
			vecS_s         <= VECTOR3D_RESET_ZERO;
			vecQ_s         <= VECTOR3D_RESET_ZERO;
			-- Aux Datas
			regA_s         <= DATA_RESET_ZERO;
			regU_s         <= DATA_RESET_ZERO;
			regV_s         <= DATA_RESET_ZERO;
			--Reset Outputs
			result_o       <= DATA_RESET_ZERO;
			collision_o    <= '0';
		
		--Clock
		elsif rising_edge(clk) then
			
			--States (FSM)
			case CurrentState_s is
			
				-- Wait a new data to rayO_s.x
				when WAIT_OX_S =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_OY_S;
						rayO_s.x <= data_i;
					else
						CurrentState_s <= WAIT_OX_S;
					end if;
				
			    -- Wait a new data to rayO_s.y
				when WAIT_OY_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_OZ_S;
						rayO_s.y <= data_i;
					else
						CurrentState_s <= WAIT_OY_S;
					end if;
						
			    -- Wait a new data to rayO_s.z
				when WAIT_OZ_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_DX_S;
						rayO_s.z <= data_i;
					else
						CurrentState_s <= WAIT_OZ_S;
					end if;
					
			    -- Wait a new data to rayD_s.x
				when WAIT_DX_S =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_DY_S;
						rayD_s.x <= data_i;
					else
						CurrentState_s <= WAIT_DX_S;
					end if;
				
			    -- Wait a new data to rayD_s.y
				when WAIT_DY_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_DZ_S;
						rayD_s.y <= data_i;
					else
						CurrentState_s <= WAIT_DY_S;
					end if;
						
			   -- Wait a new data to rayD_s.z
				when WAIT_DZ_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V0X_S;
						rayD_s.z <= data_i;
					else
						CurrentState_s <= WAIT_DZ_S;
					end if;
				
			    -- Wait a new data to triV0_s.x
				when WAIT_V0X_S =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V0Y_S;
						triV0_s.x <= data_i;
					else
						CurrentState_s <= WAIT_V0X_S;
					end if;
				
			    -- Wait a new data to triV0_s.y
				when WAIT_V0Y_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V0Z_S;
						triV0_s.y <= data_i;
					else
						CurrentState_s <= WAIT_V0Y_S;
					end if;
						
			    -- Wait a new data to rtriV0_s.z
				when WAIT_V0Z_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V1X_S;
						triV0_s.z <= data_i;
					else
						CurrentState_s <= WAIT_V0Z_S;
					end if;

			    -- Wait a new data to triV1_s.x
				when WAIT_V1X_S =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V1Y_S;
						triV1_s.x <= data_i;
					else
						CurrentState_s <= WAIT_V1X_S;
					end if;
				
			    -- Wait a new data to triV1_s.y
				when WAIT_V1Y_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V1Z_S;
						triV1_s.y <= data_i;
					else
						CurrentState_s <= WAIT_V1Y_S;
					end if;
						
			    -- Wait a new data to triV1_s.z
				when WAIT_V1Z_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V2X_S;
						triV1_s.z <= data_i;
					else
						CurrentState_s <= WAIT_V1Z_S;
					end if;

			    -- Wait a new data to triV2_s.x
				when WAIT_V2X_S =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V2Y_S;
						triV2_s.x <= data_i;
					else
						CurrentState_s <= WAIT_V2X_S;
					end if;
				
			    -- Wait a new data to triV2_s.y
				when WAIT_V2Y_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_V2Z_S;
						triV2_s.y <= data_i;
					else
						CurrentState_s <= WAIT_V2Y_S;
					end if;
						
			    -- Wait a new data to triV2_s.z
				when WAIT_V2Z_S  =>
					-- Wait data_av_i to get the data.
					if data_av_i = '1' then
						CurrentState_s <= WAIT_START_S;
						triV2_s.z <= data_i;
					else
						CurrentState_s <= WAIT_V2Z_S;
					end if;

				-- Wait a new data_av_i to be a start in the calculation
				when WAIT_START_S  =>
					-- Wait data_av_i to start.
					if data_av_i = '1' then
						CurrentState_s <= EDGE1_S;
					else
						CurrentState_s <= WAIT_START_S;
					end if;

			    -- Calculate the edge1 side.
				when EDGE1_S  =>
					-- Wait done to get the data.
					if subVec_s.done_o = '1' then
						CurrentState_s <= EDGE2_S;
						vecEdge1_s <= subVec_s.result_o;
					else
						CurrentState_s <= EDGE1_S;
					end if;

				-- Calculate the edge2 side.
				when EDGE2_S  =>
					-- Wait done to get the data.
					if subVec_s.done_o = '1' then
						CurrentState_s <= H_S;
						vecEdge2_s <= subVec_s.result_o;
					else
						CurrentState_s <= EDGE2_S;
					end if;

			    -- Calcuoate the cross to h 
				when H_S  =>
					-- Wait done to get the data.
					if crossP_s.done_o = '1' then
						CurrentState_s <= A_S;
						vecH_s <= crossP_s.result_o;
					else
						CurrentState_s <= H_S;
					end if;

				-- Calculate the dot to a.
				when A_S  =>
					-- Wait done to get the data.
					if dotP_s.done_o = '1' then
						CurrentState_s <= IF1_A_S;
						regA_s <= dotP_s.result_o;
					else
						CurrentState_s <= A_S;
					end if;

				-- Campare a with EPSILON
				when IF1_A_S  =>
					-- |A| >= EPSILON
					if fpu_o_s.ready = '1' and fpu_o_s.altb = '0' then
						CurrentState_s <= F_S;
					-- |A| < EPSILON
					elsif fpu_o_s.ready = '1' and fpu_o_s.altb = '1' then
						CurrentState_s <= DONE_S;
						result_o       <= CTE_INF;
						collision_o    <= '0';
					else
						CurrentState_s <= IF1_A_S;
					end if;

				-- Calculate f = 1/a
				when F_S  =>
					-- Wait done to get the data.
					if fpu_o_s.ready = '1' then
						CurrentState_s <= S_S;
						regA_s <= fpu_o_s.result;
					else
						CurrentState_s <= F_S;
					end if;

				-- calculate s = O - V0
				when S_S  =>
					-- Wait done to get the data.
					if subVec_s.done_o = '1' then
						CurrentState_s <= U_DOT_S;
						vecS_s <= subVec_s.result_o;
					else
						CurrentState_s <= S_S;
					end if;

				-- Dot productof (s,h).
				when U_DOT_S  =>
					-- Wait done to get the data.
					if dotP_s.done_o = '1' then
						CurrentState_s <= U_S;
						regU_s <= dotP_s.result_o;
					else
						CurrentState_s <= U_DOT_S;
					end if;

				-- Calculate U = f * u_dot
				when U_S  =>
					-- Wait done to get the data.
					if fpu_o_s.ready = '1' then
						CurrentState_s <= IF2_U1_S;
						regU_s <= fpu_o_s.result;
					else
						CurrentState_s <= U_S;
					end if;

				-- Verify if  u >= 0 && u <= 1. u < 0 is the MSB. u > 1 is get from fpu.
				when IF2_U1_S  =>
					-- U >= 0 && U <= 1
					if fpu_o_s.ready = '1' and fpu_o_s.agtb = '0' and regU_s(FLOAT_WIDTH-1) = '0' then
						CurrentState_s <= Q_S;
					-- U < 0 || U > 1
					elsif fpu_o_s.ready = '1' and (fpu_o_s.agtb = '1' or regU_s(FLOAT_WIDTH-1) = '1') then
						CurrentState_s <= DONE_S;
						result_o <= CTE_INF;
						collision_o <= '0';
					else
						CurrentState_s <= IF2_U1_S;
					end if;

				-- CrossP (s, edge1)
				when Q_S  =>
					-- Wait done to get the data.
					if crossP_s.done_o = '1' then
						CurrentState_s <= V_DOT_S;
						vecQ_s <= crossP_s.result_o;
					else
						CurrentState_s <= Q_S;
					end if;

				-- V = dot(d,q);
				when V_DOT_S  =>
					-- Wait done to get the data.
					if dotP_s.done_o = '1' then
						CurrentState_s <= V_S;
						regV_s <= dotP_s.result_o;
					else
						CurrentState_s <= V_DOT_S;
					end if;

				-- V = f * v_dot
				when V_S  =>
					-- Wait ready from fpu.
					if fpu_o_s.ready = '1' then
						CurrentState_s <= IF3_V0_S;
						regV_s <= fpu_o_s.result;
					else
						CurrentState_s <= V_S;
					end if;

				-- Compare V < 0 or (U+V)>1
				when IF3_V0_S  =>
					-- V < 0? V < 0 is MSB.
					if regV_s(FLOAT_WIDTH-1) = '0' then
						CurrentState_s <= ADD_UV_S;
					else
						CurrentState_s <= DONE_S;
						result_o <= CTE_INF;
						collision_o <= '0';
					end if;

				-- Add u+v
				when ADD_UV_S  =>
					-- Wait ready from fpu.
					if fpu_o_s.ready = '1' then
						CurrentState_s <= IF3_UV1_S;
						regV_s <= fpu_o_s.result;
					else
						CurrentState_s <= ADD_UV_S;
					end if;

				-- Compare (u+v) > 1
				when IF3_UV1_S  =>
					-- (u+v) <= 1
					if fpu_o_s.ready = '1' and fpu_o_s.agtb = '0' then
						CurrentState_s <= T_DOT_S;
					-- u+v > 1
					elsif fpu_o_s.ready = '1' and fpu_o_s.agtb = '1' then
						CurrentState_s <= DONE_S;
						result_o <= CTE_INF;
						collision_o <= '0';
					else
						CurrentState_s <= IF3_UV1_S;
					end if;

				-- t = dot(edge2,q)
				when T_DOT_S  =>
					-- Wait done to get the data.
					if dotP_s.done_o = '1' then
						CurrentState_s <= T_S;
						regV_s <= dotP_s.result_o;
					else
						CurrentState_s <= T_DOT_S;
					end if;

				-- t = f * t
				when T_S  =>
					-- Wait done to get the data.
					if fpu_o_s.ready = '1' then
						CurrentState_s <= IF4_T_S;
						regV_s <= fpu_o_s.result;
					else
						CurrentState_s <= T_S;
					end if;	

				-- t > EPSILON?
				when IF4_T_S  =>
					-- t > EPSILON
					if fpu_o_s.ready = '1' and fpu_o_s.agtb = '1' then
						CurrentState_s <= DONE_S;
						result_o <= regV_s;
						collision_o <= '1';
					-- t <= EPSILON
					elsif fpu_o_s.ready = '1' and fpu_o_s.agtb = '0' then
						CurrentState_s <= DONE_S;
						result_o <= CTE_INF;
						collision_o <= '0';
					else
						CurrentState_s <= IF4_T_S;
					end if;						
				
				--DONE_S.
				when OTHERS  =>
					CurrentState_s <= WAIT_OX_S;
					
			end case;
		end if;
	end process;
	
	-- External signals.
	-- DONE
	done_o      <= '1' when CurrentState_s = DONE_S else '0';
	
	-- Generation of Cross_Product communication signals.
	crossP_s.start_i <= '1' when CurrentState_s = H_S or CurrentState_s = Q_S else '0';
	
	crossP_s.vecA_i  <= rayD_s when CurrentState_s = H_S else
						vecS_s;
						
	crossP_s.vecB_i  <= vecEdge2_s when CurrentState_s = H_S else
						vecEdge1_s;	
	
	
	-- Generation of Dot_Product communication signals.
	dotP_s.start_i <= '1' when CurrentState_s = A_S or CurrentState_s = U_DOT_S or CurrentState_s = V_DOT_S or CurrentState_s = T_DOT_S else '0';
	
	dotP_s.vecA_i  <= vecEdge1_s when CurrentState_s = A_S else
					  vecS_s     when CurrentState_s = U_DOT_S else
					  rayD_s     when CurrentState_s = V_DOT_S else
					  vecEdge2_s;
						
	dotP_s.vecB_i  <= vecH_s when CurrentState_s = A_S or CurrentState_s = U_DOT_S else
					  vecQ_s;
	
	-- Generation of Sub_Vector communication signals.
	subVec_s.start_i <= '1' when CurrentState_s = EDGE1_S or CurrentState_s = EDGE2_S or CurrentState_s = S_S  else '0';
	
	subVec_s.vecA_i  <= triV1_s when CurrentState_s = EDGE1_S else
					    triV2_s when CurrentState_s = EDGE2_S else
					    rayO_s;
						
	subVec_s.vecB_i  <= triV0_s;
	
	
	-- top_fpu_s generation
	top_fpu_s.start <= '1'  when CurrentState_s = IF1_A_S or CurrentState_s = F_S or CurrentState_s = U_S or CurrentState_s = IF2_U1_S or CurrentState_s = V_S or CurrentState_s = ADD_UV_S or CurrentState_s = IF3_UV1_S or CurrentState_s = T_S or CurrentState_s = IF4_T_S else '0';
	
	top_fpu_s.op    <= FPU_DIV  when CurrentState_s = F_S else
						 FPU_MUL  when CurrentState_s = U_S or CurrentState_s = V_S or CurrentState_s = T_S else
						 FPU_ADD  when CurrentState_s = ADD_UV_S else
						 FPU_CMP; --CurrentState_s = IF1_A_S or CurrentState_s = IF2_U1_S or CurrentState_s = IF3_UV1_S or IF4_T_S
	
	regA_mod_s      <= '0' & regA_s(FLOAT_WIDTH-2 downto 0);
	
	top_fpu_s.a     <= regA_mod_s when CurrentState_s = IF1_A_S else
						 CTE_ONE    when CurrentState_s = F_S else
						 regU_s     when CurrentState_s = U_S or CurrentState_s = IF2_U1_S or CurrentState_s = ADD_UV_S else
						 regV_s;    --CurrentState_s = V_S or CurrentState_s = IF3_UV1_S or CurrentState_s = T_S or CurrentState_s = IF4_T_S 
						 
	top_fpu_s.b     <= CTE_EPSILON when CurrentState_s = IF1_A_S or CurrentState_s = IF4_T_S else
						 CTE_ONE     when CurrentState_s = IF2_U1_S or CurrentState_s = IF3_UV1_S else
						 regV_s      when CurrentState_s = ADD_UV_S else
						 regA_s;     --CurrentState_s = F_S or CurrentState_s = U_S or CurrentState_s = V_S or CurrentState_s = T_S
						 
	
	-- FPU Multiplexers
	fpu_i_s <= crossP_s.fpu_o when CurrentState_s = H_S or CurrentState_s = Q_S else
			   dotP_s.fpu_o   when CurrentState_s = A_S or CurrentState_s = U_DOT_S or CurrentState_s = V_DOT_S or CurrentState_s = T_DOT_S else
			   subVec_s.fpu_o when CurrentState_s = EDGE1_S or CurrentState_s = EDGE2_S or CurrentState_s = S_S else
			   top_fpu_s;
				
	-- FPU "Demultiplexers"
	crossP_s.fpu_i  <= fpu_o_s;
	dotP_s.fpu_i    <= fpu_o_s;
	subVec_s.fpu_i  <= fpu_o_s;
	
	-- Cross_Product Instantiation
	instance_cross_product: entity work.cross_product
        port map (
            clk        => clk,
            rst        => rst,
            start_i    => crossP_s.start_i, 
            done_o     => crossP_s.done_o, 
            vecA_i     => crossP_s.vecA_i,
            vecB_i     => crossP_s.vecB_i,
            result_o   => crossP_s.result_o,
            fpu_i      => crossP_s.fpu_i,
            fpu_o      => crossP_s.fpu_o
        );
		
	-- Dot_Product   Instantiation
	instance_dot_product: entity work.dot_product
        port map (
            clk        => clk,
            rst        => rst,
            start_i    => dotP_s.start_i, 
            done_o     => dotP_s.done_o, 
            vecA_i     => dotP_s.vecA_i,
            vecB_i     => dotP_s.vecB_i,
            result_o   => dotP_s.result_o,
            fpu_i      => dotP_s.fpu_i,
            fpu_o      => dotP_s.fpu_o
        );	
	
	-- Sub_Vector    Instantiation
	instance_sub_vector: entity work.sub_vector
        port map (
            clk        => clk,
            rst        => rst,
            start_i    => subVec_s.start_i, 
            done_o     => subVec_s.done_o, 
            vecA_i     => subVec_s.vecA_i,
            vecB_i     => subVec_s.vecB_i,
            result_o   => subVec_s.result_o,
            fpu_i      => subVec_s.fpu_i,
            fpu_o      => subVec_s.fpu_o
        );
		
	-- FPU_Starter   Instantiation
	instance_fpu_starter: entity work.fpu_starter
        port map (
            clk         => clk,
            rst         => rst,
            start_i     => fpu_i_s.start, 
            ready_i     => fpu_o_s.ready, 
            start_o     => fpu_start
        );
		
	-- FPU           Instantiation
	instance_fpu: entity work.fpu
		port map(
			clk_i				=> clk,
			rst_i				=> rst,
			opa_i				=> fpu_i_s.a,
			opb_i				=> fpu_i_s.b,
			fpu_op_i			=> fpu_i_s.op,
			rmode_i				=> FPU_ROUNDING_MODE,
			output_o			=> fpu_o_s.result,
			start_i				=> fpu_start,
			ready_o				=> fpu_o_s.ready,
			ine_o				=> open,
			overflow_o			=> open,
			underflow_o			=> open,
			div_zero_o			=> open,
			inf_o				=> open,
			zero_o				=> open,
			qnan_o				=> open,
			snan_o				=> open,
			altb_o				=> fpu_o_s.agtb,
			blta_o				=> fpu_o_s.altb,
			aeqb_o				=> fpu_o_s.aeqb,
			cmp_unordered_o		=> open,
			cmp_inf_o			=> open,
			cmp_zero_o			=> open
		); 	
end behavioral;
