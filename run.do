# Compile the testbench & code
vlog AHB_Master_tb.v
vlog AHB_Master.v

# Run the simulation
vsim AHB_Master_tb

# Add waveforms to view signals
add wave -r /*

# Execute the simulation
run -all