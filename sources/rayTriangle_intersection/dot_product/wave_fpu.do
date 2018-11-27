onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cross_product_tb/vecB
add wave -noupdate -radix hexadecimal /cross_product_tb/vecA
add wave -noupdate -radix hexadecimal /cross_product_tb/start_i
add wave -noupdate -radix hexadecimal /cross_product_tb/rst
add wave -noupdate -radix hexadecimal /cross_product_tb/result_o
add wave -noupdate -radix hexadecimal /cross_product_tb/fpu_start
add wave -noupdate -radix hexadecimal /cross_product_tb/fpu_B
add wave -noupdate -radix hexadecimal /cross_product_tb/fpu_A
add wave -noupdate -radix hexadecimal -childformat {{/cross_product_tb/fpu.start_i -radix hexadecimal} {/cross_product_tb/fpu.ready_o -radix hexadecimal} {/cross_product_tb/fpu.a_i -radix hexadecimal} {/cross_product_tb/fpu.b_i -radix hexadecimal} {/cross_product_tb/fpu.op_i -radix hexadecimal} {/cross_product_tb/fpu.result_o -radix hexadecimal} {/cross_product_tb/fpu.gt_o -radix hexadecimal} {/cross_product_tb/fpu.eq_o -radix hexadecimal} {/cross_product_tb/fpu.lt_o -radix hexadecimal}} -subitemconfig {/cross_product_tb/fpu.start_i {-radix hexadecimal} /cross_product_tb/fpu.ready_o {-radix hexadecimal} /cross_product_tb/fpu.a_i {-radix hexadecimal} /cross_product_tb/fpu.b_i {-radix hexadecimal} /cross_product_tb/fpu.op_i {-radix hexadecimal} /cross_product_tb/fpu.result_o {-radix hexadecimal} /cross_product_tb/fpu.gt_o {-radix hexadecimal} /cross_product_tb/fpu.eq_o {-radix hexadecimal} /cross_product_tb/fpu.lt_o {-radix hexadecimal}} /cross_product_tb/fpu
add wave -noupdate -radix hexadecimal /cross_product_tb/done_o
add wave -noupdate -radix hexadecimal /cross_product_tb/clk
add wave -noupdate -radix hexadecimal /cross_product_tb/CROSS_PRODUCT/CurrentState_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {231381 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {198568 ps} {264194 ps}
