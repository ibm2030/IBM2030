vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L processing_system7_vip_v1_0_23 -L smartconnect_v1_0 -L xilinx_vip "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L processing_system7_vip_v1_0_23 -L smartconnect_v1_0 -L xilinx_vip "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../../IBM2030.gen/sources_1/ip/blk_mem_64k_9/blk_mem_64k_9_sim_netlist.vhdl" \

vlog -work xil_defaultlib \
"glbl.v"

