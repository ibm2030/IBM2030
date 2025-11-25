transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xilinx_vip  -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l smartconnect_v1_0 "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -l axi_vip_v1_1_21 -l processing_system7_vip_v1_0_23 -l smartconnect_v1_0 "+incdir+../../../../../../../../../mnt/LJW2025/Xilinx/2025.1.1/data/rsb/busdef" "+incdir+/mnt/LJW2025/Xilinx/2025.1.1/data/xilinx_vip/include" -l xilinx_vip -l xpm -l xil_defaultlib \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"/mnt/LJW2025/Xilinx/2025.1.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93  \
"../../../../IBM2030.gen/sources_1/ip/blk_mem_64k_9/blk_mem_64k_9_sim_netlist.vhdl" \

vlog -work xil_defaultlib \
"glbl.v"

