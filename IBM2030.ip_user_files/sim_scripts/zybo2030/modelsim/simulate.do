onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L xil_defaultlib -L xilinx_vip -L xpm -L axi_bram_ctrl_v4_1_13 -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_21 -L processing_system7_vip_v1_0_23 -L proc_sys_reset_v5_0_17 -L xlconstant_v1_1_10 -L smartconnect_v1_0 -L axi_register_slice_v2_1_35 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.zybo2030 xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {zybo2030.udo}

run 1000ns

quit -force
