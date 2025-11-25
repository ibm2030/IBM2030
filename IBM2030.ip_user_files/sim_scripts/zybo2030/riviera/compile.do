transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/xil_defaultlib
vlib riviera/axi_bram_ctrl_v4_1_13
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_vip_v1_1_21
vlib riviera/processing_system7_vip_v1_0_23
vlib riviera/proc_sys_reset_v5_0_17
vlib riviera/xlconstant_v1_1_10
vlib riviera/smartconnect_v1_0
vlib riviera/axi_register_slice_v2_1_35

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi_bram_ctrl_v4_1_13 riviera/axi_bram_ctrl_v4_1_13
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_21 riviera/axi_vip_v1_1_21
vmap processing_system7_vip_v1_0_23 riviera/processing_system7_vip_v1_0_23
vmap proc_sys_reset_v5_0_17 riviera/proc_sys_reset_v5_0_17
vmap xlconstant_v1_1_10 riviera/xlconstant_v1_1_10
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_register_slice_v2_1_35 riviera/axi_register_slice_v2_1_35

vlog -work xilinx_vip  -incr "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/zybo2030/ip/zybo2030_ibm2030_0_0/sim/zybo2030_ibm2030_0_0.vhd" \

vcom -work axi_bram_ctrl_v4_1_13 -93  -incr \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/2f03/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/zybo2030/ip/zybo2030_axi_bram_ctrl_0_1/sim/zybo2030_axi_bram_ctrl_0_1.vhd" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5 "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_21  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_23  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_processing_system7_0_0/sim/zybo2030_processing_system7_0_0.v" \
"../../../bd/zybo2030/ip/zybo2030_clk_wiz_0_0/zybo2030_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/zybo2030/ip/zybo2030_clk_wiz_0_0/zybo2030_clk_wiz_0_0.v" \

vcom -work proc_sys_reset_v5_0_17 -93  -incr \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/zybo2030/ip/zybo2030_rst_ps7_0_50M_0/sim/zybo2030_rst_ps7_0_50M_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/sim/bd_c662.v" \

vlog -work xlconstant_v1_1_10  -incr -v2k5 "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a165/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_0/sim/bd_c662_one_0.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_c662_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/3718/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_c662_arinsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_c662_rinsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_c662_awinsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_c662_winsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_c662_binsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_c662_aroutsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_c662_routsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_c662_awoutsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_c662_woutsw_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_c662_boutsw_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_c662_arni_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_13/sim/bd_c662_rni_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_14/sim/bd_c662_awni_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_15/sim/bd_c662_wni_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_16/sim/bd_c662_bni_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/d800/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_17/sim/bd_c662_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/2da8/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_18/sim/bd_c662_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/dce3/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_19/sim/bd_c662_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/cef3/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_20/sim/bd_c662_s00a2s_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_21/sim/bd_c662_sarn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_22/sim/bd_c662_srn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_23/sim/bd_c662_sawn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_24/sim/bd_c662_swn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_25/sim/bd_c662_sbn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/7f4f/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_26/sim/bd_c662_m00s2a_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_27/sim/bd_c662_m00arn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_28/sim/bd_c662_m00rn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_29/sim/bd_c662_m00awn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_30/sim/bd_c662_m00wn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_31/sim/bd_c662_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/0133/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_32/sim/bd_c662_m00e_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_33/sim/bd_c662_m01s2a_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_34/sim/bd_c662_m01arn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_35/sim/bd_c662_m01rn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_36/sim/bd_c662_m01awn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_37/sim/bd_c662_m01wn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_38/sim/bd_c662_m01bn_0.sv" \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/bd_0/ip/ip_39/sim/bd_c662_m01e_0.sv" \

vlog -work axi_register_slice_v2_1_35  -incr -v2k5 "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/c5b7/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/ec67/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/6cfa/hdl" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a9be" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/f0b6/hdl/verilog" "+incdir+../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/a8e4/hdl/verilog" "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib -l axi_bram_ctrl_v4_1_13 -l axi_infrastructure_v1_1_0 -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l proc_sys_reset_v5_0_17 -l xlconstant_v1_1_10 -l smartconnect_v1_0 -l axi_register_slice_v2_1_35 \
"../../../bd/zybo2030/ip/zybo2030_smartconnect_0_0/sim/zybo2030_smartconnect_0_0.sv" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/zybo2030/ip/zybo2030_axi_bram_ctrl_2_0/sim/zybo2030_axi_bram_ctrl_2_0.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/ClockGen.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/SyncAsync.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/SyncAsyncReset.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/DVI_Constants.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/OutputSERDES.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/TMDS_Encoder.vhd" \
"../../../../IBM2030.gen/sources_1/bd/zybo2030/ipshared/20df/src/rgb2dvi.vhd" \
"../../../bd/zybo2030/ip/zybo2030_rgb2dvi_0_0/sim/zybo2030_rgb2dvi_0_0.vhd" \
"../../../bd/zybo2030/sim/zybo2030.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

