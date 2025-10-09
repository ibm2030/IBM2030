transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+blk_mem_2k_9  -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_11 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.blk_mem_2k_9 xil_defaultlib.glbl

do {blk_mem_2k_9.udo}

run 1000ns

endsim

quit -force
