vlib design_test 
vlog -work design_test design_tb.v
vsim design_test.stimulus
add wave -r sim:/stimulus/*
run -all
