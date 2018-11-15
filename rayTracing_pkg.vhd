-------------------------------------------------------------------------
-- Design unit: Ray Tracing package
-- Description:
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package rayTracing_pkg is  
    
	-- Number bits used on data (float)
	constant FLOAT_WIDTH : integer := 32;
	
	-- Constant number in float32
	constant INF_FLOAT32     : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"7F800000";
	constant ZERO_FLOAT32    : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"00000000";
	constant ONE_FLOAT32     : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"3F800000";
	constant EPSILON_FLOAT32 : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"33D6BF95";
    
    -- Instruction_type defines the instructions decodable by the control unit
    type Instruction_type is (ADDU, JR);
	
	subtype data_t is std_logic_vector(FLOAT_WIDTH-1 downto 0);
	
	--Constants for data_t.
	constant DATA_RESET_ZERO : data_t := (OTHERS=>'0');
	
	-- Vector with 3-dimesions type
	type vector3D_t is record
		x : data_t;
		y : data_t;
		z : data_t;
	end record;
	
	--Constants to vector3D_t
	constant VECTOR3D_RESET_ZERO : vector3D_t := (DATA_RESET_ZERO, DATA_RESET_ZERO, DATA_RESET_ZERO);
	
	-- Type ray
	type ray_t is record
		o : vector3D_t;
		d : vector3D_t;
	end record;
	
	-- Type triangle
	type triangle_t is record
		v0 : vector3D_t;
		v1 : vector3D_t;
		v2 : vector3D_t;
	end record;
	
	--FPU operations
	constant FPU_ADD : std_logic_vector(2 downto 0) := "000";
	constant FPU_SUB : std_logic_vector(2 downto 0) := "001";
	constant FPU_MUL : std_logic_vector(2 downto 0) := "010";
	constant FPU_DIV : std_logic_vector(2 downto 0) := "011";
	constant FPU_CMP : std_logic_vector(2 downto 0) := "100";
	
	
	-- FPU comunication
	type fpu_t is record
		-- Arithmetic (FPU)
		start_i  : std_logic;
		ready_o  : std_logic;
		a_i      : data_t;
		b_i      : data_t;
		
		-- Arithmetic (FPU)
		op_i     : std_logic_vector(2 downto 0);
		result_o : data_t;
		
		--Comparator
		gt_o     : std_logic;
		eq_o     : std_logic;
		lt_o     : std_logic;
	end record;
                
end package;


