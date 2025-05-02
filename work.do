vlib work
vlog -work work testbench.v
vsim work.stimulus
add wave -r sim:/stimulus/*
run -all
