onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /raytriangle_intersection_tb/clk
add wave -noupdate -radix hexadecimal /raytriangle_intersection_tb/rst
add wave -noupdate -radix hexadecimal /raytriangle_intersection_tb/data_av_i
add wave -noupdate -radix hexadecimal /raytriangle_intersection_tb/done_o
add wave -noupdate -radix hexadecimal /raytriangle_intersection_tb/collision_o
add wave -noupdate -radix float32 /raytriangle_intersection_tb/data_i
add wave -noupdate -radix float32 -childformat {{/raytriangle_intersection_tb/result_o(31) -radix float32} {/raytriangle_intersection_tb/result_o(30) -radix float32} {/raytriangle_intersection_tb/result_o(29) -radix float32} {/raytriangle_intersection_tb/result_o(28) -radix float32} {/raytriangle_intersection_tb/result_o(27) -radix float32} {/raytriangle_intersection_tb/result_o(26) -radix float32} {/raytriangle_intersection_tb/result_o(25) -radix float32} {/raytriangle_intersection_tb/result_o(24) -radix float32} {/raytriangle_intersection_tb/result_o(23) -radix float32} {/raytriangle_intersection_tb/result_o(22) -radix float32} {/raytriangle_intersection_tb/result_o(21) -radix float32} {/raytriangle_intersection_tb/result_o(20) -radix float32} {/raytriangle_intersection_tb/result_o(19) -radix float32} {/raytriangle_intersection_tb/result_o(18) -radix float32} {/raytriangle_intersection_tb/result_o(17) -radix float32} {/raytriangle_intersection_tb/result_o(16) -radix float32} {/raytriangle_intersection_tb/result_o(15) -radix float32} {/raytriangle_intersection_tb/result_o(14) -radix float32} {/raytriangle_intersection_tb/result_o(13) -radix float32} {/raytriangle_intersection_tb/result_o(12) -radix float32} {/raytriangle_intersection_tb/result_o(11) -radix float32} {/raytriangle_intersection_tb/result_o(10) -radix float32} {/raytriangle_intersection_tb/result_o(9) -radix float32} {/raytriangle_intersection_tb/result_o(8) -radix float32} {/raytriangle_intersection_tb/result_o(7) -radix float32} {/raytriangle_intersection_tb/result_o(6) -radix float32} {/raytriangle_intersection_tb/result_o(5) -radix float32} {/raytriangle_intersection_tb/result_o(4) -radix float32} {/raytriangle_intersection_tb/result_o(3) -radix float32} {/raytriangle_intersection_tb/result_o(2) -radix float32} {/raytriangle_intersection_tb/result_o(1) -radix float32} {/raytriangle_intersection_tb/result_o(0) -radix float32}} -subitemconfig {/raytriangle_intersection_tb/result_o(31) {-radix float32} /raytriangle_intersection_tb/result_o(30) {-radix float32} /raytriangle_intersection_tb/result_o(29) {-radix float32} /raytriangle_intersection_tb/result_o(28) {-radix float32} /raytriangle_intersection_tb/result_o(27) {-radix float32} /raytriangle_intersection_tb/result_o(26) {-radix float32} /raytriangle_intersection_tb/result_o(25) {-radix float32} /raytriangle_intersection_tb/result_o(24) {-radix float32} /raytriangle_intersection_tb/result_o(23) {-radix float32} /raytriangle_intersection_tb/result_o(22) {-radix float32} /raytriangle_intersection_tb/result_o(21) {-radix float32} /raytriangle_intersection_tb/result_o(20) {-radix float32} /raytriangle_intersection_tb/result_o(19) {-radix float32} /raytriangle_intersection_tb/result_o(18) {-radix float32} /raytriangle_intersection_tb/result_o(17) {-radix float32} /raytriangle_intersection_tb/result_o(16) {-radix float32} /raytriangle_intersection_tb/result_o(15) {-radix float32} /raytriangle_intersection_tb/result_o(14) {-radix float32} /raytriangle_intersection_tb/result_o(13) {-radix float32} /raytriangle_intersection_tb/result_o(12) {-radix float32} /raytriangle_intersection_tb/result_o(11) {-radix float32} /raytriangle_intersection_tb/result_o(10) {-radix float32} /raytriangle_intersection_tb/result_o(9) {-radix float32} /raytriangle_intersection_tb/result_o(8) {-radix float32} /raytriangle_intersection_tb/result_o(7) {-radix float32} /raytriangle_intersection_tb/result_o(6) {-radix float32} /raytriangle_intersection_tb/result_o(5) {-radix float32} /raytriangle_intersection_tb/result_o(4) {-radix float32} /raytriangle_intersection_tb/result_o(3) {-radix float32} /raytriangle_intersection_tb/result_o(2) {-radix float32} /raytriangle_intersection_tb/result_o(1) {-radix float32} /raytriangle_intersection_tb/result_o(0) {-radix float32}} /raytriangle_intersection_tb/result_o
add wave -noupdate /raytriangle_intersection_tb/RAY_TRIANGLE_INTERSECTION/CurrentState_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7973618 ps} 0}
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
WaveRestoreZoom {7941710 ps} {8007336 ps}
