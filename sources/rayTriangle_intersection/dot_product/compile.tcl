# Sets the compiler
set compiler vcom

# Creates the work library if it does not exist
if { ![file exist work] } {
	vlib work
}

# Source files listed in hierarchical order: bottom -> top

set sourceFiles {
	
	lib/rayTracing_pkg.vhd
	
	
	
	fpu/fpupack.vhd
	fpu/comppack.vhd
	fpu/addsub_28.vhd
	fpu/post_norm_addsub.vhd
	fpu/pre_norm_addsub.vhd
	fpu/fcmp.v
	fpu/mul_24.vhd
	fpu/post_norm_div.vhd
	fpu/post_norm_mul.vhd
	fpu/pre_norm_div.vhd
	fpu/pre_norm_mul.vhd
	fpu/serial_div.vhd
	fpu/serial_mul.vhd
	fpu/fpu.vhd
	
	
	
	fpu_starter/fpu_starter.vhd
		
	dot_product/dot_product.vhd
	dot_product/dot_product_tb.vhd
		
	}

set top dot_product

if { [llength $sourceFiles] > 0 } {
	
	foreach file $sourceFiles {
		if [ catch {$compiler $file} ] {
			if [catch {vlog $file} ] {
				puts "\n*** ERROR compiling file $file :( ***" 
			return;
			}
		}
	}
}

if { [llength $sourceFiles] > 0 } {
	
	puts "\n*** Compiled files:"  
	
	foreach file $sourceFiles {
		puts \t$file
	}
}

puts "\n*** Compilation OK ;) ***"

set StdArithNoWarnings 1