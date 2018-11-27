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
	constant CTE_INF     : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"7F800000";
	constant CTE_ZERO    : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"00000000";
	constant CTE_ONE     : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"3F800000";
	constant CTE_EPSILON : std_logic_vector(FLOAT_WIDTH-1 downto 0) := x"33D6BF95";
    
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
	
	-- FPU operations
	constant FPU_ADD : std_logic_vector(2 downto 0) := "000";
	constant FPU_SUB : std_logic_vector(2 downto 0) := "001";
	constant FPU_MUL : std_logic_vector(2 downto 0) := "010";
	constant FPU_DIV : std_logic_vector(2 downto 0) := "011";
	constant FPU_CMP : std_logic_vector(2 downto 0) := "100";
	
	-- FPU rounding mode
	constant FPU_ROUNDING_MODE : std_logic_vector(1 downto 0) := "00"; -- round to nearest even
	
	-- FPU comunication. From Circ to FPU.
	type fpu_o_t is record
		-- Arithmetic (FPU)
		start  : std_logic;
		a      : data_t;
		b      : data_t;
		
		-- Arithmetic (FPU)
		op     : std_logic_vector(2 downto 0);
	end record;
	
	-- FPU comunication. From FPU to Circ.
	type fpu_i_t is record
		-- Arithmetic (FPU)
		ready  : std_logic;
		
		-- Arithmetic (FPU)
		result : data_t;
		
		--Comparator
		agtb     : std_logic;
		aeqb     : std_logic;
		altb     : std_logic;
	end record;
	
	-- Type used for top comunicate to the subcircuits that return a vector.
	type subCirc_vivo_t is record
		 -- Control
        start_i       : std_logic;     -- Start the operation (sub_vec)
        done_o        : std_logic;     -- Operation is DONE   (sub_vec)   

		-- Data
		vecA_i        : vector3D_t;    -- Vector_A
		vecB_i        : vector3D_t;    -- Vector_B
		result_o      : vector3D_t;    -- Operation result
		
		-- FPU
		fpu_i        : fpu_i_t;                       --Control and Data from fpu.
		fpu_o        : fpu_o_t;                      --Control and Data to fpu.
	end record;
	
	-- Type used for top comunicate to the subcircuits that return a data.
	type subCirc_vido_t is record
		 -- Control
        start_i       : std_logic;     -- Start the operation (sub_vec)
        done_o        : std_logic;     -- Operation is DONE   (sub_vec)   

		-- Data
		vecA_i        : vector3D_t;    -- Vector_A
		vecB_i        : vector3D_t;    -- Vector_B
		result_o      : data_t;        -- Operation result
		
		-- FPU
		fpu_i        : fpu_i_t;                       --Control and Data from fpu.
		fpu_o        : fpu_o_t;                      --Control and Data to fpu.
	end record;	
                
end package;


