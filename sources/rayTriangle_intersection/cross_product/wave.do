onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cross_product_tb/rst
add wave -noupdate -radix hexadecimal /cross_product_tb/clk
add wave -noupdate -radix hexadecimal /cross_product_tb/vecA
add wave -noupdate -radix hexadecimal /cross_product_tb/vecB
add wave -noupdate -radix hexadecimal /cross_product_tb/start_i
add wave -noupdate -radix hexadecimal /cross_product_tb/result_o
add wave -noupdate -radix hexadecimal /cross_product_tb/done_o
add wave -noupdate -radix hexadecimal /cross_product_tb/CROSS_PRODUCT/CurrentState_s
add wave -noupdate -radix hexadecimal /cross_product_tb/fpu_start
add wave -noupdate -radix hexadecimal /cross_product_tb/fpu_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {99050 ps} {100050 ps}
