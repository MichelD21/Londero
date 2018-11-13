# Sets the compiler
set compiler vcom

# Creates the work library if it does not exist
if { ![file exist work] } {
	vlib work
}

# Source files listed in hierarchical order: bottom -> top

set sourceFiles {

	fpupack.vhd
	comppack.vhd
	addsub_28.vhd
	post_norm_addsub.vhd
	pre_norm_addsub.vhd
	fcmp.v
	mul_24.vhd
	post_norm_div.vhd
	post_norm_mul.vhd
	pre_norm_div.vhd
	pre_norm_mul.vhd
	serial_div.vhd
	serial_mul.vhd
	fpu.vhd
	
	fpu_tb.vhd
	}

set top fpu

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