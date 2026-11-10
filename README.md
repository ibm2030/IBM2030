# An IBM System/360 Model 30 in VHDL, modified for the Zynq SoC.

Lawrence Wilkinson lawrence@ljw.me.uk http://www.ljw.me.uk/ibm360

THIS IS A WORK IN PROGRESS

There are four main components to this release:
* VHDL for the CPU (with 64k storage) and Multiplexer channel
* The microcode image (4k x 55)
* The I/O support devices (Block Diagram)
* The processor configuration

I am not claiming copyright to the microcode image - this is based on IBM manuals from 1964-1965 which may or may not be copyrighted themselves.

The VHDL is based on the IBM Maintenance Diagram Manual (MDM), which can be found on Bitsavers.

As supplied, the compiled system is suitable for a Digilent Zybo Z7-20 board, see https://store.digilentinc.com/zybo-z7-zynq-7000-arm-fpga-soc-development-board/
It uses the following I/O:
* VGA output via Digilent VGA adapter on JC/JD
* Serial console output via Digilent RS232 adapter on JA
** TX (K16)
** RX (K14)
* HDMI output
* SPI output for Front Panel LEDs
** CLK (V8)
** LOAD (W8)
** DIN (U7)
* SPI input for Front Panel Switches
** SCL (V12)
** SDA (W16)
* Parallel I/O for a subset of the switches and LEDs
** BTN0 (K18) Reset
** BTN1 (P16) Start
** BTN2 (K19) Load
** BTN3 (Y16) Stop
** SW0 (G15) Lamp Test
** SW1 (P15) Single Cycle
** SW2 (W13) Single Instruction
** SW3 (T16)
** LD0 (M14) MAN
** LD1 (M15) WAIT
** LD2 (G14) TEST
** LD3 (D18) LOAD

If using an alternative board, it may be sufficient to modify the UCF file to reallocate inputs and outputs

These files can be compiled using Xilinx Vivado v2026.1 (and presumably later versions.)

Building the SD card (Zybo Z7-20, Linux boot)
---------------------------------------------

These steps take a modified VHDL design through to a bootable SD card. They were last used with Vivado/Vitis 2026.1 and PetaLinux 2025.2.
The paths below are examples; set them to suit your installation:

```bash
REPO=~<path>/IBM2030                               # this repository
PLNX=<path-to-petalinux>                           # PetaLinux install (contains settings.sh)
PROJ=$PLNX/zynq_petalinux                          # PetaLinux project
XSA=$REPO/zybo2030_wrapper.xsa                     # exported hardware
```

The PetaLinux project configuration is kept in `petalinux/zynq_petalinux/project-spec`. This is a copy of `$PROJ/project-spec`, so keep the two in step.

### 0. Main storage initialisation (only if it has changed)

Main storage (`blk_mem_64k_9`) is initialised from `ibm2030.coe`, which is generated from a punched object deck (`pch00d.txt`):

```bash
cd $REPO
gcc -o pch_to_mem utils/pch_to_mem.c
./pch_to_mem < pch00d.txt > ibm2030.coe
```

Each line of the `.coe` file is 9 bits: data bits 0-7 followed by the (odd) parity bit.
Then in Vivado, under Sources > IP Sources, right-click `blk_mem_64k_9` and choose Reset Output Products, then Generate Output Products.

### 1. Vivado: bitstream and hardware export

1. Open `IBM2030.xpr`.
2. Generate Bitstream. Synthesis and implementation are run first if they are out of date.
3. Check Report Timing Summary. A negative WNS means the design may not work reliably.
4. File > Export > Export Hardware, choose Include bitstream, and save as `<REPO>/zybo2030_wrapper.xsa`.
   Do not include the binary (.bin) file unless `-bin_file` is enabled under Settings > Bitstream, otherwise the export fails with "Unable to get BIN file from implementation run".

Or from the Tcl console:

```tcl
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1
write_hw_platform -fixed -include_bit -force -file $REPO/zybo2030_wrapper.xsa
```

### 2. Vitis: bare-metal application (optional)

This step is not needed to boot Linux, because PetaLinux builds its own boot loader (FSBL).

1. Select the `ibm2030` platform component, open Settings, click Switch XSA and select the new `.xsa`.
2. In FLOW, build `ibm2030`, then build `zybo2030`.
3. Vitis 2026.1 only: if the BSP is regenerated, change `cmake_minimum_required(VERSION 3.3)` to `3.5` in the `xiltimer` and `xilffs` `.cmake` files under `<REPO>/ibm2030/zynq_fsbl/zynq_fsbl_bsp/libsrc/`, or set `CMAKE_POLICY_VERSION_MINIMUM=3.5`.

### 3. PetaLinux: boot files

```bash
cd $PROJ
source $PLNX/settings.sh

petalinux-config --get-hw-description=$XSA --silentconfig
grep -E 'SERIAL_PS7_UART_1|PRIMARY_SD_PS7_SD_0' project-spec/configs/config   # both should be =y

petalinux-build
petalinux-package --boot --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot --force
```

If the `grep` shows nothing, run `petalinux-config` without `--silentconfig` and, under Subsystem Hardware Settings, set Serial to `ps7_uart_1`, Primary SD to `ps7_sd_0` and Ethernet to `ps7_ethernet_0`.
If AXI peripherals were added or renamed in the block design, check that the `axi1` and `axi2` aliases in `project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi` still point to the BRAM controllers.

The output is in `$PROJ/images/linux`: `BOOT.BIN`, `boot.scr` and `image.ub`.

### 4. SD card

The SD card has a 32MB+ FAT partition labelled `PLBOOT`. Check with `lsblk` which device it is (here `/dev/sdb1`).

```bash
I=$PROJ/images/linux
udisksctl mount -b /dev/sdb1
cp $I/BOOT.BIN $I/boot.scr $I/image.ub /media/$USER/PLBOOT/ && sync

# OPTIONAL Remount so the check reads the card rather than the page cache
udisksctl unmount -b /dev/sdb1 && udisksctl mount -b /dev/sdb1
for f in BOOT.BIN boot.scr image.ub; do cmp $I/$f /media/$USER/PLBOOT/$f && echo "$f OK"; done
# End OPTIONAL

udisksctl unmount -b /dev/sdb1
```

If U-Boot reports that the ramdisk image is corrupted, the copy on the card is bad. Re-run the check above, and replace the card if it fails.

### 5. Boot

1. Insert the card and set the Zybo boot-mode jumper to SD.
2. Connect to the console at 115200 baud: `picocom -b 115200 /dev/ttyUSB1` (`/dev/ttyUSB0` is the JTAG port).
3. Power on and log in.
4. Check that `/dev/axi1` (main storage) and `/dev/axi2` (local storage) exist and that `dmesg | grep axibram` shows the driver loaded.

### 6. From the command line
 1. The device /dev/axi1 is mapped to the 64k of Main Storage for reading and writing
 2. The device /dev/axi2 is mapped to the 2k of Local Storage for reading and writing
 3. The utility dump\_ls will print the contents of the 2k local storage area in a readable format

Apologies for the varied quality of the VHDL.  This project has taken over 10 years and I have not necessarily re-visited code that was written early on.  So there is a variety of styles and conventions.  In my defence, it works (or seems to).

Lawrence Wilkinson
lawrence@ljw.me.uk
2026/11/10

