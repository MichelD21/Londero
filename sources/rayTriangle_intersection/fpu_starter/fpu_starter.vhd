
library IEEE;
use IEEE.std_logic_1164.all;

entity fpu_starter is
    port (  
        clk           : in  std_logic;                     -- Clock
        rst           : in  std_logic;                     -- Reset
        
        -- CONTROL_MASTER
        start_i       : in  std_logic;                     -- Continuous in one.
		
		-- CONTROL_FPU
		ready_i       : in  std_logic;                     -- FPU end the operation.
        start_o       : out std_logic                      -- Pulse of one cycle.
    );
end fpu_starter;

architecture behavioral of fpu_starter is
    
	-- FMS states
	type state_t is (WAIT_S, SET_S, DESET_S);
	
	-- CurrentState
	signal CurrentState_s : state_t;
	
begin

	--External signals.
	start_o <= '1' when CurrentState_s = SET_S else '0';
	
    --Global Process
	process(clk, rst)
	begin
		--Reset
		if rst = '1' then
			CurrentState_s <= WAIT_S;
		
		--Clock
		elsif rising_edge(clk) then
			
			--States (FSM)
			case CurrentState_s is
			
				-- Wait a master signal to start.
				when WAIT_S =>
					-- Master need FPU to operate?
					if start_i = '1' then
						CurrentState_s <= SET_S;
					else
						CurrentState_s <= WAIT_S;
					end if;
				
			    -- Set the start_o, to reset FPU.
				when SET_S  =>
					CurrentState_s <= DESET_S;
			
				--DESET_S. Turn down the start_o, so FPU can start to operate. And wait the ready signal.
				when OTHERS  =>
					-- FPU is ready?
					if ready_i = '1' then
						CurrentState_s <= WAIT_S;
					else
						CurrentState_s <= DESET_S;
					end if;
					
			end case;
		end if;
	end process;
	    
end behavioral;